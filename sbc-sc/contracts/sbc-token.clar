
;; sbc-token
;; Sustainable Bitcoin Certificate Token Definitions and Utilities

;; constants
;; The test address that is authorized to mint sbc tokens.
;; It should be replaced by the app address.
(define-constant AUTH_CALLER_ADDRESS 'SP186MENEFRP25YP4VSPNYAW4E3ZC41XDGKRB7YCB)

;; data maps and vars
;; a map from a minted Bitcoin block to its owner address and Bitcoin amount.
(define-map minted-block-info
    {block: uint}
    {
        btc-address: (buff 40),
        bit-amount: uint,
        sbc-amount: uint
    }
)

;; a map from a Bitcoin address to the total sbc it has minted.
(define-map minted-sbc-by-user
    {btc-address: (buff 40)}
    {total-minted-sbc: uint} 
)

;; private functions
;;

;; public functions
;;

;; SIP-010 DEFINITION
;; Update to this definition when deploy on the mainnet
;; (impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
;; Use this definition on the testnet
(impl-trait 'STR8P3RD1EHA8AA37ERSSSZSWKS9T2GYQFGXNA4C.sip-010-trait-ft-standard.sip-101-trait)

(define-fungible-token sbc)
;; SIP-010 FUNCTIONS
;; Transfer from the caller to a new principal
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) (err ERR_UNAUTHORIZED))
    (if (is-some memo)
      (print memo)
      none
    )
    (ft-transfer? sbc amount from to)
  )
)

;; the human readable name of the token
(define-read-only (get-name)
  (ok "Sustainable Bitcoin Certificate")
)

;; the ticker symbol, or empty if none
(define-read-only (get-symbol)
  (ok "SBC")
)

;; the number of decimals used, e.g. 8 would mean 100_000_000 represents 1 token
;; SBC uses 8, which is the same as Bitcoin
(define-read-only (get-decimals)
  (ok u8)
)

;; the balance of the passed principal
(define-read-only (get-balance (user principal))
  (ok (ft-get-balance sbc user))
)

;; the current total supply (which does not need to be a constant)
(define-read-only (get-total-supply)
  (ok (ft-get-supply sbc))
)

;; an optional URI that represents metadata of this token
(define-read-only (get-token-uri)
  (ok (var-get tokenUri))
)

;; UTILITIES

; URI for SBC token
(define-data-var tokenUri (optional (string-utf8 256)) (some u"https://abc/sbc.json"))

;; set token URI to new value, only accessible by Auth
(define-public (set-token-uri (newUri (optional (string-utf8 256))))
  (begin
    (asserts! (is-authorized-auth) (err ERR_UNAUTHORIZED))
    (ok (var-set tokenUri newUri))
  )
)

;; mint new tokens, only accessible by Auth
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-authorized-auth) (err ERR_UNAUTHORIZED))
    (ft-mint? sbc amount recipient)
  )
)

;; mint new tokens and record data, only accessible by Auth
(define-public (mint-and-record (amount uint) (recipient principal) (btc-block uint) (btc-address (buff 40)))
  (begin
    (asserts! (is-authorized-auth) (err ERR_UNAUTHORIZED))
    (ft-mint? sbc amount recipient)
    (map-set minted-block-info {block: btc-block} {btc-address: btc-address, btc-amount: amount, sbc-amout: amount})
    (let (current-btc (get total-minted-sbc (map-get? minted-sbc-by-user {btc-address: btc-address})))
    (if current-btc)
        (map-set minted-sbc-by-user {btc-address: btc-address}, totol-minted-sbc: (+ current-btc amount))
        (map-set minted-sbc-by-user {btc-address: btc-address}, totol-minted-sbc: amount)
    )
  )
)

;; checks if caller is Authorized caller
(define-private (is-authorized-auth)
   (is-eq contract-caller AUTH_CALLER_ADDRESS)
)

;; SEND-MANY

(define-public (send-many (recipients (list 200 { to: principal, amount: uint, memo: (optional (buff 34)) })))
  (fold check-err
    (map send-token recipients)
    (ok true)
  )
)

(define-private (check-err (result (response bool uint)) (prior (response bool uint)))
  (match prior ok-value result
               err-value (err err-value)
  )
)

(define-private (send-token (recipient { to: principal, amount: uint, memo: (optional (buff 34)) }))
  (send-token-with-memo (get amount recipient) (get to recipient) (get memo recipient))
)

(define-private (send-token-with-memo (amount uint) (to principal) (memo (optional (buff 34))))
  (let
    (
      (transferOk (try! (transfer amount tx-sender to memo)))
    )
    (ok transferOk)
  )
)