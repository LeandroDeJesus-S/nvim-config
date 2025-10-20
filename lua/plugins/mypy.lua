return {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            python = { "dmypy" },
        }

        local lint_group =
            vim.api.nvim_create_augroup("lint", { clear = true })
        vim.api.nvim_create_autocmd(
            { "BufWritePost", "BufReadPost", "InsertLeave" },
            {
                group = lint_group,
                callback = function()
                    lint.try_lint()
                end,
            }
        )

        vim.keymap.set("n", "<leader>cL", function()
            lint.try_lint()
        end, { desc = "Lint current file" })
    end,
}
