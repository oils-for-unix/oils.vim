" Vim syntax file
" Language: YSH
"
" Claude AI helped a lot here, because vim config confuses me
" But I've kept this initial version very bare-bones.  We can iterate on it.
"
" Larger version, with a few issues: https://github.com/sj2tpgk/vim-oil
"
" I put this in ~/.vim/syntax/ysh.vim
"
" And added this to my ~/.vimrc:
"
" augroup filetypedetect
"  au BufNewFile,BufRead *.ysh setf ysh
" augroup END

if exists("b:current_syntax")
  finish
endif

" This avoids problems with long multiline strings
:syntax sync minlines=200

" End-of-line comments
syn match yshComment "#.*$"

" TODO:
" - J8-style strings b'\n'
" - raw prefix r''
" - rarely used: $"" prefix
"   - also leaving out bash-style $'\n' strings
" - backslash escapes within strings:
"    - \" \$ in double quotes
"    - \u{123456} in J8-style strings
"
" - Is there way to understand recursion like ${a:-'foo'}?  Or just leave that
"   out
" - There is also recursion of $(hostname) and such.
"
" - Here docs?  They are hard, could leave them out of YSH

" Raw
" \< means word boundary, which isn't exactly right, but it's better than not
" including it 
syn region yshRawString start="\<r'" end="'"

syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region yshSingleQuoteString start="'" end="'"

" Double-quoted strings
syn region yshDoubleQuoteString start='"' skip='\\.' end='"' contains=yshInterpolation

" String interpolation within double quotes
syn match yshInterpolation "\$\w\+" contained

" Python-like triple-quoted strings
syn region yshTripleSingleQuoteString start="'''" end="'''"
syn region yshTripleDoubleQuoteString start='"""' end='"""' contains=yshInterpolation

" YSH keywords (not sure about leading =)
syn keyword yshKeyword proc func const var setvar setglobal call

" Define highlighting
hi def link yshComment Comment
hi def link yshKeyword Keyword

hi def link yshRawString String
hi def link j8String String
hi def link yshSingleQuoteString String
hi def link yshDoubleQuoteString String
hi def link yshInterpolation Special

hi def link yshTripleSingleQuoteString String
hi def link yshTripleDoubleQuoteString String

let b:current_syntax = "ysh"
