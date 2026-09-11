local M = {}

local function read_colors()
  local path = vim.fn.expand("~/.cache/wal/colors.json")
  local file = io.open(path, "r")
  if not file then return nil end

  local contents = file:read("*a")
  file:close()
  local ok, data = pcall(vim.json.decode, contents)
  if not ok or not data then return nil end
  return vim.tbl_extend("force", data.special or {}, data.colors or {})
end

function M.apply()
  local colors = read_colors()
  if not colors then return end

  vim.o.background = "dark"
  vim.cmd("highlight clear")

  for index = 0, 15 do
    vim.g["terminal_color_" .. index] = colors["color" .. index]
  end

  local set = vim.api.nvim_set_hl
  local function hl(name, opts) set(0, name, opts) end

  hl("Normal", { fg = colors.foreground, bg = colors.background })
  hl("NormalFloat", { fg = colors.foreground, bg = colors.color0 })
  hl("FloatBorder", { fg = colors.color12, bg = colors.color0 })
  hl("CursorLine", { bg = colors.color0 })
  hl("CursorLineNr", { fg = colors.color13, bold = true })
  hl("LineNr", { fg = colors.color8 })
  hl("SignColumn", { bg = colors.background })
  hl("StatusLine", { fg = colors.foreground, bg = colors.color0 })
  hl("StatusLineNC", { fg = colors.color8, bg = colors.color0 })
  hl("TabLine", { fg = colors.color8, bg = colors.color0 })
  hl("TabLineSel", { fg = colors.background, bg = colors.color12, bold = true })
  hl("Visual", { bg = colors.color8 })
  hl("Search", { fg = colors.background, bg = colors.color13 })
  hl("IncSearch", { fg = colors.background, bg = colors.color12, bold = true })
  hl("MatchParen", { fg = colors.color13, bold = true, underline = true })
  hl("Comment", { fg = colors.color8, italic = true })
  hl("String", { fg = colors.color3 })
  hl("Function", { fg = colors.color12 })
  hl("Keyword", { fg = colors.color5 })
  hl("Type", { fg = colors.color6 })
  hl("Constant", { fg = colors.color13 })
  hl("Identifier", { fg = colors.color7 })
  hl("Operator", { fg = colors.color4 })
  hl("DiagnosticError", { fg = colors.color1 })
  hl("DiagnosticWarn", { fg = colors.color5 })
  hl("DiagnosticInfo", { fg = colors.color4 })
  hl("DiagnosticHint", { fg = colors.color3 })
  hl("ErrorMsg", { fg = colors.color1, bold = true })
  hl("WarningMsg", { fg = colors.color5, bold = true })
end

vim.api.nvim_create_user_command("Pywal", M.apply, {})
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = M.apply,
})

return M
