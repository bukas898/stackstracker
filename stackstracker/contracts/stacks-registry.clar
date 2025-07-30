;; StacksTracker Registry Contract 
;; Basic contract registration and lookup functionality

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_CONTRACT_NOT_FOUND (err u101))
(define-constant ERR_CONTRACT_ALREADY_EXISTS (err u102))
(define-constant ERR_INVALID_CONTRACT_NAME (err u103))

;; Data Variables
(define-data-var contract-version (string-ascii 10) "0.1.0")

;; Data Maps
;; Stores mapping of contract names to their addresses
(define-map registered-contracts 
    (string-ascii 64) 
    {
        contract-address: principal,
        registered-at: uint,
        is-active: bool
    }
)

;; Private Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (validate-contract-name (name (string-ascii 64)))
    (and 
        (> (len name) u0)
        (<= (len name) u64)
    )
)

;; Public Functions

;; Register a new contract in the registry
(define-public (register-contract 
    (name (string-ascii 64)) 
    (contract-address principal)
)
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (validate-contract-name name) ERR_INVALID_CONTRACT_NAME)
        (asserts! (is-none (map-get? registered-contracts name)) ERR_CONTRACT_ALREADY_EXISTS)
        
        ;; Register the contract
        (map-set registered-contracts name {
            contract-address: contract-address,
            registered-at: block-height,
            is-active: true
        })
        
        (ok true)
    )
)

;; Update an existing contract address
(define-public (update-contract-address
    (name (string-ascii 64))
    (new-address principal)
)
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        
        (match (map-get? registered-contracts name)
            contract-data 
            (begin
                (map-set registered-contracts name {
                    contract-address: new-address,
                    registered-at: (get registered-at contract-data),
                    is-active: (get is-active contract-data)
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
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        
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

;; Verify contract exists and is active
(define-read-only (is-contract-active (name (string-ascii 64)))
    (match (map-get? registered-contracts name)
        contract-data (get is-active contract-data)
        false
    )
)

;; Get registry version
(define-read-only (get-registry-version)
    (var-get contract-version)
)