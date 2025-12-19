return {
    {
        "hrsh7th/nvim-cmp",
        enabled = false,
    },
    {
        "saghen/blink.cmp",
        dependencies = {
            { "rafamadriz/friendly-snippets" },
        },
        enabled = true,

        version = "1.*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = { preset = "super-tab" },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 500 },
                trigger = {
                    show_on_trigger_character = true,
                    show_on_blocked_trigger_characters = { " ", "\n", "\t" },
                },
                menu = {
                    border = "rounded",
                    draw = {
                        components = {
                            src_name = {
                                text = function(ctx)
                                    return string.format(
                                        "[%s]",
                                        ctx.source_name
                                    )
                                end,
                            },
                            kind_icon = {
                                text = function(ctx)
                                    local ic, _, _ = require("mini.icons").get(
                                        "lsp",
                                        ctx.kind
                                    )
                                    return ic
                                end,
                                highlight = function(ctx)
                                    local _, hl, _ = require("mini.icons").get(
                                        "lsp",
                                        ctx.kind
                                    )
                                    return hl
                                end,
                            },
                        },
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind_icon", "kind", gap = 1 },
                            { "src_name" },
                        },
                    },
                },
            },

            sources = {
                default = {
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                },
            },

            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
}
