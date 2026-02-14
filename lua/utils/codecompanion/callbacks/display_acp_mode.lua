local log = require("codecompanion.utils.log")

local M = {}

---@param background CodeCompanion.Background|nil
---@param chat CodeCompanion.Chat
function M.request(background, chat)
    local function fetch_modes(attempt)
        if not chat or not chat.acp_connection then
            if attempt < 10 then
                vim.defer_fn(function()
                    fetch_modes(attempt + 1)
                end, 500)
            else
                log:info("[display_acp_mode] No ACP connection after retries")
            end
            return
        end

        local modes = chat.acp_connection:get_modes()
        if
            not modes
            or not modes.availableModes
            or #modes.availableModes == 0
        then
            if attempt < 10 then
                vim.defer_fn(function()
                    fetch_modes(attempt + 1)
                end, 500)
            else
                log:info("[display_acp_mode] No modes available after retries")
            end
            return
        end

        -- Find current mode
        local current_mode
        for _, mode in ipairs(modes.availableModes) do
            if mode.id == modes.currentModeId then
                current_mode = mode
                break
            end
        end

        if not current_mode then
            log:info("[display_acp_mode] Current mode not found")
            return
        end

        vim.g.codecompanion_acp_mode = current_mode.name
        require("lualine").refresh()

        -- Check if title already contains mode to avoid duplicates
        local existing_title = chat.title or ""
        local mode_suffix = " - " .. current_mode.name

        if existing_title:find(mode_suffix, 1, true) then
            log:info("[display_acp_mode] Mode already in title")
            return
        end

        -- If title is empty/nil, wait for it
        if existing_title == "" then
            log:info("[display_acp_mode] Title not set yet, skipping")
            return
        end

        local new_title = existing_title .. mode_suffix
        chat:set_title(new_title)
        log:info("[display_acp_mode] Set title to: " .. new_title)
    end

    -- Start fetching with retries
    fetch_modes(1)
end

return M
