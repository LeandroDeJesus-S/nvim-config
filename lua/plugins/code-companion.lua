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
        {
            "HakonHarnes/img-clip.nvim",
            opts = {
                filetypes = {
                    codecompanion = {
                        prompt_for_file_name = false,
                        template = "[Image]($FILE_PATH)",
                        use_absolute_path = true,
                    },
                },
            },
            keys = {
                {
                    "<C-p>",
                    "<cmd>PasteImage<cr>",
                    desc = "Paste image from system clipboard",
                    mode = { "n", "i" },
                },
            },
        },
    },
    cmd = {
        "CodeCompanion",
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
        opts = {
            log_level = "TRACE",
        },
        display = {
            action_palette = {
                provider = "telescope",
            },
            chat = {
                window = {
                    width = chat_w_pct,
                    opts = {
                        number = false,
                        relativenumber = false,
                    },
                },
            },
        },
        extensions = {
            spinner = {},
        },
        interactions = {
            background = {
                adapter = "ollama",
                model = "qwen3:0.6b",
                chat = {
                    opts = {
                        enabled = true,
                    },
                    callbacks = {
                        ["on_ready"] = {
                            actions = {
                                "utils.codecompanion.callbacks.display_acp_mode",
                            },
                            enabled = true,
                        },
                    },
                },
            },
            chat = {
                roles = {
                    llm = function(adapter)
                        local icon = "🤖"
                        local name = adapter.formatted_name
                        local model = adapter.model.name or adapter.model
                        return string.format("%s %s (%s)", icon, name, model)
                    end,
                    user = "🧑🏼‍💻 Me",
                },
                adapter = {
                    name = "opencode",
                    model = "google/antigravity-claude-sonnet-4-5-thinking",
                },
                slash_commands = {
                    ["file"] = {
                        callback = "interactions.chat.slash_commands.builtin.file",
                        description = "Select a file using Telescope",
                        opts = {
                            provider = "telescope",
                            contains_code = true,
                        },
                    },
                },
                tools = {
                    ["fetch_webpage"] = { adapter = "gemini" },
                    groups = {
                        ["read_only"] = {
                            description = "Read-only tools - can be used to read and understand code",
                            prompt = "You are able to use the tools ${tools} to perform read-only operations on code to understand and fetch information as you need.",
                            tools = {
                                "file_search",
                                "read_file",
                                "get_changed_files",
                                "grep_search",
                                "fetch_webpage",
                                "list_code_usages",
                            },
                            opts = {
                                collapse_tools = true,
                            },
                        },
                    },
                    -- opts = {
                    --     default_tools = { "read_only" },
                    -- },
                },
                keymaps = {
                    change_mode = {
                        modes = { n = "gm" },
                        index = 25,
                        callback = function(chat)
                            if not chat.acp_connection then
                                return
                            end

                            local modes = chat.acp_connection:get_modes()
                            if
                                not modes
                                or not modes.availableModes
                                or #modes.availableModes == 0
                            then
                                return
                            end

                            -- Find current mode index
                            local current_idx = 1
                            for i, mode in ipairs(modes.availableModes) do
                                if mode.id == modes.currentModeId then
                                    current_idx = i
                                    break
                                end
                            end

                            -- Cycle to next mode
                            local next_idx = (
                                current_idx % #modes.availableModes
                            ) + 1
                            local next_mode = modes.availableModes[next_idx]

                            chat.acp_connection:set_mode(next_mode.id)
                            chat:update_metadata()
                            vim.g.codecompanion_acp_mode = next_mode.name
                            require("lualine").refresh()
                            require("codecompanion.utils").notify(
                                "Switched to " .. next_mode.name .. " mode",
                                vim.log.levels.INFO
                            )
                        end,
                        description = "[ACP] Cycle session mode",
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
                                default = "gemini-3-flash-preview",
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
        rules = {
            opts = {
                chat = {
                    enabled = true,
                    autoload = { "default", "gemini" },
                },
            },
            gemini = gemini.memory(),
        },
    },
    config = function(_, opts)
        local interactions = opts.interactions or {}
        local chat = interactions.chat or {}
        local adapter = chat.adapter or ""

        if
            (type(adapter) == "string" and adapter == "gemini")
            or (type(adapter) == "table" and adapter.name == "gemini")
        then
            gemini.sync_key()
        end

        require("codecompanion").setup(opts)
    end,
}
