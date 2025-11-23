local function rotate_gemini_key()
    local env = vim.fn.environ()
    local keys = {}

    -- filter the pattern GEMINI_API_KEY<num>
    for name, _ in pairs(env) do
        if name:match("^GEMINI_API_KEY%d*$") then
            table.insert(keys, name)
        end
    end

    -- ordering: GEMINI_API_KEY, GEMINI_API_KEY1, GEMINI_API_KEY2...
    table.sort(keys, function(a, b)
        local na = tonumber(a:match("^GEMINI_API_KEY(%d+)$")) or 0
        local nb = tonumber(b:match("^GEMINI_API_KEY(%d+)$")) or 0
        return na < nb
    end)

    if #keys == 0 then
        vim.notify("No GEMINI_API_KEY variables found", vim.log.levels.ERROR)
        return
    end

    local current = vim.env.GEMINI_API_KEY
    local current_index = 1

    for i, keyname in ipairs(keys) do
        if env[keyname] == current then
            current_index = i
            break
        end
    end

    -- move forward (with wrap-around)
    local next_index = (current_index % #keys) + 1
    local next_keyname = keys[next_index]

    vim.env.GEMINI_API_KEY = env[next_keyname]

    vim.notify(
        "Gemini API key switched to " .. next_keyname,
        vim.log.levels.INFO
    )
end

vim.api.nvim_create_user_command("RotateGeminiKey", rotate_gemini_key, {})
