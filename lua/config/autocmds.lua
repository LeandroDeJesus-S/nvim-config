-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
    end,
})

local cc_group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

vim.api.nvim_create_autocmd({ "User" }, {
    pattern = {
        "CodeCompanionChatACPModeChanged",
        "CodeCompanionChatCreated",
        "CodeCompanionChatOpened",
    },
    group = cc_group,
    callback = function(request)
        local ok, chat = pcall(
            require("codecompanion.interactions.chat").buf_get_chat,
            request.buf
        )
        if ok and chat then
            if request.match == "CodeCompanionChatACPModeChanged" then
                local modes = chat.acp_connection:get_modes()
                if modes and modes.currentModeId then
                    for _, mode in ipairs(modes.availableModes) do
                        if mode.id == modes.currentModeId then
                            vim.g.codecompanion_acp_mode = mode.name
                            require("lualine").refresh()
                            break
                        end
                    end
                end
            else
                -- For Created/Opened events, use the shared logic
                require("utils.codecompanion.callbacks.display_acp_mode").request(
                    nil,
                    chat
                )
            end
        end
    end,
})
