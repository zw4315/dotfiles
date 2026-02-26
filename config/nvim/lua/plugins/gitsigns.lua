return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      -- Override default gitsigns keymaps to free up <leader>gh for diffview
      -- Use <leader>gk prefix for hunks (gk = "g"it "k"unk/hunk)
      opts.on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation (keep default ]c and [c)
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        -- Hunk operations (using gk prefix instead of gh)
        map("n", "<leader>gks", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>gkr", gs.reset_hunk, "Reset Hunk")
        map("v", "<leader>gks", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage Hunk")
        map("v", "<leader>gkr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset Hunk")
        map("n", "<leader>gku", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gkp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gkb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>gkB", gs.toggle_current_line_blame, "Toggle Line Blame")

        -- Diff operations
        map("n", "<leader>gkd", gs.diffthis, "Diff This")
        map("n", "<leader>gkD", function()
          gs.diffthis("~")
        end, "Diff This ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end

      return opts
    end,
  },
}
