-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>jp", "<Cmd>put<CR>", { desc = "Put below" })
vim.keymap.set("n", "<leader>jP", "<Cmd>put!<CR>", { desc = "Put above" })
