local getPyPoetryPath = function()
    local wd = vim.fn.getcwd()
    if vim.fn.glob(wd .. "**/pyproject.toml") == "" then
        if vim.fn.glob(wd .. "**/*.py") ~= "" then
            vim.notify(
                "Unable to find poetry project",
                vim.log.levels.WARN,
                {}
            )
        end
        return ""
    end
    local envPythonPath = vim.fn.trim(vim.fn.system("poetry env info -e"))
    return envPythonPath
end

return {
    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            ---@type lspconfig.options
            servers = {
                ruff = {
                    init_options = {
                        settings = {
                            configurationPreference = "filesystemFirst",
                            lineLength = 95,
                            indentWidth = 4,
                            outputFormat = "grouped",
                            exclude = {
                                "*/migrations/*",
                                "*__init__*",
                                "*__pyc*",
                                "media/",
                                "templates/*",
                                "readme",
                                "tests/",
                                "*_test.py",
                                "manage.py",
                            },
                            lint = {
                                preview = true,
                                select = { "I", "F", "E", "W", "PL", "PT" },
                            },
                            format = {
                                preview = true,
                                ["quote-style"] = "single",
                                ["docstring-code-format"] = true,
                                ["docstring-code-line-length"] = 90,
                                ["line-ending"] = "lf",
                            },
                        },
                    },
                },
                gopls = {
                    settings = {
                        gopls = {
                            hints = {
                                rangeVariableTypes = true,
                                parameterNames = true,
                                constantValues = true,
                                assignVariableTypes = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                functionTypeParameters = true,
                            },
                        },
                    },
                },
                pyright = {
                    settings = {
                        disableOrganizeImports = true,
                        python = {
                            pythonPath = getPyPoetryPath(),
                            analysis = {
                                -- ignore = { "*" },
                                typeCheckingMode = "off",
                            },
                        },
                    },
                },
            },
        },
    },
}
