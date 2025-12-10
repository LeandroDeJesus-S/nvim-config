local function run_git_diff()
    if vim.system then
        local result = vim.system(
            { "git", "diff", "--no-ext-diff", "--staged" },
            { text = true }
        ):wait()
        if result.code == 0 then
            return result.stdout
        end
    else
        -- Fallback for older Neovim
        local output = vim.fn.system("git diff --no-ext-diff --staged")
        if vim.v.shell_error == 0 then
            return output
        end
    end
    return "No staged changes found. Please stage your changes first."
end

---@type CodeCompanionPromptLibrary
return {
    ["Conventional Commit"] = {
        strategy = "chat",
        description = "Suggests a semantic/conventional commit message",
        opts = {},
        prompts = {
            {
                role = "user",
                content = function(_)
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
                    local diff = run_git_diff()
                    return string.format(tpl, diff)
                end,
                opts = {
                    contains_code = true,
                },
            },
        },
    },
}
