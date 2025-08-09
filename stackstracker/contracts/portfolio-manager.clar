;; StacksTracker Portfolio Manager Contract (Stage 2 - Enhanced Features)
;; Enhanced portfolio tracking with analytics, permissions, and extended asset support

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_PORTFOLIO_NOT_FOUND (err u301))
(define-constant ERR_PORTFOLIO_ALREADY_EXISTS (err u302))
(define-constant ERR_INVALID_PORTFOLIO_NAME (err u303))
(define-constant ERR_INVALID_VISIBILITY (err u304))
(define-constant ERR_HOLDING_NOT_FOUND (err u305))
(define-constant ERR_INVALID_ASSET_TYPE (err u306))
(define-constant ERR_INVALID_QUANTITY (err u307))
(define-constant ERR_PORTFOLIO_LIMIT_REACHED (err u310))

;; Asset type constants
(define-constant ASSET_TYPE_BTC "btc")
(define-constant ASSET_TYPE_STX "stx")
(define-constant ASSET_TYPE_SIP010 "sip010")

;; Visibility constants
(define-constant VISIBILITY_PRIVATE u0)
(define-constant VISIBILITY_PUBLIC u1)
(define-constant VISIBILITY_FRIENDS u2)

;; Portfolio limits
(define-constant FREE_TIER_PORTFOLIO_LIMIT u3)
(define-constant PRO_TIER_PORTFOLIO_LIMIT u20)

;; Data Variables
(define-data-var contract-version (string-ascii 10) "0.2.0")
(define-data-var total-portfolios uint u0)
(define-data-var total-holdings uint u0)

;; Data Maps
;; Enhanced portfolio registry
(define-map user-portfolios 
    {user: principal, portfolio-id: uint}
    {
        name: (string-utf8 100),
        description: (optional (string-utf8 500)),
        visibility: uint,
        created-at: uint,
        updated-at: uint,
        total-holdings: uint,
        total-value-usd: uint,
        is-active: bool
    }
)

;; Portfolio counter per user
(define-map user-portfolio-count 
    principal 
    uint
)

;; Enhanced portfolio holdings with cost basis
(define-map portfolio-holdings 
    {user: principal, portfolio-id: uint, holding-id: uint}
    {
        asset-type: (string-ascii 20),
        asset-id: (string-ascii 100),
        asset-symbol: (string-ascii 10),
        quantity: uint,
        cost-basis-usd: uint,
        acquired-at: uint,
        updated-at: uint,
        notes: (optional (string-utf8 200))
    }
)

;; Holding counter per portfolio
(define-map portfolio-holding-count 
    {user: principal, portfolio-id: uint}
    uint
)

;; Portfolio sharing permissions
(define-map portfolio-permissions 
    {owner: principal, portfolio-id: uint, viewer: principal}
    {
        permission-level: uint,
        granted-at: uint,
        granted-by: principal
    }
)

;; Portfolio analytics cache
(define-map portfolio-analytics 
    {user: principal, portfolio-id: uint}
    {
        last-calculated: uint,
        total-invested-usd: uint,
        current-value-usd: uint,
        unrealized-pnl-usd: int,
        total-transactions: uint,
        performance-24h: int
    }
)

;; User subscription tiers (simplified)
(define-map user-subscription-tier 
    principal 
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
        (is-eq asset-type ASSET_TYPE_SIP010)
    )
)

(define-private (validate-visibility (visibility uint))
    (<= visibility u2)
)

(define-private (get-user-portfolio-limit (user principal))
    (let ((tier (default-to u0 (map-get? user-subscription-tier user))))
        (if (is-eq tier u1)
            PRO_TIER_PORTFOLIO_LIMIT
            FREE_TIER_PORTFOLIO_LIMIT
        )
    )
)

(define-private (can-create-portfolio (user principal))
    (let ((current-count (default-to u0 (map-get? user-portfolio-count user)))
          (limit (get-user-portfolio-limit user)))
        (< current-count limit)
    )
)

(define-private (portfolio-exists (user principal) (portfolio-id uint))
    (is-some (map-get? user-portfolios {user: user, portfolio-id: portfolio-id}))
)

(define-private (can-access-portfolio (owner principal) (portfolio-id uint) (viewer principal))
    (or 
        (is-eq owner viewer)
        (is-contract-owner)
        (match (map-get? user-portfolios {user: owner, portfolio-id: portfolio-id})
            portfolio-data 
            (or 
                (is-eq (get visibility portfolio-data) VISIBILITY_PUBLIC)
                (is-some (map-get? portfolio-permissions {owner: owner, portfolio-id: portfolio-id, viewer: viewer}))
            )
            false
        )
    )
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

(define-private (update-portfolio-analytics (user principal) (portfolio-id uint) (cost-basis uint))
    (let ((analytics-key {user: user, portfolio-id: portfolio-id}))
        (match (map-get? portfolio-analytics analytics-key)
            existing-analytics
            (map-set portfolio-analytics analytics-key
                (merge existing-analytics {
                    total-invested-usd: (+ (get total-invested-usd existing-analytics) cost-basis),
                    total-transactions: (+ (get total-transactions existing-analytics) u1),
                    last-calculated: block-height
                })
            )
            (map-set portfolio-analytics analytics-key
                {
                    last-calculated: block-height,
                    total-invested-usd: cost-basis,
                    current-value-usd: u0,
                    unrealized-pnl-usd: 0,
                    total-transactions: u1,
                    performance-24h: 0
                }
            )
        )
        (ok true)
    )
)

;; Public Functions

;; Create a new portfolio
(define-public (create-portfolio 
    (name (string-utf8 100)) 
    (description (optional (string-utf8 500)))
    (visibility uint)
)
    (let ((portfolio-id (+ (default-to u0 (map-get? user-portfolio-count tx-sender)) u1)))
        (begin
            ;; Validate inputs
            (asserts! (validate-portfolio-name name) ERR_INVALID_PORTFOLIO_NAME)
            (asserts! (validate-visibility visibility) ERR_INVALID_VISIBILITY)
            (asserts! (can-create-portfolio tx-sender) ERR_PORTFOLIO_LIMIT_REACHED)
            
            ;; Create portfolio
            (map-set user-portfolios 
                {user: tx-sender, portfolio-id: portfolio-id}
                {
                    name: name,
                    description: description,
                    visibility: visibility,
                    created-at: block-height,
                    updated-at: block-height,
                    total-holdings: u0,
                    total-value-usd: u0,
                    is-active: true
                }
            )
            
            ;; Initialize analytics
            (unwrap-panic (update-portfolio-analytics tx-sender portfolio-id u0))
            
            ;; Update counters
            (unwrap-panic (increment-user-portfolio-count tx-sender))
            (var-set total-portfolios (+ (var-get total-portfolios) u1))
            
            (ok portfolio-id)
        )
    )
)

;; Update portfolio details
(define-public (update-portfolio 
    (portfolio-id uint)
    (new-name (optional (string-utf8 100)))
    (new-description (optional (string-utf8 500)))
    (new-visibility (optional uint))
)
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id}))
        (match (map-get? user-portfolios portfolio-key)
            portfolio-data
            (let ((updated-portfolio 
                {
                    name: (default-to (get name portfolio-data) new-name),
                    description: (if (is-some new-description) new-description (get description portfolio-data)),
                    visibility: (default-to (get visibility portfolio-data) new-visibility),
                    created-at: (get created-at portfolio-data),
                    updated-at: block-height,
                    total-holdings: (get total-holdings portfolio-data),
                    total-value-usd: (get total-value-usd portfolio-data),
                    is-active: (get is-active portfolio-data)
                }))
                (begin
                    ;; Validate new values if provided
                    (match new-name 
                        some-name (asserts! (validate-portfolio-name some-name) ERR_INVALID_PORTFOLIO_NAME)
                        true
                    )
                    (match new-visibility 
                        some-visibility (asserts! (validate-visibility some-visibility) ERR_INVALID_VISIBILITY)
                        true
                    )
                    
                    ;; Update portfolio
                    (map-set user-portfolios portfolio-key updated-portfolio)
                    (ok true)
                )
            )
            ERR_PORTFOLIO_NOT_FOUND
        )
    )
)

;; Add or update a holding in portfolio
(define-public (add-holding 
    (portfolio-id uint)
    (asset-type (string-ascii 20))
    (asset-id (string-ascii 100))
    (asset-symbol (string-ascii 10))
    (quantity uint)
    (cost-basis-usd uint)
    (notes (optional (string-utf8 200)))
)
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id})
          (holding-id (+ (default-to u0 (map-get? portfolio-holding-count portfolio-key)) u1)))
        (begin
            ;; Validate inputs
            (asserts! (portfolio-exists tx-sender portfolio-id) ERR_PORTFOLIO_NOT_FOUND)
            (asserts! (validate-asset-type asset-type) ERR_INVALID_ASSET_TYPE)
            (asserts! (> quantity u0) ERR_INVALID_QUANTITY)
            
            ;; Create holding
            (map-set portfolio-holdings 
                {user: tx-sender, portfolio-id: portfolio-id, holding-id: holding-id}
                {
                    asset-type: asset-type,
                    asset-id: asset-id,
                    asset-symbol: asset-symbol,
                    quantity: quantity,
                    cost-basis-usd: cost-basis-usd,
                    acquired-at: block-height,
                    updated-at: block-height,
                    notes: notes
                }
            )
            
            ;; Update portfolio totals
            (match (map-get? user-portfolios portfolio-key)
                portfolio-data
                (map-set user-portfolios portfolio-key
                    (merge portfolio-data {
                        total-holdings: (+ (get total-holdings portfolio-data) u1),
                        updated-at: block-height
                    })
                )
                false
            )
            
            ;; Update analytics
            (unwrap-panic (update-portfolio-analytics tx-sender portfolio-id cost-basis-usd))
            
            ;; Update counters
            (unwrap-panic (increment-portfolio-holding-count tx-sender portfolio-id))
            (var-set total-holdings (+ (var-get total-holdings) u1))
            
            (ok holding-id)
        )
    )
)

;; Remove a holding from portfolio
(define-public (remove-holding 
    (portfolio-id uint)
    (holding-id uint)
)
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id})
          (holding-key {user: tx-sender, portfolio-id: portfolio-id, holding-id: holding-id}))
        (begin
            (asserts! (portfolio-exists tx-sender portfolio-id) ERR_PORTFOLIO_NOT_FOUND)
            (asserts! (is-some (map-get? portfolio-holdings holding-key)) ERR_HOLDING_NOT_FOUND)
            
            ;; Remove holding
            (map-delete portfolio-holdings holding-key)
            
            ;; Update portfolio totals
            (match (map-get? user-portfolios portfolio-key)
                portfolio-data
                (map-set user-portfolios portfolio-key
                    (merge portfolio-data {
                        total-holdings: (if (> (get total-holdings portfolio-data) u0)
                            (- (get total-holdings portfolio-data) u1)
                            u0
                        ),
                        updated-at: block-height
                    })
                )
                false
            )
            
            (var-set total-holdings (if (> (var-get total-holdings) u0)
                (- (var-get total-holdings) u1)
                u0
            ))
            
            (ok true)
        )
    )
)

;; Grant portfolio access to another user
(define-public (grant-portfolio-access 
    (portfolio-id uint)
    (viewer principal)
    (permission-level uint)
)
    (begin
        (asserts! (portfolio-exists tx-sender portfolio-id) ERR_PORTFOLIO_NOT_FOUND)
        (asserts! (<= permission-level u2) ERR_UNAUTHORIZED)
        
        (map-set portfolio-permissions 
            {owner: tx-sender, portfolio-id: portfolio-id, viewer: viewer}
            {
                permission-level: permission-level,
                granted-at: block-height,
                granted-by: tx-sender
            }
        )
        
        (ok true)
    )
)

;; Revoke portfolio access
(define-public (revoke-portfolio-access 
    (portfolio-id uint)
    (viewer principal)
)
    (begin
        (asserts! (portfolio-exists tx-sender portfolio-id) ERR_PORTFOLIO_NOT_FOUND)
        
        (map-delete portfolio-permissions 
            {owner: tx-sender, portfolio-id: portfolio-id, viewer: viewer})
        
        (ok true)
    )
)

;; Set user subscription tier (admin only)
(define-public (set-user-subscription-tier (user principal) (tier uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (map-set user-subscription-tier user tier)
        (ok true)
    )
)

;; Deactivate portfolio
(define-public (deactivate-portfolio (portfolio-id uint))
    (let ((portfolio-key {user: tx-sender, portfolio-id: portfolio-id}))
        (match (map-get? user-portfolios portfolio-key)
            portfolio-data
            (begin
                (map-set user-portfolios portfolio-key
                    (merge portfolio-data {
                        is-active: false,
                        updated-at: block-height
                    })
                )
                (ok true)
            )
            ERR_PORTFOLIO_NOT_FOUND
        )
    )
)

;; Read-only Functions

;; Get portfolio details
(define-read-only (get-portfolio (user principal) (portfolio-id uint))
    (if (can-access-portfolio user portfolio-id tx-sender)
        (map-get? user-portfolios {user: user, portfolio-id: portfolio-id})
        none
    )
)

;; Get holding details
(define-read-only (get-holding-details 
    (user principal) 
    (portfolio-id uint) 
    (holding-id uint)
)
    (if (can-access-portfolio user portfolio-id tx-sender)
        (map-get? portfolio-holdings {user: user, portfolio-id: portfolio-id, holding-id: holding-id})
        none
    )
)

;; Get user's portfolio count
(define-read-only (get-user-portfolio-count (user principal))
    (default-to u0 (map-get? user-portfolio-count user))
)

;; Get user's portfolio limit
(define-read-only (get-user-portfolio-limit-check (user principal))
    (get-user-portfolio-limit user)
)

;; Get portfolio analytics
(define-read-only (get-portfolio-analytics (user principal) (portfolio-id uint))
    (if (can-access-portfolio user portfolio-id tx-sender)
        (map-get? portfolio-analytics {user: user, portfolio-id: portfolio-id})
        none
    )
)

;; Check portfolio access
(define-read-only (check-portfolio-access (owner principal) (portfolio-id uint) (viewer principal))
    (can-access-portfolio owner portfolio-id viewer)
)

;; Get contract statistics
(define-read-only (get-contract-stats)
    {
        version: (var-get contract-version),
        total-portfolios: (var-get total-portfolios),
        total-holdings: (var-get total-holdings),
        contract-owner: CONTRACT_OWNER
    }
)

;; Get supported asset types
(define-read-only (get-supported-asset-types)
    {
        btc: ASSET_TYPE_BTC,
        stx: ASSET_TYPE_STX,
        sip010: ASSET_TYPE_SIP010
    }
)

;; Get visibility options
(define-read-only (get-visibility-options)
    {
        private: VISIBILITY_PRIVATE,
        public: VISIBILITY_PUBLIC,
        friends: VISIBILITY_FRIENDS
    }
)

;; Get subscription limits
(define-read-only (get-subscription-limits)
    {
        free: FREE_TIER_PORTFOLIO_LIMIT,
        pro: PRO_TIER_PORTFOLIO_LIMIT
    }
)