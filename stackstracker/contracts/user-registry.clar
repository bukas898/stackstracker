;; StacksTracker User Registry Contract - Bitcoin Integration
;; User profile management with Bitcoin address linking

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_USER_NOT_FOUND (err u201))
(define-constant ERR_USER_ALREADY_EXISTS (err u202))
(define-constant ERR_INVALID_USERNAME (err u203))
(define-constant ERR_USERNAME_TAKEN (err u204))
(define-constant ERR_INVALID_BTC_ADDRESS (err u205))
(define-constant ERR_BTC_ADDRESS_ALREADY_LINKED (err u206))
(define-constant ERR_INVALID_EMAIL_HASH (err u209))
(define-constant ERR_BTC_ADDRESS_NOT_FOUND (err u210))

;; Data Variables
(define-data-var contract-version (string-ascii 10) "2.0.0")
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
        subscription-tier: uint ;; 0=free, 1=pro, 2=enterprise
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
        linked-at: uint,
        address-type: (string-ascii 20), ;; "legacy", "segwit", "taproot"
        label: (optional (string-utf8 100)) ;; User-defined label
    }
)

;; Reverse lookup: BTC address to Stacks address
(define-map btc-to-stacks 
    (string-ascii 64) 
    principal
)

;; User preferences
(define-map user-preferences 
    principal 
    {
        privacy-level: uint, ;; 0=public, 1=friends, 2=private
        notifications-enabled: bool,
        default-currency: (string-ascii 10) ;; "USD", "BTC", "STX"
    }
)

;; Private Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (validate-username (username (string-utf8 50)))
    (and 
        (>= (len username) u3)
        (<= (len username) u50)
    )
)

(define-private (validate-btc-address (address (string-ascii 64)))
    (and 
        (>= (len address) u26) ;; Minimum Bitcoin address length
        (<= (len address) u64) ;; Maximum reasonable length
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
                subscription-tier: u0 ;; free
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
                default-currency: "USD"
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
                    verified: false, ;; Manual verification required
                    linked-at: block-height,
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

;; Verify Bitcoin address (admin only for now)
(define-public (verify-btc-address (user principal) (btc-address (string-ascii 64)))
    (let ((address-link-key {stacks-address: user, btc-address: btc-address}))
        (begin
            (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
            
            (match (map-get? btc-address-links address-link-key)
                link-data
                (begin
                    (map-set btc-address-links address-link-key
                        (merge link-data {
                            verified: true
                        })
                    )
                    (ok true)
                )
                ERR_BTC_ADDRESS_NOT_FOUND
            )
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
    (default-currency (string-ascii 10))
)
    (begin
        (asserts! (user-exists tx-sender) ERR_USER_NOT_FOUND)
        (asserts! (<= privacy-level u2) ERR_UNAUTHORIZED) ;; Valid privacy levels: 0-2
        
        (map-set user-preferences tx-sender {
            privacy-level: privacy-level,
            notifications-enabled: notifications-enabled,
            default-currency: default-currency
        })
        
        (ok true)
    )
)

;; Update subscription tier (admin only)
(define-public (update-subscription-tier (user principal) (new-tier uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
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

;; Check if username is available
(define-read-only (is-username-available (username (string-utf8 50)))
    (is-none (map-get? username-registry username))
)

;; Check if Bitcoin address is linked
(define-read-only (is-btc-address-linked (btc-address (string-ascii 64)))
    (is-some (map-get? btc-to-stacks btc-address))
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
