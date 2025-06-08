" Testing Vim's NFA regex engine.
"
" :help two-engines

" auto (the default)
set regexpengine=0
" old
"set regexpengine=1
" new NFA
" set regexpengine=2

" matching with backreference
echo match('hi', '\(\w\)\1')
echo match('hh', '\(\w\)\1')

" \v very magic is more readable
echo match('hi', '\v(\w)\1')
echo match('hh', '\v(\w)\1')

" Force new engine
echo match('hi', '\%#=2\(\w\)\1')
echo match('hh', '\%#=2\(\w\)\1')

" echo match('hi', '\%#=1\(\w\)\1')
" echo match('hh', '\%#=1\(\w\)\1')


" Example from Claude: they both work the same
let text = "abc123abc456abc"
" Old engine
echo matchstr(text, '\%#=1\(\w\+\)\d\+\1')
" NFA
echo matchstr(text, '\%#=2\(\w\+\)\d\+\1')
