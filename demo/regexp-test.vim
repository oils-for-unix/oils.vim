" Testing Vim's NFA regex engine.
"
" :help two-engines

" somehow 'echo' doesn't sneeded for
"redir > /dev/stdout #_tmp/regexp-test.log
redir > _tmp/regexp-test.log

" auto (the default)
set regexpengine=0
" old
"set regexpengine=1
" new NFA
" set regexpengine=2

" matching with backreference
echo '=== backref'
let pat = '\(\w\)\1'
echo match('hi', pat)
echo match('hh', pat)
echo ''

" \v very magic is more readable
echo '=== \v'
let pat = '\v(\w)\1'
echo match('hi', pat)
echo match('hh', pat)

" Force new engine
echo '=== force NFA engine'
let pat = '\%#=2\(\w\)\1'
echo match('hi', pat)
echo match('hh', pat)
echo ''

" echo match('hi', '\%#=1\(\w\)\1')
" echo match('hh', '\%#=1\(\w\)\1')

" Example from Claude: they both work the same
let text = "abc123abc456abc"
" Old engine
echo matchstr(text, '\%#=1\(\w\+\)\d\+\1')
echo matchstr(text, '\%#=2\(\w\+\)\d\+\1')

echo '=== + operator'
let pat = '\v[0-9]+'
echo match('123', pat)
echo match('  123', pat)
echo ''

echo '=== beginning of line'
let pat = '\v^[0-9]+'
echo match('123', pat)
echo match('  123', pat)
echo match('abc', pat)
echo ''

echo '=== beginning of line or whitespace'
let pat = '\v(^|\s*)[0-9]+'
echo match('123', pat)
echo match('  123', pat)
echo match('abc', pat)
echo ''

" What about \z?  That is exclusive to syn match, syn region
" Gah

echo '=== beginning of line or whitespace'
let pat = '\v(^|\s*)[0-9]+'
echo match('123', pat)
echo match('  123', pat)
echo match('abc', pat)
echo ''

echo 'END regexp-test'
echo ''

" Things to test
" - ysh.vim regexes
" - anchor to beginning of line?

redir END
