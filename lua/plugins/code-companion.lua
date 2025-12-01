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
    config = function()
        require("codecompanion").setup({
            display = {
                action_palette = {
                    provider = "telescope",
                },
            },
            extensions = {
                spinner = {},
            },
            strategies = {
                chat = {
                    adapter = "gemini",
                    slash_commands = {
                        ["file"] = {
                            callback = "strategies.chat.slash_commands.catalog.file",
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
            prompt_library = {
                ["Convertional Commit"] = {
                    strategy = "chat",
                    description = "Suggests a semantic/convertional commit message",
                    prompts = {
                        role = "user",
                        content = function(context)
                            local tpl =
                                [[Generate a high-quality commit message following the rules of Conventional Commits (https://www.conventionalcommits.org/).

Requirements:
- Start with a valid type (feat, fix, refactor, docs, style, test, chore, perf, build, ci, revert).
- Optionally include a scope in parentheses.
- Use a short, clear, one-line description written in the imperative mood (e.g., “add…”, “fix…”, “update…”).
- Keep the subject under 70 characters when possible.

Body rules:
- Provide a concise and meaningful explanation of WHAT changed and WHY.
- Break the body into paragraphs if needed, each focused and short.
- Do not repeat the subject in the body.
- Avoid implementation details unless they help understand intent.
- If relevant, include notes on breaking changes or important side effects.

Input:
The following are the staged changes; analyze them carefully and infer the most appropriate type, scope, and description:

```diff
%s
```
]]
                            local diff = vim.system(
                                { "git", "diff", "--no-ext-diff", "--staged" },
                                { text = true }
                            ):wait()
                            return string.format(tpl, diff.stdout)
                        end,
                        opts = {
                            contains_code = true,
                        },
                    },
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
