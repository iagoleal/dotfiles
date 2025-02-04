;;; Run a file or project.
;;; This is particularly useful for game engines/frmaeworks such as love2d or tcod.

(local ed (require :editor))

(fn love-runner []
  (if (ed.directory? "src")
    "!love --fused src"
    "!love --fused ."))

(fn python-runner []
  (if (ed.filereadable? "__main__.py")
    "!python ."
    "!python %"))

(local command
  {:python python-runner
   :lua    love-runner
   :fennel love-runner})

(fn run [?ft]
  "Execute/run current project for a filetype."
  (let [ft (or ?ft vim.bo.filetype)
        runner (. command ft)]
    (vim.cmd "write") ; save file
    (match (type runner)
      :string   (vim.cmd runner)
      :function (vim.cmd (runner))
      _         (ed.echowarn (.. "No runner found for filetype " ft)))))

{: run}
