(local {: api} (require :editor))

(import-macros {: def-command
                : restoring-cursor}
               :macros)

(local fmt string.format)

;;;----------------------------------------------------------------------------
;;; Constants and parameters
;;;----------------------------------------------------------------------------

(local bu-limit 8.55)

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

(fn build#simple-transaction [cat payer _amount name]
  (let [amount (tonumber _amount)]
    [(fmt "%s * %s"                  (today!) (or name "???"))
     (fmt "  %s             R$% .2f" cat amount)
     (fmt "  %s             R$% .2f" payer (- amount))]))

(fn build#split-transaction [cat payer amount name]
  [(fmt "%s * %s ; split:ivani"    (today!) (or name "???"))
   (fmt "  %s             R$% .2f" cat (/ amount 2))
   (fmt "  person:ivani   R$% .2f" (/ amount 2))
   (fmt "  ; payer")
   (fmt "  %s             R$% .2f" payer (- amount))])

;;;----------------------------------------------------------------------------
;;; Commands and Options
;;;----------------------------------------------------------------------------

(api.buf_create_user_command 0 :Bus
  (fn [{: fargs}]
    (api.put (build#bus-transaction fargs) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(vim.tbl_keys bus-prices)})

(api.buf_create_user_command 0 :SplitIvani
  (fn [{: fargs}]
    (api.put (build#split-transaction (table.unpack fargs)) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(do hl-accounts)})

(api.buf_create_user_command 0 :AddTransaction
  (fn [{: fargs}]
    (api.put (build#simple-transaction (table.unpack fargs)) :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs :+
   :complete #(do hl-accounts)})

(api.buf_create_user_command 0 :Uber
  (fn [{: args}]
    (api.put (build#simple-transaction "expenses:transport:uber"
                                       "card:btg"
                                       (tonumber args)
                                       "Uber")
             :l true true)
    (restoring-cursor (vim.cmd "'{,'}LedgerAlign")))
  {:nargs 1})

(set vim.wo.foldmethod :syntax)
