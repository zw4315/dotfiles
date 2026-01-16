# dotfiles

My minimal configuration for a development environment.

## Install (auto)

1. run the following command in ubuntu
```bash
mkdir -p ~/repo && cd ~/repo
git clone git@github.com:zw4315/dotfiles.git
cd dotfiles
curl -sL https://raw.githubusercontent.com/zw4315/dotfiles/master/setup | bash
```

2. Vim: after entering vim, run the following cmd
```vim
:plugInstall
```

3. Neovim: after entering `nvim`, run the following cmd (first run will bootstrap `lazy.nvim`)
```vim
:Lazy sync
```

## dirs Explain

- vim/after/plugin: 下面放一些补充, 例如在高亮插件的基础上, 写一些自己的函数
- nvim: Neovim 配置目录（会链接到 `~/.config/nvim`）


## How to use

- hh 高亮 toggle
- hc 不改变高亮状态的情况下, 查询当前词是第几个
- HH remove all highlight
