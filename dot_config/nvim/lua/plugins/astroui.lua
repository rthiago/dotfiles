-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        features = {
          diagnostics = {
            virtual_text = false,
            virtual_lines = false,
          },
        },
        diagnostics = {
          virtual_text = false,
        },
        options = { opt = { foldcolumn = "0", scrolloff = 4, wrap = true } },
        mappings = {
          n = {
            ["<C-H>"] = {
              function() require("astrocore.buffer").nav(-vim.v.count1) end,
              desc = "Previous buffer",
            },
            ["<C-J>"] = { "<C-E>", desc = "Scroll viewport down" },
            ["<C-K>"] = { "<C-Y>", desc = "Scroll viewport up" },
            ["<C-L>"] = {
              function() require("astrocore.buffer").nav(vim.v.count1) end,
              desc = "Next buffer",
            },
            ["<BS>"] = { "<C-^>", desc = "Alternate buffer" },
            ["<Leader>O"] = {
              function() vim.fn.setreg("+", vim.fn.expand "%:.") end,
              desc = "Copy file path",
            },
            H = { "^", desc = "First non-blank character" },
            L = { "g_", desc = "Last non-blank character" },
            n = { "nzz", desc = "Next search result centered" },
            N = { "Nzz", desc = "Previous search result centered" },
          },
        },
      },
    },
  },
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "dracula",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
