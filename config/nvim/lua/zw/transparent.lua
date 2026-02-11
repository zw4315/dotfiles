local M = {}

local groups = {
  "Normal",
  "NormalNC",
  "NonText",
  "LineNr",
  "SignColumn",
  "FoldColumn",
  "VertSplit",
  "StatusLine",
  "StatusLineNC",
}

local function apply()
  if not vim.g.transparent_enabled then
    return
  end
  for _, name in ipairs(groups) do
    vim.api.nvim_set_hl(0, name, { bg = "none", ctermbg = "none" })
  end
end

function M.enable()
  vim.g.transparent_enabled = true
  apply()
end

function M.disable()
  vim.g.transparent_enabled = false
  local ok, colors_name = pcall(function()
    return vim.g.colors_name
  end)
  if ok and colors_name and colors_name ~= "" then
    pcall(vim.cmd.colorscheme, colors_name)
  end
end

function M.toggle()
  if vim.g.transparent_enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.setup()
  if vim.g.transparent_enabled == nil then
    vim.g.transparent_enabled = false
  end
  vim.api.nvim_create_user_command("ToggleTransparent", function()
    M.toggle()
  end, {})
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      apply()
    end,
  })
end

return M

