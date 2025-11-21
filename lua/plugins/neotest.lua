return {
    { "nvim-neotest/neotest-python" },
    { "fredrikaverpil/neotest-golang" },
    {
        "nvim-neotest/neotest",
        opts = { adapters = { "neotest-python", "neotest-golang" } },
    },
}
