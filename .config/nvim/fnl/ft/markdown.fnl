;; Utilities for working with Markdown files
(local M {})

;;; Set a default value to a variable
(macro default-value! [variable default]
  `(set-forcibly! ,variable
                  (if (= ,variable nil)
                      ,default
                      ,variable)))


(fn strip-atx [str]
  "Remove any ATX markup to turn argument into a common line."
  (let [(header title) (str:match "^(%#*)%s*([^%s].*)%s*$")]
    (values title (or header ""))))

(fn atx-header? [str]
  "Check if argument string is a line with ATX style header markup."
    (let [(_ len) (strip-atx str)]
      (> len 0)))

(fn setext-decoration? [str]
  "Check if argument string is a setext style header markup."
  (or (str:match "^%=+$")
      (str:match "^%-+$")))

;;;
;;; Buffer manipulation methods
;;;

(fn M.to-setext-header [depth line-number]
  "Convert a line in the buffer to a markdown Setext style header."
  (let [header-char       (match depth
                           1 "="
                           2 "-"
                           _ (error "Setext header is only defined for levels 1 and 2."))
        line              (vim.fn.line line-number)
        text              (strip-atx (vim.fn.getline line))
        next-text         (vim.fn.getline (+ line 1))
        header-decoration (string.rep header-char (length text))]
    (vim.fn.setline line text)              ; Current line becomes text with no headers
    (if (or (setext-decoration? next-text))  ; Renormalize following line if it is part of the header
      (vim.fn.setline (+ line 1) header-decoration)
      (vim.fn.append  line       header-decoration))))

(fn M.to-atx-header [depth line header-char]
  "Convert a line in the buffer to a markdown ATX style header."
  (default-value! header-char "#")     ; needed because pandoc lhaskell uses "=" for compatibility with C preprocessor
  (let [line       (vim.fn.line ".")
        text       (strip-atx (vim.fn.getline line))
        next-text  (vim.fn.getline (+ line 1))
        new-text   (table.concat [(string.rep header-char depth) text]
                                 " ")]
    (vim.fn.setline line new-text)         ; Current line becomes text with correct headers
    (when (setext-decoration? next-text)   ; Delete any setext header
      (vim.fn.deletebufline "%" (+ line 1)))))

(fn M.clean-md-header [line]
  "Convert a line in the buffer to have no header markup."
  (let [line       (vim.fn.line ".")
        text       (strip-atx (vim.fn.getline line))
        next-text  (vim.fn.getline (+ line 1))]
    (vim.fn.setline line text)             ; Current line becomes text with no headers
    (when (setext-decoration? next-text)   ; Delete any setext header
      (vim.fn.deletebufline "%" (+ line 1)))))

M
