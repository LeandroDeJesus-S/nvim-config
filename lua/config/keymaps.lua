-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local opts = { noremap = true, silent = true }

vim.keymap.set(
    "v",
    "J",
    ":m '>+1<CR>gv=gv",
    { desc = "move down selected lines in visual mode" }
)
vim.keymap.set(
    "v",
    "K",
    ":m '<-2<CR>gv=gv",
    { desc = "move up selected lines in visual mode" }
)

local Terminal = require("toggleterm.terminal").Terminal
local lazydocker = Terminal:new({
    cmd = "lazydocker",
    hidden = true,
    direction = "float",
})

function _lazydocker_toggle()
    lazydocker:toggle()
end

vim.keymap.set(
    "n",
    "<leader>Ld",
    "<cmd>lua _lazydocker_toggle()<CR>",
    { desc = "Toggle lazydocker", noremap = true, silent = true }
)
