;; StacksTracker Registry Contract 
;; Enhanced registry with admin system and versioning

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_CONTRACT_NOT_FOUND (err u101))
(define-constant ERR_CONTRACT_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_CONTRACT_NAME (err u103))
(define-constant ERR_ADMIN_NOT_FOUND (err u105))
(define-constant ERR_ALREADY_ADMIN (err u106))

;; Data Variables
(define-data-var contract-version (string-ascii 10) "0.5.0")
(define-data-var registry-paused bool false)

;; Data Maps
;; Stores mapping of contract names to their addresses
(define-map registered-contracts 
    (string-ascii 64) 
    {
        contract-address: principal,
        registered-at: uint,
        is-active: bool,
        version: (string-ascii 10),
        description: (string-utf8 200)
    }
)

;; Stores admin permissions for each contract
(define-map contract-admins 
    {contract-name: (string-ascii 64), admin: principal}
    {
        granted-at: uint,
        granted-by: principal,
        can-update: bool,
        can-manage-admins: bool
    }
)

;; Global admins who can manage the registry
(define-map global-admins 
    principal 
    {
        granted-at: uint,
        granted-by: principal,
        is-active: bool
    }
)

;; Private Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (is-global-admin (user principal))
    (match (map-get? global-admins user)
        admin-data (get is-active admin-data)
        false
    )
)

(define-private (is-contract-admin (contract-name (string-ascii 64)) (user principal))
    (is-some (map-get? contract-admins {contract-name: contract-name, admin: user}))
)

(define-private (can-update-contract (contract-name (string-ascii 64)) (user principal))
    (or 
        (is-contract-owner)
        (is-global-admin user)
        (match (map-get? contract-admins {contract-name: contract-name, admin: user})
            admin-data (get can-update admin-data)
            false
        )
    )
)

(define-private (can-manage-admins (contract-name (string-ascii 64)) (user principal))
    (or 
        (is-contract-owner)
        (is-global-admin user)
        (match (map-get? contract-admins {contract-name: contract-name, admin: user})
            admin-data (get can-manage-admins admin-data)
            false
        )
    )
)

(define-private (validate-contract-name (name (string-ascii 64)))
    (and 
        (> (len name) u0)
        (<= (len name) u64)
    )
)

;; Public Functions

;; Initialize the registry (can only be called once by contract owner)
(define-public (initialize)
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        ;; Add contract owner as global admin
        (map-set global-admins CONTRACT_OWNER {
            granted-at: block-height,
            granted-by: CONTRACT_OWNER,
            is-active: true
        })
        (ok true)
    )
)

;; Register a new contract in the registry
(define-public (register-contract 
    (name (string-ascii 64)) 
    (contract-address principal)
    (version (string-ascii 10))
    (description (string-utf8 200))
)
    (begin
        (asserts! (not (var-get registry-paused)) ERR_UNAUTHORIZED)
        (asserts! (or (is-contract-owner) (is-global-admin tx-sender)) ERR_UNAUTHORIZED)
        (asserts! (validate-contract-name name) ERR_INVALID_CONTRACT_NAME)
        (asserts! (is-none (map-get? registered-contracts name)) ERR_CONTRACT_ALREADY_EXISTS)
        
        ;; Register the contract
        (map-set registered-contracts name {
            contract-address: contract-address,
            registered-at: block-height,
            is-active: true,
            version: version,
            description: description
        })
        
        ;; Grant admin permissions to the registering user
        (map-set contract-admins {contract-name: name, admin: tx-sender} {
            granted-at: block-height,
            granted-by: tx-sender,
            can-update: true,
            can-manage-admins: true
        })
        
        (ok true)
    )
)

;; Update an existing contract registration
(define-public (update-contract
    (name (string-ascii 64))
    (new-address principal)
    (new-version (string-ascii 10))
    (new-description (string-utf8 200))
)
    (begin
        (asserts! (not (var-get registry-paused)) ERR_UNAUTHORIZED)
        (asserts! (can-update-contract name tx-sender) ERR_UNAUTHORIZED)
        
        (match (map-get? registered-contracts name)
            contract-data 
            (begin
                (map-set registered-contracts name {
                    contract-address: new-address,
                    registered-at: (get registered-at contract-data),
                    is-active: (get is-active contract-data),
                    version: new-version,
                    description: new-description
                })
                (ok true)
            )
            ERR_CONTRACT_NOT_FOUND
        )
    )
)

;; Activate or deactivate a contract
(define-public (set-contract-status (name (string-ascii 64)) (active bool))
    (begin
        (asserts! (can-manage-admins name tx-sender) ERR_UNAUTHORIZED)
        
        (match (map-get? registered-contracts name)
            contract-data
            (begin
                (map-set registered-contracts name (merge contract-data {is-active: active}))
                (ok true)
            )
            ERR_CONTRACT_NOT_FOUND
        )
    )
)

;; Grant admin permissions to a user for a specific contract
(define-public (grant-contract-admin 
    (contract-name (string-ascii 64)) 
    (admin principal) 
    (can-update bool)
    (can-manage-admins bool)
)
    (begin
        (asserts! (can-manage-admins contract-name tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-some (map-get? registered-contracts contract-name)) ERR_CONTRACT_NOT_FOUND)
        
        (map-set contract-admins {contract-name: contract-name, admin: admin} {
            granted-at: block-height,
            granted-by: tx-sender,
            can-update: can-update,
            can-manage-admins: can-manage-admins
        })
        
        (ok true)
    )
)

;; Revoke admin permissions from a user for a specific contract
(define-public (revoke-contract-admin 
    (contract-name (string-ascii 64)) 
    (admin principal)
)
    (begin
        (asserts! (can-manage-admins contract-name tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-some (map-get? contract-admins {contract-name: contract-name, admin: admin})) ERR_ADMIN_NOT_FOUND)
        
        (map-delete contract-admins {contract-name: contract-name, admin: admin})
        (ok true)
    )
)

;; Grant global admin permissions (only contract owner)
(define-public (grant-global-admin (admin principal))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (is-none (map-get? global-admins admin)) ERR_ALREADY_ADMIN)
        
        (map-set global-admins admin {
            granted-at: block-height,
            granted-by: tx-sender,
            is-active: true
        })
        (ok true)
    )
)

;; Revoke global admin permissions (only contract owner)
(define-public (revoke-global-admin (admin principal))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq admin CONTRACT_OWNER)) ERR_UNAUTHORIZED) ;; Cannot revoke owner
        
        (match (map-get? global-admins admin)
            admin-data
            (begin
                (map-set global-admins admin (merge admin-data {is-active: false}))
                (ok true)
            )
            ERR_ADMIN_NOT_FOUND
        )
    )
)

;; Pause/unpause the registry (emergency function)
(define-public (set-registry-pause (paused bool))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (var-set registry-paused paused)
        (ok true)
    )
)

;; Read-only Functions

;; Get contract address by name
(define-read-only (get-contract-address (name (string-ascii 64)))
    (match (map-get? registered-contracts name)
        contract-data 
        (if (get is-active contract-data)
            (some (get contract-address contract-data))
            none
        )
        none
    )
)

;; Get full contract details
(define-read-only (get-contract-details (name (string-ascii 64)))
    (map-get? registered-contracts name)
)

;; Get contract admin details
(define-read-only (get-contract-admin-details 
    (contract-name (string-ascii 64)) 
    (admin principal)
)
    (map-get? contract-admins {contract-name: contract-name, admin: admin})
)

;; Check if user is global admin
(define-read-only (is-user-global-admin (user principal))
    (is-global-admin user)
)

;; Get registry status
(define-read-only (get-registry-status)
    {
        version: (var-get contract-version),
        paused: (var-get registry-paused),
        owner: CONTRACT_OWNER
    }
)

;; Verify contract exists and is active
(define-read-only (is-contract-active (name (string-ascii 64)))
    (match (map-get? registered-contracts name)
        contract-data (get is-active contract-data)
        false
    )
)