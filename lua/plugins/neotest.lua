return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-neotest/neotest-python",
            {
                "fredrikaverpil/neotest-golang",
                version = "*",
                build = function()
                    vim.system({
                        "go",
                        "install",
                        "gotest.tools/gotestsum@latest",
                    }):wait()
                end,
            },
        },
        opts = {
            adapters = {
                "neotest-python",
                ["neotest-golang"] = { runner = "gotestsum" },
            },
        },
    },
}
