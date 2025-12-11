local M = {}
local state = {
    gemini_state_file = vim.fn.stdpath("data") .. "/gemini_api_key_state",
}

function M.get_current_key_name()
    local f = io.open(state.gemini_state_file, "r")
    if not f then
        return nil
    end
    local name = f:read("*a")
    f:close()
    return (name ~= "" and name) or nil
end

local function write_current_key_name(name)
    local f = io.open(state.gemini_state_file, "w")
    if not f then
        vim.notify(
            "Failed to write Gemini key state to " .. state.gemini_state_file,
            vim.log.levels.ERROR
        )
        return
    end
    f:write(name)
    f:close()
end

-- Rotate between gemini api keys.
--
--  If you sets gemini api keys like GEMINI_API_KEY, GEMINI_API_KEY1, GEMINI_API_KEYn. This function will rotate between them.
--  GEMINI_API_KEY is the default key, and at least 2 keys are required.
M.rotate_key = function()
    local keys = {}
    for name, _ in pairs(vim.fn.environ()) do
        if name:match("^GEMINI_API_KEY%d*$") then
            table.insert(keys, name)
        end
    end

    if #keys < 2 then
        vim.notify(
            "Not enough GEMINI_API_KEY variables found to rotate",
            vim.log.levels.WARN
        )
        return
    end

    table.sort(keys, function(a, b)
        local na = tonumber(a:match("^GEMINI_API_KEY(%d+)$")) or -1
        local nb = tonumber(b:match("^GEMINI_API_KEY(%d+)$")) or -1
        if a == "GEMINI_API_KEY" then
            na = 0
        end
        if b == "GEMINI_API_KEY" then
            nb = 0
        end
        return na < nb
    end)

    local current_key = M.get_current_key_name() or "GEMINI_API_KEY"

    for i, keyname in ipairs(keys) do
        if current_key == keyname then
            current_key = keys[(i % #keys) + 1]
            break
        end
    end

    vim.env._GEMINI_API_KEY = vim.fn.environ()[current_key]
    write_current_key_name(current_key)
end

-- Sync gemini api with the last recently used.
function M.sync_key()
    local current = M.get_current_key_name()

    if
        current
        and vim.fn.has_key(vim.fn.environ(), current)
        and vim.fn.environ()[current] ~= vim.env._GEMINI_API_KEY
    then
        vim.env._GEMINI_API_KEY = vim.fn.environ()[current]
    end

    vim.notify(
        string.format("Gemini API key synced to %s", current),
        vim.log.levels.INFO
    )
end

function M.memory()
    return {
        description = "Gemini memory files",
        parser = "claude",
        files = {
            "GEMINI.md",
            "AGENTS.md",
        },
    }
end

return M
