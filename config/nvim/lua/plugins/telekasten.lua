return {
  {
    "mattn/calendar-vim",
    cmd = { "Calendar" },
  },
  {
    "renerocksai/telekasten.nvim",
    lazy = true,
    cmd = { "Telekasten" },
    keys = function()
      -- Avoid LazyVim's <leader>z (zen/zoom) and <leader>n (new file).
      local notes_dir = vim.fn.expand(vim.env.ZK_NOTES_DIR or "~/mgnt/notes")

      local function telescope_find_files()
        require("telescope.builtin").find_files({
          cwd = notes_dir,
          hidden = true,
          follow = true,
        })
      end

      local function telescope_live_grep()
        require("telescope.builtin").live_grep({
          cwd = notes_dir,
        })
      end

      local function tk_cmd(sub, fallback)
        return function()
          local ok = pcall(vim.cmd, "Telekasten " .. sub)
          if not ok and fallback then
            fallback()
          end
        end
      end

      return {
        { "<leader>kp", tk_cmd("panel"), desc = "Notes Panel" },
        { "<leader>kt", tk_cmd("goto_today"), desc = "Notes Today" },
        { "<leader>kw", tk_cmd("goto_thisweek"), desc = "Notes This Week" },
        { "<leader>kn", tk_cmd("new_note"), desc = "Notes New" },
        { "<leader>kl", tk_cmd("follow_link"), desc = "Notes Follow Link" },
        { "<leader>kc", tk_cmd("show_calendar", function() vim.cmd("Calendar") end), desc = "Notes Calendar" },
        -- Use Telescope for navigation/search (avoids Telekasten's "insert link" behavior in non-modifiable buffers).
        { "<leader>kf", telescope_find_files, desc = "Notes Find" },
        { "<leader>kg", telescope_live_grep, desc = "Notes Search" },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "mattn/calendar-vim",
    },
    opts = function()
      local notes_dir = vim.fn.expand(vim.env.ZK_NOTES_DIR or "~/mgnt/notes")
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
