(local {: api} (require :editor))

(local {: tupdate!} (require :core))

(import-macros {: def-command
                : restoring-cursor}
               :macros)

(local fmt string.format)

;; Ler https://zignar.net/2022/09/02/a-tree-sitting-in-your-editor/

;;;----------------------------------------------------------------------------
;;; Constants and parameters
;;;----------------------------------------------------------------------------

(local bu-limit 8.55)
(local default-payment "assets:wise:usd")

(local bus-prices
  {:110   13.10
   :535   13.10
   :423   13.10
   ; Niterói <-> Rio
   :755   11.70
   :775   11.70
   :740   11.70
   :760   11.70
   :barca  7.70
   ; SG <-> Niterói
   :409    5.85
   :408    5.85
   :403    5.85
   :532    5.85
   ; Rio de Janeiro
   :metro  5.00
   :vlt    4.30
   :brt    4.30})

(local templates
  {:expenses/bus "  expenses:transport:urban  R$% .2f ; linha:%s"
   :riocard      "  assets:riocard  R$% .2f"})

(local hl-accounts
  (let [stdout (. (: (vim.system ["hledger" "accounts"]) :wait) :stdout)]
    (vim.split stdout "\n"  { :trimempty true})))

;;;----------------------------------------------------------------------------
;;; Methods
;;;----------------------------------------------------------------------------

(fn today! []
  "Use today's date or another previously specified."
  (or vim.b.posting_date (os.date "%Y-%m-%d")))

(fn bus->expense [bus total]
  "Build the expense posting for a RJ bus."
  (let [[line price] (match (type bus)
                      :string [bus   (or (. bus-prices bus)
                                         math.huge)]
                      :number ["???" bus])
        payed (math.min price
                        (- bu-limit total))]
    ; Formated posting and payed running total
    (values (templates.expenses/bus:format payed line)
            (+ total payed))))

(fn build#bus-transaction [buses]
  (let [transaction []
        tput        #(table.insert transaction $...)]
    ;; Accumulate total payed
    (var (total expense) 0)
    ;; Build table
    (tput (..  (today!) " * Onibus"))
    (each [_ bus (ipairs buses)]
      (set (expense total) (bus->expense bus total))
      (tput expense))
    (tput (templates.riocard:format (- total)))
    transaction))

(fn build#simple-transaction [cat _amount payer name]
  (let [amount (tonumber _amount)]
    [(fmt "%s * %s"                  (today!) (or name "???"))
     (fmt "  %s             % .2f USD" cat amount)
     (fmt "  %s             % .2f USD" payer (- amount))]))

(fn build#split-transaction [who cat _amount payer name]
  (let [amount      (tonumber _amount)
        per/capita  (/ amount (+ 1 (length who)))
        tags        (table.concat (icollect [_ p (ipairs who)]
                                    (fmt "split:%s" p))
                                  ", ")
        transaction []
        tput        #(table.insert transaction $...)]
    (tput (fmt "%s * %s %s"    (today!) (or name "???") (if (= tags "") tags (.. "; " tags))))
    (tput (fmt "  %s             R$% .2f" cat per/capita))
    (each [_ p (ipairs who)]
      (tput (fmt "  person:%s   R$% .2f" p per/capita)))
    (tput (fmt "  ; payer"))
    (tput (fmt "  %s             R$% .2f" payer (- amount)))
    transaction))

;;;----------------------------------------------------------------------------
;;; Commands and Options
;;;----------------------------------------------------------------------------

(set vim.wo.foldmethod :syntax)

(api.buf-create-user-command 0 :AddTransaction
  (fn [{: fargs}]
    (tupdate! fargs 2 #(or $1 default-payment))
    (api.put (build#simple-transaction (table.unpack fargs)) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(do hl-accounts)})

(api.buf-create-user-command 0 :SplitIvani
  (fn [{: fargs}]
    (tupdate! fargs 3 #(or $1 default-payment))
    (vim.print fargs)
    (api.put (build#split-transaction ["ivani"] (table.unpack fargs)) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(do hl-accounts)})

(api.buf-create-user-command 0 :Split3
  (fn [{: fargs}]
    (tupdate! fargs 2 #(or $1 default-payment))
    (api.put (build#split-transaction ["ivani" "gi"] (table.unpack fargs)) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(do hl-accounts)})

(api.buf-create-user-command 0 :Bus
  (fn [{: fargs}]
    (api.put (build#bus-transaction fargs) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(vim.tbl-keys bus-prices)})

(api.buf-create-user-command 0 :Uber
  (fn [{: args}]
    (api.put (build#simple-transaction "expenses:transport:uber"
                                       (tonumber args)
                                       default-payment
                                       "Uber")
             :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs 1})

(api.buf-create-user-command 0 :Uber2
  (fn [{: args}]
    (api.put (build#split-transaction ["ivani"]
                                      "expenses:transport:uber"
                                      (tonumber args)
                                      default-payment
                                      "Uber")
             :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs 1})

;;;----------------------------------------------------------------------------
;;; ledger.vim
;;;----------------------------------------------------------------------------
(set vim.g.ledger_bin             :hledger)
(set vim.g.ledger_is_hledger      true)
(set vim.g.ledger_date_format     "%Y-%m-%d")
(set vim.g.ledger_align_at        60)
(set vim.g.ledger_align_commodity false)    ; Align on R$ instead of decimal dot
(set vim.g.ledger_align_last      false)
(set vim.g.ledger_commodity_sep   " ")
(set vim.g.ledger_extra_options   "--strict ordereddates")

(vim.keymap.set :n "<leader>dd"
  #(if vim.b.posting_date
       (vim.fn.ledger#transaction_date_set
         (vim.fn.line ".")
         "primary"
         (vim.fn.strptime "%Y-%m-%d" vim.b.posting_date))
       (vim.fn.ledger#transaction_date_set
         (vim.fn.line ".")
         "primary"))
  {:buffer 0
   :desc "Change transaction date to today"})

(vim.keymap.set :n "<leader>de" "<CMD>call ledger#transaction_state_toggle(line('.'), '!* ')<CR>"
  {:buffer 0
   :desc "Toggle transaction status"})

(vim.keymap.set :n "<leader>dE" "<CMD>call ledger#transaction_post_state_toggle(line('.'), ' *!')<CR>"
  {:buffer 0
   :desc "Toggle posting status"})

;; Align all posts on current paragraph (I use one transaction per paragraph)
(vim.keymap.set :n "<leader>da"
  #(restoring-cursor (vim.cmd "'{,'}LedgerAlign"))
  {:buffer 0
   :desc "Align postings on current transaction"})
