return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Window Left" },
    { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Window Right" },
    { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Window Down" },
    { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Window Up" },
  },
}
