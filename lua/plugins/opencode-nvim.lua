return {
    "NickvanDyke/opencode.nvim",
    dependencies = {
        -- Recommended for `ask()` and `select()`.
        -- Required for `snacks` provider.
        ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
        {
            "folke/snacks.nvim",
            opts = { input = {}, picker = {}, terminal = {} },
        },
    },
    config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            provider = {
                enabled = "snacks",
                snacks = {
                    win = {
                        width = math.floor(vim.o.columns * 0.35),
                    },
                },
            },
        }

        -- Required for `opts.events.reload`.
        vim.o.autoread = true

        vim.keymap.set({ "n", "x" }, "<leader>os", function()
            require("opencode").select()
        end, { desc = "Execute opencode action" })

        vim.keymap.set({ "n", "t" }, "<C-.>", function()
            require("opencode").toggle()
        end, { desc = "Toggle opencode" })

        -- asking
        vim.keymap.set({ "n", "x" }, "<leader>oa", function()
            require("opencode").ask("@this: ", { submit = true })
        end, { desc = "Ask @this (submit)" })

        vim.keymap.set({ "n", "x" }, "<C-o><C-o>", function()
            require("opencode").ask(" ")
        end, { desc = "Ask opencode" })

        -- operators
        vim.keymap.set({ "n", "x" }, "<leader>or", function()
            return require("opencode").operator(" @this ")
        end, { desc = "Add range to opencode", expr = true })

        vim.keymap.set("n", "<leader>ol", function()
            return require("opencode").operator(" @this ") .. "_"
        end, { desc = "Add line to opencode", expr = true })

        -- commands
        vim.keymap.set("n", "C-o><C-u>", function()
            require("opencode").command("session.half.page.up")
        end, { desc = "Scroll opencode up" })

        vim.keymap.set("n", "<C-o><C-d>", function()
            require("opencode").command("session.half.page.down")
        end, { desc = "Scroll opencode down" })

        vim.keymap.set({ "n", "t" }, "<C-o><C-l>", function()
            require("opencode").command("prompt.clear")
        end, { desc = "Clear opencode prompt" })

        vim.keymap.set({ "n", "t" }, "<C-o><C-u>", function()
            require("opencode").command("session.undo")
        end, { desc = "Undo opencode session" })

        vim.keymap.set({ "n", "t" }, "<C-o><C-r>", function()
            require("opencode").command("session.redo")
        end, { desc = "Redo opencode session" })
    end,
}
