---@class CodeCompanionPromptContext
---@field bufnr number
---@field buftype string
---@field cursor_pos number[] `{row, col}`
---@field end_col number
---@field end_line number
---@field filetype string
---@field is_normal boolean
---@field is_visual boolean
---@field lines string[]
---@field mode string
---@field start_col number
---@field start_line number
---@field winnr number

---@class CodeCompanionPromptMessageOpts
---@field contains_code boolean | nil

---@class CodeCompanionPromptMessage
---@field role string
---@field content string | fun(context: CodeCompanionPromptContext): string
---@field opts CodeCompanionPromptMessageOpts | nil
---@field condition? fun(context: CodeCompanionPromptContext): boolean | nil

---@class CodeCompanionAdapterOpts
---@field name string
---@field model string

---@class CodeCompanionPromptOpts
---@field mapping string | nil
---@field modes string[] | nil
---@field alias string | nil
---@field auto_submit boolean | nil
---@field stop_context_insertion boolean | nil
---@field user_prompt boolean | nil
---@field pre_hook? fun(): number | nil
---@field is_slash_cmd boolean | nil
---@field adapter CodeCompanionAdapterOpts | nil
---@field placement "new" | "replace" | "add" | "before" | "chat" | nil
---@field ignore_system_prompt boolean | nil
---@field intro_message string | nil
---@field index number | nil
---@field is_default boolean | nil
---@field is_workflow boolean | nil

---@class CodeCompanionFileContext
---@field type "file"
---@field path string | string[]

---@class CodeCompanionSymbolsContext
---@field type "symbols"
---@field path string

---@class CodeCompanionUrlContext
---@field type "url"
---@field url string

---@alias CodeCompanionPreloadContext CodeCompanionFileContext | CodeCompanionSymbolsContext | CodeCompanionUrlContext

---@class CodeCompanionPromptDefinition
---@field interaction "chat" | "inline" | string
---@field description string
---@field opts CodeCompanionPromptOpts | nil
---@field prompts CodeCompanionPromptMessage[]
---@field context CodeCompanionPreloadContext[] | nil
---@field default_memory? string | nil
---@field condition? fun(context: CodeCompanionPromptContext): boolean | nil -- For palette visibility
---@field name string | nil -- Used for picker type prompts (e.g., "Open chats...")
---@field picker table | nil -- Used for picker type prompts (e.g., "Open chats...")

---@class CodeCompanionPromptLibrary
---@field [string] CodeCompanionPromptDefinition

local M = {}

local current_file = debug.getinfo(1, "S").source:sub(2)
local current_dir = vim.fn.fnamemodify(current_file, ":h")

for name, typ in vim.fs.dir(current_dir) do
    if not name or name == "init.lua" or typ ~= "file" then
        goto continue
    end

    local module_name = name:gsub("%.lua$", "")
    local full_module_path = "utils.codecompanion.prompts." .. module_name

    local ok, module = pcall(require, full_module_path)
    if ok and type(module) == "table" then
        for k, v in pairs(module) do
            M[k] = v
        end
    else
        print("Failed to load:", full_module_path, "Error:", module)
    end

    ::continue::
end

return M
