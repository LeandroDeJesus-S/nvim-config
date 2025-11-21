return {
    "olimorris/codecompanion.nvim",
    opts = {
        display = {
            action_palette = {
                provider = "telescope",
            },
        },
        strategies = {
            chat = {
                adapter = "gemini",
                slash_commands = {
                    ["file"] = {
                        callback = "strategies.chat.slash_commands.file",
                        description = "Select a file using Telescope",
                        opts = {
                            provider = "telescope", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks"
                            contains_code = true,
                        },
                    },
                },
            },
            inline = { adapter = "gemini" },
            cmd = { adapter = "gemini" },
        },
        adapters = {
            http = {
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        schema = {
                            model = {
                                default = "gemini-2.5-pro",
                            },
                        },
                    })
                end,
            },
            acp = {
                gemini_cli = function()
                    return require("codecompanion.adapters").extend(
                        "gemini_cli",
                        {
                            defaults = {
                                auth_method = "gemini-api-key", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
                                timeout = 60000,
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
            "<leader>ai",
            "<cmd>CodeCompanionChat Toggle<cr>",
            desc = "Toggle code companion",
        },
        {
            "<leader>aa",
            "<cmd>CodeCompanionActions<cr>",
            desc = "Show code companion actions",
        },
    },
}
