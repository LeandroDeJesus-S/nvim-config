local utils = require("utils")
local gemini = require("utils.codecompanion.gemini")
local prompts = require("utils.codecompanion.prompts")

local chat_w_pct = 0.35

return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim",
        "franco-ruggeri/codecompanion-spinner.nvim",
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
    opts = {
        display = {
            action_palette = {
                provider = "telescope",
            },
            chat = {
                window = {
                    width = chat_w_pct,
                },
            },
        },
        extensions = {
            spinner = {},
        },
        strategies = {
            chat = {
                roles = {
                    llm = function(adapter)
                        local icon = "🤖"
                        local name = adapter.formatted_name
                        local model = adapter.model.name
                        return string.format("%s %s (%s)", icon, name, model)
                    end,
                    user = "🧑🏼‍💻 Me",
                },
                adapter = "gemini",
                slash_commands = {
                    ["file"] = {
                        callback = "strategies.chat.slash_commands.catalog.file",
                        description = "Select a file using Telescope",
                        opts = {
                            provider = "telescope",
                            contains_code = true,
                        },
                    },
                },
            },
            inline = {
                adapter = "gemini",
                keymaps = {
                    accept_change = {
                        modes = { n = "<C-y>" },
                    },
                    reject_change = {
                        modes = { n = "<C-n>" },
                    },
                },
            },
            cmd = { adapter = "gemini" },
        },
        adapters = {
            http = {
                gemini = function()
                    return require("codecompanion.adapters").extend("gemini", {
                        env = {
                            api_key = function()
                                local key = vim.env._GEMINI_API_KEY
                                if not key then
                                    key = os.getenv(
                                        gemini.get_current_key_name()
                                            or "GEMINI_API_KEY"
                                    )
                                end
                                return key
                            end,
                        },
                        schema = {
                            model = {
                                default = "gemini-2.5-flash",
                            },
                        },
                        handlers = {
                            on_exit = function(_, data)
                                if not data then
                                    return
                                end

                                if data.status ~= 429 then
                                    return
                                end

                                local ok, _ = pcall(gemini.rotate_key)
                                if not ok then
                                    utils.error(
                                        "Failed to rotate Gemini API key"
                                    )
                                    return
                                end
                                utils.info(
                                    string.format(
                                        "Gemini API key changed to %s",
                                        gemini.get_current_key_name()
                                    )
                                )
                            end,
                        },
                    })
                end,
            },
        },
        prompt_library = prompts,
        memory = {
            opts = {
                chat = {
                    enabled = true,
                    defualt_memory = { "default", "gemini" },
                },
            },
            gemini = gemini.memory(),
        },
    },
    config = function(_, opts)
        gemini.sync_key()
        require("codecompanion").setup(opts)
    end,
}
