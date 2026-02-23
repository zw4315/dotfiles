-- vim-interestingwords: 同时高亮多个不同的词
-- 使用 <leader>k 高亮当前词，<leader>K 清除所有高亮
return {
  {
    "lfv89/vim-interestingwords",
    event = "VeryLazy",
    init = function()
      -- 禁用默认映射，使用自定义
      vim.g.interestingWordsDefaultMappings = 0

      -- 自定义颜色（可选）
      vim.g.interestingWordsGUIColors = {
        "#8CCBEA", -- 浅蓝
        "#A4E57E", -- 浅绿
        "#FFDB72", -- 黄色
        "#FF7272", -- 红色
        "#FFB3FF", -- 粉色
        "#9999FF", -- 紫色
      }
    end,
    keys = {
      -- 高亮/取消高亮当前词
      {
        "<leader>k",
        ":call InterestingWords('n')<cr>",
        desc = "Toggle highlight word",
        mode = "n",
      },
      -- 高亮选中的文本
      {
        "<leader>k",
        ":call InterestingWords('v')<cr>",
        desc = "Highlight selection",
        mode = "v",
      },
      -- 清除所有高亮
      {
        "<leader>K",
        ":call UncolorAllWords()<cr>",
        desc = "Clear all highlights",
        mode = "n",
      },
    },
  },
}
