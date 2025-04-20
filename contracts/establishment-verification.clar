;; Establishment Verification Contract
;; Validates legitimate food service operations

(define-data-var admin principal tx-sender)

;; Data map to store verified establishments
(define-map establishments
  { id: uint }
  {
    name: (string-utf8 100),
    address: (string-utf8 200),
    owner: principal,
    license-number: (string-utf8 50),
    is-verified: bool,
    registration-date: uint
  }
)

;; Counter for establishment IDs
(define-data-var establishment-id-counter uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new establishment
(define-public (register-establishment
                (name (string-utf8 100))
                (address (string-utf8 200))
                (license-number (string-utf8 50)))
  (let ((new-id (+ (var-get establishment-id-counter) u1)))
    (begin
      (asserts! (is-admin) (err u403))
      (map-set establishments
        { id: new-id }
        {
          name: name,
          address: address,
          owner: tx-sender,
          license-number: license-number,
          is-verified: false,
          registration-date: block-height
        }
      )
      (var-set establishment-id-counter new-id)
      (ok new-id)
    )
  )
)

;; Verify an establishment
(define-public (verify-establishment (id uint))
  (begin
    (asserts! (is-admin) (err u403))
    (match (map-get? establishments { id: id })
      establishment (begin
        (map-set establishments
          { id: id }
          (merge establishment { is-verified: true })
        )
        (ok true)
      )
      (err u404)
    )
  )
)

;; Get establishment details
(define-read-only (get-establishment (id uint))
  (map-get? establishments { id: id })
)

;; Check if establishment is verified
(define-read-only (is-establishment-verified (id uint))
  (match (map-get? establishments { id: id })
    establishment (get is-verified establishment)
    false
  )
)

;; Get total number of establishments
(define-read-only (get-establishment-count)
  (var-get establishment-id-counter)
)
