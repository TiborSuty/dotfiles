return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft.python = { "ruff_format" }
      opts.formatters.ruff_format = {
        command = require("conform.util").find_executable({ ".venv/bin/ruff" }, "ruff"),
      }
    end,
  },
}
