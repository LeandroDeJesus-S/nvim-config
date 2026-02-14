return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
        local acp_mode = {
            function()
                return "󰚩 " .. (vim.g.codecompanion_acp_mode or "")
            end,
            cond = function()
                return vim.g.codecompanion_acp_mode ~= nil
                    and vim.bo.filetype == "codecompanion"
            end,
            color = function()
                if (vim.g.codecompanion_acp_mode or ""):lower() == "build" then
                    return { fg = "#a9a1e1" }
                end
                return { fg = "#ff9e64" }
            end,
        }
        opts.sections = opts.sections or {}
        opts.sections.lualine_x = opts.sections.lualine_x or {}
        table.insert(opts.sections.lualine_x, 1, acp_mode)
        return opts
    end,
}
