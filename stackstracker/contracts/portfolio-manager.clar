;; StacksTracker Portfolio Manager Contract (Stage 1 - MVP)
;; Minimal viable product for basic portfolio creation and management

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_PORTFOLIO_NOT_FOUND (err u301))
(define-constant ERR_PORTFOLIO_ALREADY_EXISTS (err u302))
(define-constant ERR_INVALID_PORTFOLIO_NAME (err u303))
(define-constant ERR_INVALID_QUANTITY (err u307))

;; Asset type constants
(define-constant ASSET_TYPE_BTC "btc")
(define-constant ASSET_TYPE_STX "stx")

;; Data Variables
(define-data-var contract-version (string-ascii 10) "0.1.0")
(define-data-var total-portfolios uint u0)

;; Data Maps
;; Simple portfolio registry
(define-map user-portfolios 
    {user: principal, portfolio-id: uint}
    {
        name: (string-utf8 100),
        created-at: uint,
        updated-at: uint,
        is-active: bool
    }
)

;; Portfolio counter per user
(define-map user-portfolio-count 
    principal 
    uint
)

;; Simple holdings tracking
(define-map portfolio-holdings 
    {user: principal, portfolio-id: uint, holding-id: uint}
    {
        asset-type: (string-ascii 20),
        asset-symbol: (string-ascii 10),
        quantity: uint,
        added-at: uint
    }
)

;; Holding counter per portfolio
(define-map portfolio-holding-count 
    {user: principal, portfolio-id: uint}
    uint
)

;; Private Functions
(define-private (is-contract-owner)
    (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (validate-portfolio-name (name (string-utf8 100)))
    (and 
        (>= (len name) u1)
        (<= (len name) u100)
    )
)

(define-private (validate-asset-type (asset-type (string-ascii 20)))
    (or 
        (is-eq asset-type ASSET_TYPE_BTC)
        (is-eq asset-type ASSET_TYPE_STX)
    )
)

(define-private (portfolio-exists (user principal) (portfolio-id uint))
    (is-some (map-get? user-portfolios {user: user, portfolio-id: portfolio-id}))
)

(define-private (increment-user-portfolio-count (user principal))
    (let ((current-count (default-to u0 (map-get? user-portfolio-count user))))
        (map-set user-portfolio-count user (+ current-count u1))
        (ok true)
    )
)

(define-private (increment-portfolio-holding-count (user principal) (portfolio-id uint))
    (let ((current-count (default-to u0 (map-get? portfolio-holding-count {user: user, portfolio-id: portfolio-id}))))
        (map-set portfolio-holding-count {user: user, portfolio-id: portfolio-id} (+ current-count u1))
        (ok true)
    )
)

;; Public Functions

;; Create a new portfolio
(define-public (create-portfolio (name (string-utf8 100)))
    (let ((portfolio-id (+ (default-to u0 (map-get? user-portfolio-count tx-sender)) u1)))
        (begin
            ;; Validate inputs
            (asserts! (validate-portfolio-name name) ERR_INVALID_PORTFOLIO_NAME)
            
            ;; Create portfolio
            (map-set user-portfolios 
                {user: tx-sender, portfolio-id: portfolio-id}
                {
                    name: name,
                    created-at: block-height,
                    updated-at: block-height,
                    is-active: true
                }
            )
            
            ;; Update counters
            (unwrap-panic (increment-user-portfolio-count tx-sender))
            (var-set total-portfolios (+ (var-get total-portfolios) u1))
            
            (ok portfolio-id)
        )
    )
)

;; Add a holding to portfolio
(define-public (add-holding 
    (portfolio-id uint)
    (asset-type (string-ascii 20))
    (asset-symbol (string-ascii 10))
    (quantity uint)
)
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id})
          (holding-id (+ (default-to u0 (map-get? portfolio-holding-count portfolio-key)) u1)))
        (begin
            ;; Validate inputs
            (asserts! (portfolio-exists tx-sender portfolio-id) ERR_PORTFOLIO_NOT_FOUND)
            (asserts! (validate-asset-type asset-type) ERR_UNAUTHORIZED)
            (asserts! (> quantity u0) ERR_INVALID_QUANTITY)
            
            ;; Create holding
            (map-set portfolio-holdings 
                {user: tx-sender, portfolio-id: portfolio-id, holding-id: holding-id}
                {
                    asset-type: asset-type,
                    asset-symbol: asset-symbol,
                    quantity: quantity,
                    added-at: block-height
                }
            )
            
            ;; Update portfolio timestamp
            (match (map-get? user-portfolios portfolio-key)
                portfolio-data
                (map-set user-portfolios portfolio-key
                    (merge portfolio-data {updated-at: block-height})
                )
                false
            )
            
            ;; Update counters
            (unwrap-panic (increment-portfolio-holding-count tx-sender portfolio-id))
            
            (ok holding-id)
        )
    )
)

;; Update portfolio name
(define-public (update-portfolio-name 
    (portfolio-id uint)
    (new-name (string-utf8 100))
)
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id}))
        (match (map-get? user-portfolios portfolio-key)
            portfolio-data
            (begin
                (asserts! (validate-portfolio-name new-name) ERR_INVALID_PORTFOLIO_NAME)
                (map-set user-portfolios portfolio-key
                    (merge portfolio-data {
                        name: new-name,
                        updated-at: block-height
                    })
                )
                (ok true)
            )
            ERR_PORTFOLIO_NOT_FOUND
        )
    )
)

;; Delete portfolio (hard delete)
(define-public (delete-portfolio (portfolio-id uint))
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id}))
        (begin
            (asserts! (portfolio-exists tx-sender portfolio-id) ERR_PORTFOLIO_NOT_FOUND)
            (map-delete user-portfolios portfolio-key)
            (ok true)
        )
    )
)

;; Read-only Functions

;; Get portfolio details
(define-read-only (get-portfolio (user principal) (portfolio-id uint))
    (map-get? user-portfolios {user: user, portfolio-id: portfolio-id})
)

;; Get holding details
(define-read-only (get-holding 
    (user principal) 
    (portfolio-id uint) 
    (holding-id uint)
)
    (map-get? portfolio-holdings {user: user, portfolio-id: portfolio-id, holding-id: holding-id})
)

;; Get user's portfolio count
(define-read-only (get-user-portfolio-count (user principal))
    (default-to u0 (map-get? user-portfolio-count user))
)

;; Get portfolio holding count
(define-read-only (get-portfolio-holding-count (user principal) (portfolio-id uint))
    (default-to u0 (map-get? portfolio-holding-count {user: user, portfolio-id: portfolio-id}))
)

;; Get contract statistics
(define-read-only (get-contract-stats)
    {
        version: (var-get contract-version),
        total-portfolios: (var-get total-portfolios),
        contract-owner: CONTRACT_OWNER
    }
)

;; Get supported asset types
(define-read-only (get-supported-asset-types)
    {
        btc: ASSET_TYPE_BTC,
        stx: ASSET_TYPE_STX
    }
)