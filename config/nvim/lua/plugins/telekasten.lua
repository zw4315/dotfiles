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
      -- Avoid LazyVim's <leader>z* mappings (zen/zoom) which can be `nowait`.
      -- Also avoid LazyVim's <leader>n (New File).
      { "<leader>kp", function() require("telekasten").panel() end, desc = "Notes Panel" },
      { "<leader>kf", function() require("telekasten").find_notes() end, desc = "Notes Find" },
      { "<leader>kg", function() require("telekasten").search_notes() end, desc = "Notes Search" },
      { "<leader>kn", function() require("telekasten").new_note() end, desc = "Notes New" },
      { "<leader>kl", function() require("telekasten").follow_link() end, desc = "Notes Follow Link" },
      { "<leader>kt", function() require("telekasten").goto_today() end, desc = "Notes Today" },
      { "<leader>kw", function() require("telekasten").goto_thisweek() end, desc = "Notes This Week" },
      {
        "<leader>kc",
        function()
          local tk = require("telekasten")
          if type(tk.show_calendar) == "function" then
            tk.show_calendar()
          else
            vim.cmd("Calendar")
          end
        end,
        desc = "Notes Calendar",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "mattn/calendar-vim",
    },
    opts = function()
      local notes_dir = vim.fn.expand(vim.env.ZK_NOTES_DIR or "~/mgnt/agenda")
      vim.fn.mkdir(notes_dir, "p")
      vim.fn.mkdir(notes_dir .. "/daily", "p")
      vim.fn.mkdir(notes_dir .. "/weekly", "p")
      vim.fn.mkdir(notes_dir .. "/templates", "p")
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
