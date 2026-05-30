" Lightweight TSX syntax. Reuse the TypeScript rules and add cheap JSX tag
" matching only.
if exists('b:current_syntax')
  finish
endif

runtime! syntax/typescript.vim
unlet! b:current_syntax

syntax match typescriptLightJsxTag "</\?\h[-A-Za-z0-9_:.]*"
syntax match typescriptLightJsxTagEnd "/\?>"

highlight default link typescriptLightJsxTag Identifier
highlight default link typescriptLightJsxTagEnd Identifier

let b:current_syntax = 'typescriptreact_light'
