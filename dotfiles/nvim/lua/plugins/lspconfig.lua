return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Don't let nvim-lspconfig manage roslyn_ls because it's managed by roslyn.nvim
                roslyn_ls = {
                    enabled = false,
                },
                -- `hl` is the global of the Hyprland Lua API (home/gui/hyprland)
                lua_ls = {
                    settings = {
                        Lua = { diagnostics = { globals = { "hl" } } },
                    },
                },
            },
        },
    },
}
