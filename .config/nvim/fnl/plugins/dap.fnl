(local dap (require :dap))
(local dapui (require :dapui))

(local {: keymap} (require :editor))


;; Automatically open dapui on start/end of debugging
(set dap.listeners.before.attach.dapui_config dapui.open)
(set dap.listeners.before.launch.dapui_config dapui.open)

(set dap.listeners.before.event_terminated.dapui_config dapui.close)
(set dap.listeners.before.event_exited.dapui_config dapui.close)


;; Mappings

(keymap :n "<leader>bc" dap.continue)
(keymap :n "<leader>bb" dap.toggle_breakpoint)
(keymap :n "<leader>bl" #(dap.set_breakpoint nil
                                             nil
                                             (vim.fn.input "Log point: ")))
