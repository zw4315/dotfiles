return {
  {
    "mattn/calendar-vim",
    cmd = { "Calendar" },
  },
  {
    "renerocksai/telekasten.nvim",
    lazy = true,
    cmd = { "Telekasten" },
    keys = {
      { "<leader>zp", function() require("telekasten").panel() end, desc = "ZK Panel" },
      { "<leader>zf", function() require("telekasten").find_notes() end, desc = "ZK Find Notes" },
      { "<leader>zg", function() require("telekasten").search_notes() end, desc = "ZK Search Notes" },
      { "<leader>zn", function() require("telekasten").new_note() end, desc = "ZK New Note" },
      { "<leader>zl", function() require("telekasten").follow_link() end, desc = "ZK Follow Link" },
      { "<leader>zt", function() require("telekasten").goto_today() end, desc = "ZK Today" },
      { "<leader>zw", function() require("telekasten").goto_thisweek() end, desc = "ZK This Week" },
      { "<leader>zc", "<cmd>Calendar<cr>", desc = "Calendar" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "mattn/calendar-vim",
    },
    opts = function()
      local notes_dir = vim.fn.expand(vim.env.ZK_NOTES_DIR or "~/mgnt/agenda")
      return {
        home = notes_dir,
        dailies = notes_dir .. "/daily",
        weeklies = notes_dir .. "/weekly",
        templates = notes_dir .. "/templates",
        template_new_daily = notes_dir .. "/templates/daily.md",
        template_new_weekly = notes_dir .. "/templates/weekly.md",

        take_over_my_home = false,
        auto_set_filetype = false,

        plug_into_calendar = true,
        calendar_opts = {
          weeknm = 1,
          calendar_monday = 1,
        },
      }
    end,
  },
}

