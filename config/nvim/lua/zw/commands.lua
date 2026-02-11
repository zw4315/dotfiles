local M = {}

local function notify_missing(bin, hint)
  local msg = ("Missing `%s` in PATH."):format(bin)
  if hint and hint ~= "" then
    msg = msg .. " " .. hint
  end
  vim.notify(msg, vim.log.levels.WARN)
end

function M.files()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope.nvim not available", vim.log.levels.WARN)
    return
  end
  telescope.find_files({ hidden = true })
end

function M.history()
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope.nvim not available", vim.log.levels.WARN)
    return
  end
  telescope.oldfiles({})
end

function M.live_grep(initial)
  if vim.fn.executable("rg") ~= 1 then
    notify_missing("rg", "Install ripgrep to enable live grep.")
    return
  end
  local ok, telescope = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("telescope.nvim not available", vim.log.levels.WARN)
    return
  end
  telescope.live_grep({ default_text = initial or "" })
end

function M.replace()
  if vim.fn.executable("rg") ~= 1 then
    notify_missing("rg", "Install ripgrep to enable project replace.")
    return
  end
  local ok, spectre = pcall(require, "spectre")
  if not ok then
    vim.notify("nvim-spectre not available", vim.log.levels.WARN)
    return
  end
  spectre.open()
end

function M.replace_file()
  if vim.fn.executable("rg") ~= 1 then
    notify_missing("rg", "Install ripgrep to enable file replace.")
    return
  end
  local ok, spectre = pcall(require, "spectre")
  if not ok then
    vim.notify("nvim-spectre not available", vim.log.levels.WARN)
    return
  end
  spectre.open_file_search()
end

function M.setup_user_commands()
  -- Compatibility with old Vim mappings/commands
  vim.api.nvim_create_user_command("Files", function()
    M.files()
  end, {})
  vim.api.nvim_create_user_command("History", function()
    M.history()
  end, {})
  vim.api.nvim_create_user_command("Rg", function(opts)
    M.live_grep(opts.args)
  end, { nargs = "*", complete = "file" })
end

M.setup_user_commands()

return M

