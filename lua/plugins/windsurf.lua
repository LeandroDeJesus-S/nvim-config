return {
    "Exafunction/windsurf.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    opts = {
        virtual_text = {
            filetypes = {
                python = true,
                go = true,
                markdown = false,
            },
            default_filetype_enabled = true,
        },
    },
    keys = {},
}
