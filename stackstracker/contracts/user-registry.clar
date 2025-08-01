;; StacksTracker User Registry Contract
;; User profile management and Bitcoin address verification

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_USER_NOT_FOUND (err u201))
(define-constant ERR_USER_ALREADY_EXISTS (err u202))
(define-constant ERR_INVALID_USERNAME (err u203))
(define-constant ERR_USERNAME_TAKEN (err u204))
(define-constant ERR_INVALID_BTC_ADDRESS (err u205))
(define-constant ERR_BTC_ADDRESS_ALREADY_LINKED (err u206))
(define-constant ERR_INVALID_SIGNATURE (err u207))
(define-constant ERR_REGISTRY_NOT_FOUND (err u208))
(define-constant ERR_INVALID_EMAIL_HASH (err u209))
(define-constant ERR_BTC_ADDRESS_NOT_FOUND (err u210))
(define-constant ERR_VERIFICATION_FAILED (err u211))

;; Contract references
(define-constant REGISTRY_CONTRACT .stacks-registry)

;; Data Variables
(define-data-var contract-version (string-ascii 10) "1.0.0")
(define-data-var total-users uint u0)
(define-data-var total-btc-addresses uint u0)

;; Data Maps
;; Main user profiles
(define-map user-profiles 
    principal ;; Stacks address
    {
        username: (optional (string-utf8 50)),
        email-hash: (optional (string-ascii 64)), ;; SHA-256 hash for privacy
        created-at: uint,
        updated-at: uint,
        profile-status: uint, ;; 0=active, 1=suspended, 2=deleted
        subscription-tier: uint, ;; 0=free, 1=pro, 2=enterprise
        total-portfolios: uint,
        last-login: uint
    }
)

;; Username to address mapping for uniqueness
(define-map username-registry 
    (string-utf8 50) 
    principal
)

;; Bitcoin address management
(define-map btc-address-links 
    {stacks-address: principal, btc-address: (string-ascii 64)}
    {
        verified: bool,
        verification-signature: (optional (buff 65)),
        verification-message: (optional (string-ascii 200)),
        linked-at: uint,
        verified-at: (optional uint),
        address-type: (string-ascii 20), ;; "legacy", "segwit", "taproot"
        label: (optional (string-utf8 100)) ;; User-defined label
    }
)

;; Reverse lookup: BTC address to Stacks address
(define-map btc-to-stacks 
    (string-ascii 64) 
    principal
)

;; User activity tracking
(define-map user-activity 
    principal 
    {
        last-portfolio-update: uint,
        last-btc-sync: uint,
        total-transactions: uint,
        total-nfts: uint,
        total-ordinals: uint
    }
)

;; Email verification (optional feature)
(define-map email-verification 
    principal 
    {
        verification-code: (string-ascii 32),
        expires-at: uint,
        verified: bool,
        attempts: uint
    }
)

;; Profile settings and preferences
(define-map user-preferences 
    principal 
    {
        privacy-level: uint, ;; 0=public, 1=friends, 2=private
        notifications-enabled: bool,
        auto-sync-btc: bool,
        default-currency: (string-ascii 10), ;; "USD", "BTC", "STX"
        timezone: (string-ascii 50)
    }
)

;; Private Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (is-registry-admin)
    (contract-call? REGISTRY_CONTRACT check-permission "user-registry" tx-sender u4) ;; PERMISSION_ADMIN
)

(define-private (validate-username (username (string-utf8 50)))
    (and 
        (>= (len username) u3)
        (<= (len username) u50)
        ;; Add more validation logic here (alphanumeric, no special chars, etc.)
    )
)

(define-private (validate-btc-address (address (string-ascii 64)))
    (and 
        (>= (len address) u26) ;; Minimum Bitcoin address length
        (<= (len address) u64) ;; Maximum reasonable length
        ;; Add more Bitcoin address format validation here
    )
)

(define-private (validate-email-hash (hash (string-ascii 64)))
    (is-eq (len hash) u64) ;; SHA-256 hash should be exactly 64 chars
)

(define-private (get-btc-address-type (address (string-ascii 64)))
    (let ((first-char (unwrap-panic (element-at address u0))))
        (if (is-eq first-char "1")
            "legacy"
            (if (is-eq first-char "3")
                "segwit"
                (if (is-eq first-char "b")
                    "segwit" ;; bech32
                    "taproot" ;; assume taproot for other formats
                )
            )
        )
    )
)

(define-private (user-exists (user principal))
    (is-some (map-get? user-profiles user))
)

;; Public Functions

;; Create a new user profile
(define-public (create-profile (username (optional (string-utf8 50))) (email-hash (optional (string-ascii 64))))
    (let ((current-block block-height))
        (begin
            ;; Validate inputs
            (match username
                some-username 
                (begin
                    (asserts! (validate-username some-username) ERR_INVALID_USERNAME)
                    (asserts! (is-none (map-get? username-registry some-username)) ERR_USERNAME_TAKEN)
                )
                true ;; username is optional
            )
            
            (match email-hash
                some-hash (asserts! (validate-email-hash some-hash) ERR_INVALID_EMAIL_HASH)
                true ;; email-hash is optional
            )
            
            ;; Check if user already exists
            (asserts! (not (user-exists tx-sender)) ERR_USER_ALREADY_EXISTS)
            
            ;; Create user profile
            (map-set user-profiles tx-sender {
                username: username,
                email-hash: email-hash,
                created-at: current-block,
                updated-at: current-block,
                profile-status: u0, ;; active
                subscription-tier: u0, ;; free
                total-portfolios: u0,
                last-login: current-block
            })
            
            ;; Register username if provided
            (match username
                some-username (map-set username-registry some-username tx-sender)
                true
            )
            
            ;; Initialize user preferences with defaults
            (map-set user-preferences tx-sender {
                privacy-level: u1, ;; friends by default
                notifications-enabled: true,
                auto-sync-btc: true,
                default-currency: "USD",
                timezone: "UTC"
            })
            
            ;; Initialize activity tracking
            (map-set user-activity tx-sender {
                last-portfolio-update: u0,
                last-btc-sync: u0,
                total-transactions: u0,
                total-nfts: u0,
                total-ordinals: u0
            })
            
            ;; Update total users count
            (var-set total-users (+ (var-get total-users) u1))
            
            (ok true)
        )
    )
)

;; Update user profile
(define-public (update-profile 
    (new-username (optional (string-utf8 50))) 
    (new-email-hash (optional (string-ascii 64)))
)
    (let ((current-profile (unwrap! (map-get? user-profiles tx-sender) ERR_USER_NOT_FOUND)))
        (begin
            ;; Validate new username if provided
            (match new-username
                some-username 
                (begin
                    (asserts! (validate-username some-username) ERR_INVALID_USERNAME)
                    ;; Remove old username mapping if it exists
                    (match (get username current-profile)
                        old-username (map-delete username-registry old-username)
                        true
                    )
                    ;; Check if new username is available
                    (asserts! (is-none (map-get? username-registry some-username)) ERR_USERNAME_TAKEN)
                    ;; Set new username mapping
                    (map-set username-registry some-username tx-sender)
                )
                ;; If new-username is none but old username exists, remove it
                (match (get username current-profile)
                    old-username (map-delete username-registry old-username)
                    true
                )
            )
            
            ;; Validate email hash if provided
            (match new-email-hash
                some-hash (asserts! (validate-email-hash some-hash) ERR_INVALID_EMAIL_HASH)
                true
            )
            
            ;; Update profile
            (map-set user-profiles tx-sender 
                (merge current-profile {
                    username: new-username,
                    email-hash: new-email-hash,
                    updated-at: block-height
                })
            )
            
            (ok true)
        )
    )
)

;; Link Bitcoin address to user profile
(define-public (link-btc-address 
    (btc-address (string-ascii 64)) 
    (signature (optional (buff 65)))
    (verification-message (optional (string-ascii 200)))
    (label (optional (string-utf8 100)))
)
    (let ((address-type (get-btc-address-type btc-address)))
        (begin
            ;; Validate inputs
            (asserts! (user-exists tx-sender) ERR_USER_NOT_FOUND)
            (asserts! (validate-btc-address btc-address) ERR_INVALID_BTC_ADDRESS)
            
            ;; Check if BTC address is already linked to any user
            (asserts! (is-none (map-get? btc-to-stacks btc-address)) ERR_BTC_ADDRESS_ALREADY_LINKED)
            
            ;; Create address link
            (map-set btc-address-links 
                {stacks-address: tx-sender, btc-address: btc-address}
                {
                    verified: (is-some signature), ;; Auto-verify if signature provided
                    verification-signature: signature,
                    verification-message: verification-message,
                    linked-at: block-height,
                    verified-at: (if (is-some signature) (some block-height) none),
                    address-type: address-type,
                    label: label
                }
            )
            
            ;; Create reverse lookup
            (map-set btc-to-stacks btc-address tx-sender)
            
            ;; Update counters
            (var-set total-btc-addresses (+ (var-get total-btc-addresses) u1))
            
            (ok true)
        )
    )
)

;; Verify Bitcoin address ownership with signature
(define-public (verify-btc-address 
    (btc-address (string-ascii 64)) 
    (signature (buff 65))
    (message (string-ascii 200))
)
    (let ((address-link-key {stacks-address: tx-sender, btc-address: btc-address}))
        (match (map-get? btc-address-links address-link-key)
            link-data
            (begin
                ;; TODO: Implement actual signature verification logic here
                ;; This would require Bitcoin signature verification primitives
                ;; For now, we'll assume verification is successful if signature is provided
                
                (map-set btc-address-links address-link-key
                    (merge link-data {
                        verified: true,
                        verification-signature: (some signature),
                        verification-message: (some message),
                        verified-at: (some block-height)
                    })
                )
                (ok true)
            )
            ERR_BTC_ADDRESS_NOT_FOUND
        )
    )
)

;; Remove Bitcoin address link
(define-public (unlink-btc-address (btc-address (string-ascii 64)))
    (let ((address-link-key {stacks-address: tx-sender, btc-address: btc-address}))
        (begin
            (asserts! (is-some (map-get? btc-address-links address-link-key)) ERR_BTC_ADDRESS_NOT_FOUND)
            
            ;; Remove address link
            (map-delete btc-address-links address-link-key)
            (map-delete btc-to-stacks btc-address)
            
            ;; Update counter
            (var-set total-btc-addresses (- (var-get total-btc-addresses) u1))
            
            (ok true)
        )
    )
)

;; Update user preferences
(define-public (update-preferences 
    (privacy-level uint)
    (notifications-enabled bool)
    (auto-sync-btc bool)
    (default-currency (string-ascii 10))
    (timezone (string-ascii 50))
)
    (begin
        (asserts! (user-exists tx-sender) ERR_USER_NOT_FOUND)
        (asserts! (<= privacy-level u2) ERR_UNAUTHORIZED) ;; Valid privacy levels: 0-2
        
        (map-set user-preferences tx-sender {
            privacy-level: privacy-level,
            notifications-enabled: notifications-enabled,
            auto-sync-btc: auto-sync-btc,
            default-currency: default-currency,
            timezone: timezone
        })
        
        (ok true)
    )
)

;; Update user activity (called by other contracts)
(define-public (update-user-activity 
    (user principal)
    (activity-type (string-ascii 20))
    (increment-count uint)
)
    (begin
        ;; Only allow calls from registered contracts
        (asserts! (or 
            (is-registry-admin)
            (contract-call? REGISTRY_CONTRACT is-contract-active "portfolio-manager")
        ) ERR_UNAUTHORIZED)
        
        (match (map-get? user-activity user)
            current-activity
            (let ((updated-activity 
                (if (is-eq activity-type "portfolio")
                    (merge current-activity {
                        last-portfolio-update: block-height,
                        total-transactions: (+ (get total-transactions current-activity) increment-count)
                    })
                    (if (is-eq activity-type "nft")
                        (merge current-activity {
                            total-nfts: (+ (get total-nfts current-activity) increment-count)
                        })
                        (if (is-eq activity-type "ordinals")
                            (merge current-activity {
                                total-ordinals: (+ (get total-ordinals current-activity) increment-count)
                            })
                            (merge current-activity {
                                last-btc-sync: block-height
                            })
                        )
                    )
                )))
                (map-set user-activity user updated-activity)
                (ok true)
            )
            ERR_USER_NOT_FOUND
        )
    )
)

;; Update user subscription tier (admin only)
(define-public (update-subscription-tier (user principal) (new-tier uint))
    (begin
        (asserts! (is-registry-admin) ERR_UNAUTHORIZED)
        (asserts! (<= new-tier u2) ERR_UNAUTHORIZED) ;; Valid tiers: 0-2
        
        (match (map-get? user-profiles user)
            profile-data
            (begin
                (map-set user-profiles user 
                    (merge profile-data {
                        subscription-tier: new-tier,
                        updated-at: block-height
                    })
                )
                (ok true)
            )
            ERR_USER_NOT_FOUND
        )
    )
)

;; Read-only Functions

;; Get user profile
(define-read-only (get-user-profile (user principal))
    (map-get? user-profiles user)
)

;; Get user by username
(define-read-only (get-user-by-username (username (string-utf8 50)))
    (match (map-get? username-registry username)
        user-address (map-get? user-profiles user-address)
        none
    )
)

;; Get Bitcoin address details
(define-read-only (get-btc-address-details (stacks-address principal) (btc-address (string-ascii 64)))
    (map-get? btc-address-links {stacks-address: stacks-address, btc-address: btc-address})
)

;; Get Stacks address from Bitcoin address
(define-read-only (get-stacks-from-btc (btc-address (string-ascii 64)))
    (map-get? btc-to-stacks btc-address)
)

;; Get user preferences
(define-read-only (get-user-preferences (user principal))
    (map-get? user-preferences user)
)

;; Get user activity
(define-read-only (get-user-activity (user principal))
    (map-get? user-activity user)
)

;; Check if username is available
(define-read-only (is-username-available (username (string-utf8 50)))
    (is-none (map-get? username-registry username))
)

;; Check if Bitcoin address is linked
(define-read-only (is-btc-address-linked (btc-address (string-ascii 64)))
    (is-some (map-get? btc-to-stacks btc-address))
)

;; Get user's Bitcoin addresses
(define-read-only (get-user-btc-addresses (user principal))
    ;; This would need to be implemented with a more complex data structure
    ;; or through iteration in a real implementation
    ;; For now, returning a placeholder response
    (if (user-exists user)
        (ok "btc-addresses-list") ;; Placeholder
        ERR_USER_NOT_FOUND
    )
)

;; Get contract statistics
(define-read-only (get-contract-stats)
    {
        version: (var-get contract-version),
        total-users: (var-get total-users),
        total-btc-addresses: (var-get total-btc-addresses),
        contract-owner: CONTRACT_OWNER
    }
)

;; Check if user exists
(define-read-only (user-exists-check (user principal))
    (user-exists user)
)

;; Validate Bitcoin address format
(define-read-only (validate-btc-address-format (address (string-ascii 64)))
    (validate-btc-address address)
)

;; Get subscription tiers info
(define-read-only (get-subscription-tiers)
    {
        free: u0,
        pro: u1,
        enterprise: u2
    }
)