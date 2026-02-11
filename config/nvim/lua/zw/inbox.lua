local M = {}

local function default_inbox_path()
  return vim.fn.expand("~/mgnt/notes/00-inbox.md")
end

local function fallback_inbox_path()
  return vim.fn.stdpath("state") .. "/inbox.md"
end

local function ensure_file(path)
  if vim.fn.filereadable(path) == 1 then
    return true
  end
  local ok = pcall(function()
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    vim.fn.writefile({ "# Inbox", "", "- " }, path)
  end)
  return ok
end

function M.open()
  local primary = vim.fn.fnamemodify(vim.g.inbox_file or default_inbox_path(), ":p")
  local path = primary
  if not ensure_file(path) then
    local fallback = vim.fn.fnamemodify(fallback_inbox_path(), ":p")
    if ensure_file(fallback) then
      vim.notify(("Inbox path not writable: %s; using %s"):format(primary, fallback), vim.log.levels.WARN)
      path = fallback
    else
      vim.notify(("Inbox path not writable: %s"):format(primary), vim.log.levels.ERROR)
      return
    end
  end

  if #vim.api.nvim_list_uis() == 0 then
    vim.cmd.edit(vim.fn.fnameescape(path))
    return
  end

  local buf = vim.fn.bufadd(path)
  vim.fn.bufload(buf)

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    row = row,
    col = col,
  })

  vim.api.nvim_set_option_value("number", true, { win = win })
  vim.api.nvim_set_option_value("relativenumber", true, { win = win })
  vim.api.nvim_set_option_value("wrap", false, { win = win })
  vim.cmd("normal! gg")
end

function M.setup()
  vim.api.nvim_create_user_command("Inbox", function()
    M.open()
  end, {})
end

return M

