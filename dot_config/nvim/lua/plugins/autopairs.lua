---@type LazySpec
return {
  "windwp/nvim-autopairs",
  config = function(plugin, opts)
    require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts)

    -- Keep backticks literal, including Markdown fences and their Enter handling.
    local autopairs = require "nvim-autopairs"
    autopairs.remove_rule "`"
    autopairs.remove_rule "```"
    autopairs.remove_rule "```.*$"
  end,
}
