vim.api.nvim_create_user_command(
    "RotateGeminiKey",
    require("utils.codecompanion.gemini").rotate_key,
    {}
)
