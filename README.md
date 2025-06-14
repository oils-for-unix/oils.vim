Vim Syntax Highlighting for Oils
====

This repo has an accurate Vim syntax highlighter for YSH.

(Note: most editors have shell plugins, so they already understand OSH syntax!)

## Installation

I use [vim-plug][], which is configured in your `~/.vimrc` like this:

    call plug#begin()
    
    Plug 'https://github.com/oils-for-unix/oils.vim'
    
    call plug#end()

[vim-plug]: https://github.com/junegunn/vim-plug

## Configuration

YSH has more syntax than say Java, which can make it harder to pick colors.  My
vimrc overrides these colors:

    let g:ysh_expr_color = 20        " blue  
    let g:ysh_sigil_pair_color = 55  " purple
    let g:ysh_var_sub_color = 89     " lighter purple

    let g:ysh_proc_name_color = 55   " purple
    let g:ysh_func_name_color = 89   " lighter purple

## For contributors

To test locally, temporarily change the line to point at a local copy:

    Plug '~/git/oils-for-unix/oils.vim'

Run all tests:

    ./run.sh all-tests

Export `testdata/` as HTML, and publish it;

    ./run.sh write-html
    ./run.sh deploy-html

And then go to:

- <http://pages.oils.pub/>
  - source: <https://github.com/oils-for-unix/oils-for-unix.github.io>

### Write Your Own YSH Syntax Highlighter

I wrote this doc after writing the Vim highlighter:

- [Three Algorithms for YSH Syntax Highlighting](doc/algorithms.md)
  - Coarse Parsing - three steps, with **screenshots**
  - Context-free parsing
  - Full parsing
- [doc/notes.md](doc/notes.md)

## Links

Here's an alternative plugin supports more features:

- <https://github.com/sj2tpgk/vim-oil>

Though I found an issue where it incorrectly highlighted single quotes within
`#` comments.

### Code Hosts

This repo is hosted at:

- <https://github.com/oils-for-unix/oils.vim/>
- <https://codeberg.org/oils/oils.vim>

---

![Stages of Coarse Parsing](https://pages.oils.pub/oils-vim/screenshots/side-by-side.png)
