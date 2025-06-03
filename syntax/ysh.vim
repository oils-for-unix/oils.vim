" Vim syntax file
" Language: YSH
"
" Claude AI helped a lot here, because vim config confuses me
" But I've kept this initial version very bare-bones.  We can iterate on it.
"
" Larger version, with a few issues: https://github.com/sj2tpgk/vim-oil

if exists("b:current_syntax")
  finish
endif

" This avoids problems with long multiline strings
:syntax sync minlines=200

" YSH keywords (not sure how to do leading =)
syn keyword yshKeyword proc func const var setvar setglobal call

" End-of-line comments
syn match yshComment '#.*$'

" TODO:
" - rarely used: $"" prefix
"   - also leaving out bash-style $'\n' strings
"
" More structure
"
" - backslash escapes within strings:
"    - \" \$ in double quotes
"    - \u{123456} in J8-style strings
"
" - Is there way to understand recursion like ${a:-'foo'}?  Or just leave that
"   out
" - There is also recursion of $(hostname) and such.
"
" - Here docs?  They are hard, could leave them out of YSH

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region yshSingleQuoteString start="'" end="'"

" Double-quoted strings
syn region yshDoubleQuoteString start='"' skip='\\.' end='"' contains=yshInterpolation

" String interpolation within double quotes
syn match yshInterpolation "\$\w\+" contained

" Python-like triple-quoted strings
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region yshTripleSingleQuoteString start="'''" end="'''"
syn region yshTripleDoubleQuoteString start='"""' end='"""' contains=yshInterpolation

" Define highlighting
hi def link yshComment Comment
hi def link yshKeyword Keyword

hi def link rawString String
hi def link j8String String
hi def link yshSingleQuoteString String
hi def link yshDoubleQuoteString String

hi def link yshInterpolation Special

hi def link tripleRawString String
hi def link tripleJ8String String
hi def link yshTripleSingleQuoteString String
hi def link yshTripleDoubleQuoteString String

let b:current_syntax = "ysh"
