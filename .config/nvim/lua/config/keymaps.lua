-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "H", "b", { desc = "Word left" })
vim.keymap.set("n", "L", "w", { desc = "Word right" })
vim.keymap.set("n", "J", ")", { desc = "Next sentence" })
vim.keymap.set("n", "K", "(", { desc = "Previous sentence" })
