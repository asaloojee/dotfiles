return {
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Use the python from virtual environment if available, otherwise system python
      local python_path = vim.fn.getcwd() .. "/.venv/bin/python"
      if vim.fn.filereadable(python_path) == 0 then
        python_path = vim.fn.exepath("python3") or vim.fn.exepath("python")
      end

      require("dap-python").setup(python_path)

      -- Add configurations for debugging tests
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        name = "Debug Python File",
        program = "${file}",
        console = "integratedTerminal",
      })

      -- Key mappings for Python debugging
      local keymap = vim.keymap.set
      keymap("n", "<leader>dpr", function()
        require("dap-python").test_method()
      end, { desc = "Debug Python Test Method" })

      keymap("n", "<leader>dpc", function()
        require("dap-python").test_class()
      end, { desc = "Debug Python Test Class" })

      -- Enable text wrapping in DAP REPL after it opens
      local dap = require("dap")
      dap.listeners.after.event_initialized["enable_wrap"] = function()
        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
            if ft == "dap-repl" or ft:match("^dapui_") then
              vim.api.nvim_set_option_value("wrap", true, { win = win })
              vim.api.nvim_set_option_value("linebreak", true, { win = win })
            end
          end
        end, 200)
      end
    end,
  },
}
