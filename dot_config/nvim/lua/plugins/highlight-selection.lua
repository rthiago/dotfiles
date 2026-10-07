-- Highlight other occurrences of the visually selected text (mouse or keyboard)

local function clear()
  if vim.w.selection_match_id then
    pcall(vim.fn.matchdelete, vim.w.selection_match_id)
    vim.w.selection_match_id = nil
  end
end

local function update()
  clear()
  if vim.fn.mode() ~= "v" then return end
  local lines = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", { type = "v" })
  if #lines ~= 1 or #vim.trim(lines[1]) < 2 then return end
  vim.w.selection_match_id = vim.fn.matchadd("Search", "\\V" .. vim.fn.escape(lines[1], "\\"), -1)
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      highlight_selection = {
        { event = "CursorMoved", desc = "Highlight selection matches", callback = update },
        { event = "ModeChanged", desc = "Highlight selection matches", callback = vim.schedule_wrap(update) },
      },
    },
  },
}
