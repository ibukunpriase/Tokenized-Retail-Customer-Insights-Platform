;; Preference Analysis Contract
;; Identifies consumer interests

(define-data-var admin principal tx-sender)

;; Map to store consumer preference categories
(define-map consumer-preferences
  { consumer: principal, category: (string-utf8 50) }
  {
    interest-level: uint, ;; 0-100 scale
    last-updated: uint
  }
)

;; Public function to update a consumer's preference for a category
(define-public (update-preference
  (consumer principal)
  (category (string-utf8 50))
  (interest-level uint))
  (begin
    ;; Only admin or the consumer themselves can update preferences
    (asserts! (or (is-eq tx-sender (var-get admin)) (is-eq tx-sender consumer)) (err u1))
    ;; Interest level must be between 0 and 100
    (asserts! (<= interest-level u100) (err u2))

    (map-set consumer-preferences
      { consumer: consumer, category: category }
      {
        interest-level: interest-level,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

;; Read-only function to get a consumer's interest level in a category
(define-read-only (get-interest-level (consumer principal) (category (string-utf8 50)))
  (match (map-get? consumer-preferences { consumer: consumer, category: category })
    preference (ok (get interest-level preference))
    (ok u0) ;; Default to 0 if not set
  )
)

;; Read-only function to check if a consumer has high interest in a category
(define-read-only (has-high-interest (consumer principal) (category (string-utf8 50)) (threshold uint))
  (match (map-get? consumer-preferences { consumer: consumer, category: category })
    preference (ok (>= (get interest-level preference) threshold))
    (ok false) ;; Default to false if not set
  )
)
