-- UI configuration to fix icon display issues
-- If Nerd Fonts are not installed, icons show as "?"
-- This configuration replaces icons with text symbols

return {
  -- Disable nvim-web-devicons to avoid ? symbols
  {
    "nvim-tree/nvim-web-devicons",
    enabled = false,
  },
  
  -- Configure LazyVim to use text icons instead of Nerd Font icons
  {
    "LazyVim/LazyVim",
    opts = {
      icons = {
        diagnostics = {
          Error = "E ",
          Warn = "W ",
          Hint = "H ",
          Info = "I ",
        },
        git = {
          added = "+",
          modified = "~",
          removed = "-",
        },
        kinds = {
          Array = "[]",
          Boolean = "T/F",
          Class = "C",
          Color = "#",
          Control = "@",
          Collapsed = "▸",
          Constant = "π",
          Constructor = "new",
          Copilot = "AI",
          Enum = "E",
          EnumMember = "e",
          Event = "!",
          Field = ".",
          File = "F",
          Folder = "D",
          Function = "ƒ",
          Interface = "I",
          Key = "K",
          Keyword = "kw",
          Method = "M",
          Module = "mod",
          Namespace = "ns",
          Null = "Ø",
          Number = "123",
          Object = "{}",
          Operator = "+",
          Package = "pkg",
          Property = "P",
          Reference = "ref",
          Snippet = "snp",
          String = '""',
          Struct = "S",
          Text = "T",
          TypeParameter = "T",
          Unit = "U",
          Value = "V",
          Variable = "X",
        },
      },
    },
  },
}
