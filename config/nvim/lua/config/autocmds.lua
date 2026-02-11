-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Telekasten uses <C-i> for "insert link" inside some Telescope pickers.
-- In most terminal setups, <Tab> == <C-i>, so pressing Tab can trigger an
-- insert action that fails in non-modifiable buffers (e.g. calendar).
-- Remap <Tab>/<C-i> in TelescopePrompt to a safe navigation action.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function(args)
    local ok_actions, actions = pcall(require, "telescope.actions")
    if not ok_actions then
      return
    end

    local ok_state, state = pcall(require, "telescope.actions.state")
    if ok_state then
      local picker = state.get_current_picker(args.buf)
      local title = picker and picker.prompt_title or ""
      local title_l = string.lower(title)
      if not string.find(title_l, "telekasten", 1, true) and not string.find(title_l, "goto day", 1, true) then
        return
      end
    end

    vim.keymap.set("i", "<Tab>", actions.move_selection_next, { buffer = args.buf, silent = true })
    vim.keymap.set("i", "<S-Tab>", actions.move_selection_previous, { buffer = args.buf, silent = true })
    vim.keymap.set("i", "<C-i>", actions.move_selection_next, { buffer = args.buf, silent = true })
  end,
})
