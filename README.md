Vim Syntax Highlighting for Oils
====

Right now we're doing YSH only, not OSH.

## Installation

I use [vim-plug][], which is configured in your `~/.vimrc` like this:

    call plug#begin()
    
    Plug 'https://github.com/oils-for-unix/oils.vim'
    
    call plug#end()

[vim-plug]: https://github.com/junegunn/vim-plug

## Configuration

My vimrc overrides these colors:

    let g:ysh_expr_color = 20        " blue  
    let g:ysh_sigil_pair_color = 55  " purple
    let g:ysh_var_sub_color = 89     " lighter purple

    let g:ysh_proc_name_color = 55   " purple
    let g:ysh_func_name_color = 89   " lighter purple

## Local Testing

Temporarily change the line to point at a local copy:

    Plug '~/git/oils-for-unix/oils.vim'

## Links


Here's an alternative plugin supports more features:

- <https://github.com/sj2tpgk/vim-oil>

Though I found an issue where it incorrectly highlighted single quotes within
`#` comments.

So I am trying something simpler.

---

- [notes.md](notes.md)
- [checklist.md](checklist.md)

