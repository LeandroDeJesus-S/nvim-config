return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim",
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
    config = function()
        require("codecompanion").setup({
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
                        return require("codecompanion.adapters").extend(
                            "gemini",
                            {
                                schema = {
                                    model = {
                                        default = "gemini-2.5-pro",
                                    },
                                },
                            }
                        )
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
        })

        -- auto rotate gemini api key on 429 response
        vim.api.nvim_create_autocmd({ "User" }, {
            group = vim.api.nvim_create_augroup("CodeCompanionHooks", {}),
            pattern = { "CodeCompanionRequestFinished" },
            callback = function(opts)
                if
                    opts.data.adapter.name ~= "gemini"
                    or opts.match ~= "CodeCompanionRequestFinished"
                then
                    return
                end

                if opts.data.status == 429 then
                    vim.cmd("RotateGeminiKey")
                end
            end,
        })
    end,
}
