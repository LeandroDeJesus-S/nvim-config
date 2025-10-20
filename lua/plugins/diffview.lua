return {
    "sindrets/diffview.nvim",
    config = function()
        require("diffview").setup()
    end,
    keys = {
        { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diff view open" },
    },
}
