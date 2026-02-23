local function style_file()
  return vim.fn.stdpath("state") .. "/nerd-font-style"
end

local function read_style()
  local path = style_file()
  local f = io.open(path, "r")
  if not f then
    return nil
  end

  local value = f:read("*l")
  f:close()
  if value == "ascii" or value == "glyph" then
    return value
  end
  return nil
end

local function write_style(style)
  local dir = vim.fn.fnamemodify(style_file(), ":h")
  vim.fn.mkdir(dir, "p")

  local f = io.open(style_file(), "w")
  if not f then
    return
  end
  f:write(style)
  f:close()
end

return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    cmd = { "NerdFontToggle", "NerdFontOn", "NerdFontOff" },
    keys = {
      {
        "<leader>uI",
        "<cmd>NerdFontToggle<cr>",
        desc = "Toggle Nerd Font Icons",
      },
    },
    opts = function(_, opts)
      opts = opts or {}
      opts.style = read_style() or opts.style or "glyph"
      return opts
    end,
    config = function(_, opts)
      local mini_icons = require("mini.icons")
      local config_opts = vim.deepcopy(opts or {})
      mini_icons.setup(config_opts)

      local function apply_style(style)
        if style ~= "glyph" and style ~= "ascii" then
          return
        end

        config_opts.style = style
        write_style(style)
        mini_icons.setup(config_opts)
        vim.cmd("redraw!")
        vim.notify("mini.icons style: " .. style, vim.log.levels.INFO)
      end

      local function define_command(name, fn)
        pcall(vim.api.nvim_del_user_command, name)
        vim.api.nvim_create_user_command(name, fn, {})
      end

      define_command("NerdFontToggle", function()
        local next_style = (config_opts.style == "glyph") and "ascii" or "glyph"
        apply_style(next_style)
      end)

      define_command("NerdFontOn", function()
        apply_style("glyph")
      end)

      define_command("NerdFontOff", function()
        apply_style("ascii")
      end)
    end,
  },
}
