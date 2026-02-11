local cmd = require("zw.commands")

local map = vim.keymap.set

-- Find / search
map("n", "<C-p>", cmd.files, { desc = "Find files" })
map("n", "<leader>g", function()
  cmd.live_grep()
end, { desc = "Live grep" })
map("n", "<leader>o", cmd.history, { desc = "Recent files" })

-- Replace
map("n", "<leader>rfs", cmd.replace, { desc = "Replace (project)" })
map("n", "<leader>rf", cmd.replace_file, { desc = "Replace (file)" })

-- File tree
map("n", "<C-n>", function()
  pcall(vim.cmd, "NvimTreeToggle")
end, { silent = true, desc = "Toggle file tree" })
map("n", "<leader>n", function()
  pcall(vim.cmd, "NvimTreeFindFile")
end, { silent = true, desc = "Find current file in tree" })

-- Outline (replaces Tagbar)
map("n", "<F8>", function()
  pcall(vim.cmd, "AerialToggle")
end, { silent = true, desc = "Toggle outline" })

-- Floating terminal
map({ "n", "t" }, "<leader>tt", function()
  pcall(vim.cmd, "ToggleTerm")
end, { silent = true, desc = "Toggle terminal" })

-- Transparent background toggle (legacy mapping)
map("n", "<F12>", function()
  require("zw.transparent").toggle()
end, { silent = true, desc = "Toggle transparent" })

-- Maximizer
map("n", "<leader>m", function()
  pcall(vim.cmd, "Maximize")
end, { silent = true, desc = "Maximize window" })

-- Insert inbox block (keep old behavior)
map("n", "<leader>x", "oinbox::<CR>::inbox<Esc>O", { noremap = true, silent = true })
map("i", "<leader>x", "<Esc>oinbox::<CR>::inbox<Esc>O", { noremap = true, silent = true })

-- Inbox (floating editor)
map("n", "<leader>i", function()
  require("zw.inbox").open()
end, { silent = true, desc = "Open inbox" })

-- Insert date-time
map("i", "<F5>", function()
  return os.date("%Y-%m-%d %H:%M:%S")
end, { expr = true, noremap = true, silent = true })

