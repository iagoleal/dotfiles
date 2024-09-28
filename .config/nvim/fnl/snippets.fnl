(local {: current-line
        : pumvisible?
        : feedkeys} (require :editor))

(fn defaultable [t]
  (setmetatable t
    {:__index (fn [self _] (rawget self :*))}))

(local snippets
  (defaultable
    {:*
      {:date #(os.date "%Y-%m-%d")
       :uuid #(vim.trim (vim.fn.system :uuidgen))}
     :lua
      {:f "local function ${1:name}(${2})\n  $0\nend"
       :m "function ${1:M}.${2:name}(${3})\n  $0\nend"}}))

(fn expand []
  (let [[lnum col] (vim.api.nvim_win_get_cursor 0)
        line       (current-line)
        word       (vim.fn.matchstr line "\\w\\+\\%.c")
        snippet    (?. snippets vim.bo.filetype word)]
    (when snippet
      (vim.api.nvim_buf_set_text 0
                                 (- lnum 1)
                                 (- col (length word))
                                 (- lnum 1)
                                 col
                                 {})
      (vim.snippet.expand (match (type snippet)
                            :function (snippet)
                            _         snippet)))))


;; Export
{: expand
 : snippets}
