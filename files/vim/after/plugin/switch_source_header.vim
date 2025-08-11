" 切换头文件，源文件
function! SwitchSourceHeader()
    let l:ext = expand('%:e')
    let l:newfile = ''

    if l:ext ==# 'h'
        let l:newfile = expand('%:r') . '.cpp'
        if !filereadable(l:newfile)
            let l:newfile = expand('%:r') . '.c'
        endif
        if !filereadable(l:newfile)
            let l:newfile = ''
        endif
    elseif l:ext ==# 'cpp' || l:ext ==# 'c'
        let l:newfile = expand('%:r') . '.h'
        if !filereadable(l:newfile)
            let l:newfile = ''
        endif
    endif

    if l:newfile != ''
        execute 'edit' l:newfile
    else
        " 推测目标文件名
        if l:ext ==# 'h'
            let l:newfile = expand('%:r') . '.cpp'
        elseif l:ext ==# 'cpp' || l:ext ==# 'c'
            let l:newfile = expand('%:r') . '.h'
        else
            echo "Not a source or header file"
            return
        endif

        " 询问是否新建
        let l:ans = confirm("File not found. Create " . l:newfile . " ?", "&Yes\n&No", 2)
        if l:ans == 1
            execute 'edit' l:newfile
        endif
    endif
endfunction

" 快捷键绑定
nnoremap <Leader>sh :call SwitchSourceHeader()<CR>
