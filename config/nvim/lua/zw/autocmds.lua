-- Autocommands

-- Format C/C++ on save (same behavior as :%!clang-format)
if vim.fn.executable("clang-format") == 1 then
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.cpp", "*.h", "*.cc" },
    command = "%!clang-format",
  })
end

-- Markdown: move current "##" card to top for specific files (ported from Vimscript)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.md" },
  callback = function()
    local name = vim.fn.expand("%:t")
    if not name:match("^(append|review|kanban)%.md$") then
      return
    end
    if vim.b._card_auto_top_busy then
      return
    end
    if vim.b.last_tick and vim.b.last_tick == vim.b.changedtick then
      return
    end

    local curpos = vim.fn.getpos(".")
    local s = vim.fn.search("^##%s", "bnW")
    if s == 0 then
      return
    end
    local e = vim.fn.search("^##%s", "nW")
    if e == 0 then
      e = vim.fn.line("$") + 1
    end
    e = e - 1

    vim.b._card_auto_top_busy = true
    local ok, err = pcall(function()
      vim.cmd(("%d,%dmove 0"):format(s, e))

      -- normalize spacing: exactly one blank line before each "##" (except first)
      vim.fn.cursor(1, 1)
      while true do
        local l = vim.fn.search("^##%s", "W")
        if l == 0 then
          break
        end
        if l > 1 then
          while l > 1 and vim.fn.getline(l - 1):match("^%s*$") do
            vim.cmd(((l - 1) .. "delete _"))
            l = l - 1
          end
          if l > 1 and not vim.fn.getline(l - 1):match("^%s*$") then
            vim.fn.append(l - 1, "")
            l = l + 1
          end
        end
        vim.fn.cursor(l + 1, 1)
      end
    end)
    vim.b._card_auto_top_busy = nil
    if not ok then
      vim.notify(("card_auto_top failed: %s"):format(err), vim.log.levels.WARN)
    end
    vim.fn.setpos(".", curpos)
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.md" },
  callback = function()
    vim.b.last_tick = vim.b.changedtick
  end,
})

