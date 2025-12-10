return {
    {
        "LeandroDeJesus-S/poetry.nvim",
        config = function(_)
            require("poetry_nvim").setup({
                plugins = {
                    poetry_shell = { enabled = true },
                },
            })
        end,
    },
}
