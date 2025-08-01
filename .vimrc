" ------------------------------
" 基础设置
" ------------------------------
set nocompatible
set number
set relativenumber
set autochdir
set hlsearch
set wildmenu
set wildmode=longest:full,full
set path+=**

" ------------------------------
" 折叠设置：按语法折叠函数块
" ------------------------------
set foldmethod=syntax
set foldlevel=99
set foldenable

" ------------------------------
" 插件系统：vim-plug
" ------------------------------
call plug#begin('~/.vim/plugged')

" 文件导航与快速编辑
Plug 'preservim/nerdtree'              " 文件树
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " 模糊搜索
Plug 'junegunn/fzf.vim'

" 语法增强
Plug 'sheerun/vim-polyglot'            " 多语言语法支持（C++增强）
Plug 'octol/vim-cpp-enhanced-highlight' " C++ 类型、模板等额外高亮
Plug 'morhetz/gruvbox'
Plug 'joshdick/onedark.vim'

" 括号/引号自动补全
Plug 'tpope/vim-surround'
Plug 'szw/vim-maximizer'

call plug#end()

" ------------------------------
" 启用插件、语法、配色
" ------------------------------
filetype plugin indent on
syntax enable
"set termguicolors
set notermguicolors
set t_Co=256
colorscheme onedark
"colorscheme gruvbox  " 可改为 gruvbox、nord、onedark 等

" ------------------------------
" 快捷键配置
" ------------------------------
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <Leader>n :NERDTreeFind<CR>
nnoremap <silent> <C-p> :Files<CR>


" toggle 最大化当前窗口
nnoremap <silent> <leader>m :MaximizerToggle<CR>
nnoremap <silent> <Leader>= :set nowinfixwidth<Bar>wincmd =<CR>

" cscope
if has("cscope")
    set cscopequickfix=s-,c-,d-,i-,t-,e-
    set cscopetag
    set csto=0
    set cst
    set nocsverb
    " 自动加载 cscope 数据库
    if filereadable("cscope.out")
        cs add cscope.out
    endif
endif

"同时加载 ctags
set tags=./tags

nnoremap <leader>cs :cs find s <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>cc :cs find c <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>cd :cs find d <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>cg :cs find g <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>ct :cs find t <C-R>=expand("<cword>")<CR><CR>

" 在 Vim 中绑定快捷键（类似 LSP）
nnoremap <silent> <Leader>gd :!global -d <C-R>=expand("<cword>")<CR><CR>
nnoremap <silent> <Leader>gr :!global -r <cword><CR>

