## vim setting
- 当前的做法是自己配的特定插件的复杂 keymap:customized complex function 放在 after/plugins/xxx.vim, 这个文件夹下的 .vim 文件会被 vim 运行时自动加载
- 这些复杂函数的具体实现, 放在 autoload 文件夹内, 这里的模块属于懒加载, 如果没调用, 就不会加载
