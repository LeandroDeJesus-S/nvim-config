return {
    "olimorris/codecompanion.nvim",
    opts = {
        strategies = {
            chat = { adapter = "gemini_cli" },
        },
        adapters = {
            acp = {
                gemini_cli = function()
                    return require("codecompanion.adapters").extend(
                        "gemini_cli",
                        {
                            defaults = {
                                auth_method = "gemini-api-key", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
                            },
                            env = {
                                GEMINI_API_KEY = "cmd:echo $GEMINI_API_KEY",
                            },
                        }
                    )
                end,
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        {
            "<leader>cc",
            "<cmd>CodeCompanionChat Toggle<cr>",
            desc = "Toggle code companion",
        },
    },
}
