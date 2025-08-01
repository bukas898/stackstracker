;; StacksTracker User Registry Contract - Basic user profile management
;; Part of the StacksTracker ecosystem for Bitcoin L2 portfolio tracking

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_USER_NOT_FOUND (err u201))
(define-constant ERR_USER_ALREADY_EXISTS (err u202))
(define-constant ERR_INVALID_USERNAME (err u203))
(define-constant ERR_USERNAME_TAKEN (err u204))

;; Data Variables
(define-data-var total-users uint u0)

;; Data Maps
;; Main user profiles
(define-map user-profiles 
    principal ;; Stacks address
    {
        username: (string-utf8 50),
        created-at: uint,
        profile-status: uint ;; 0=active, 1=suspended, 2=deleted
    }
)

;; Username to address mapping for uniqueness
(define-map username-registry 
    (string-utf8 50) 
    principal
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

(define-private (user-exists (user principal))
    (is-some (map-get? user-profiles user))
)

;; Public Functions

;; Create a new user profile
(define-public (create-profile (username (string-utf8 50)))
    (let ((current-block block-height))
        (begin
            ;; Validate username
            (asserts! (validate-username username) ERR_INVALID_USERNAME)
            (asserts! (is-none (map-get? username-registry username)) ERR_USERNAME_TAKEN)
            
            ;; Check if user already exists
            (asserts! (not (user-exists tx-sender)) ERR_USER_ALREADY_EXISTS)
            
            ;; Create user profile
            (map-set user-profiles tx-sender {
                username: username,
                created-at: current-block,
                profile-status: u0 ;; active
            })
            
            ;; Register username
            (map-set username-registry username tx-sender)
            
            ;; Update total users count
            (var-set total-users (+ (var-get total-users) u1))
            
            (ok true)
        )
    )
)

;; Update user profile
(define-public (update-profile (new-username (string-utf8 50)))
    (let ((current-profile (unwrap! (map-get? user-profiles tx-sender) ERR_USER_NOT_FOUND)))
        (begin
            ;; Validate new username
            (asserts! (validate-username new-username) ERR_INVALID_USERNAME)
            
            ;; Remove old username mapping
            (map-delete username-registry (get username current-profile))
            
            ;; Check if new username is available
            (asserts! (is-none (map-get? username-registry new-username)) ERR_USERNAME_TAKEN)
            
            ;; Set new username mapping
            (map-set username-registry new-username tx-sender)
            
            ;; Update profile
            (map-set user-profiles tx-sender 
                (merge current-profile {
                    username: new-username
                })
            )
            
            (ok true)
        )
    )
)

;; Update profile status (admin only)
(define-public (update-profile-status (user principal) (new-status uint))
    (begin
        (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
        (asserts! (<= new-status u2) ERR_UNAUTHORIZED)
        
        (match (map-get? user-profiles user)
            profile-data
            (begin
                (map-set user-profiles user 
                    (merge profile-data {
                        profile-status: new-status
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

;; Check if username is available
(define-read-only (is-username-available (username (string-utf8 50)))
    (is-none (map-get? username-registry username))
)

;; Get total users
(define-read-only (get-total-users)
    (var-get total-users)
)

;; Check if user exists
(define-read-only (user-exists-check (user principal))
    (user-exists user)
)
