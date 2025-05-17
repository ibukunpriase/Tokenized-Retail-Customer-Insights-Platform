;; Retailer Verification Contract
;; Validates merchants on the platform

(define-data-var admin principal tx-sender)

;; Map to store verified retailers
(define-map verified-retailers principal
  {
    name: (string-utf8 100),
    website: (string-utf8 100),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a retailer (can only be called by the admin)
(define-public (register-retailer (retailer principal) (name (string-utf8 100)) (website (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can register retailers
    (asserts! (is-none (map-get? verified-retailers retailer)) (err u2)) ;; Retailer not already registered

    (map-set verified-retailers retailer
      {
        name: name,
        website: website,
        verified: true,
        verification-date: block-height
      }
    )
    (ok true)
  )
)

;; Public function to check if a retailer is verified
(define-read-only (is-verified-retailer (retailer principal))
  (match (map-get? verified-retailers retailer)
    retailer-data (ok (get verified retailer-data))
    (ok false)
  )
)

;; Public function to get retailer details
(define-read-only (get-retailer-details (retailer principal))
  (map-get? verified-retailers retailer)
)

;; Public function to update admin (only current admin can call)
(define-public (update-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3)) ;; Only current admin can update
    (var-set admin new-admin)
    (ok true)
  )
)
