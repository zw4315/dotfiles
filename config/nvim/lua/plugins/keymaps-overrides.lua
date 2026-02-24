return {
  -- 保留 <leader>gg 给 Diffview（覆盖 LazyVim lazygit 映射）
  {
    "snacks.nvim",
    keys = {
      { "<leader>gg", false },
    },
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  -- NERDTree-style keymaps
                  ["go"] = { { "confirm", "focus_list" } },
                  ["gi"] = { { "edit_split", "focus_list" } },
                  ["gs"] = { { "edit_vsplit", "focus_list" } },
                },
              },
            },
          },
        },
      },
    },
  },
}
