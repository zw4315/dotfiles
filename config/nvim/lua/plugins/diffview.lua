return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview Repo History" },
      {
        "<leader>gc",
        function()
          vim.ui.input({ prompt = "Diff range (e.g. abc123..def456 or main...HEAD): " }, function(input)
            if not input or vim.trim(input) == "" then
              return
            end
            vim.cmd("DiffviewOpen " .. vim.trim(input))
          end)
        end,
        desc = "Diffview Compare Range",
      },
    },
    opts = {
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
    },
  },
}
