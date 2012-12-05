" File: shebang.vim
" Author: Vital Kudzelka
" Version: 0.2
" Description: Filetype detection by shebang at file.
" Last Modified: December 05, 2012

" Guard {{{

if exists('g:loaded_shebang') || &cp || version < 700 || did_filetype()
  finish
endif
let g:loaded_shebang = 1

" }}}
" Default settings {{{

" swallow error messages if not set
call shebang#default('g:shebang_enable_debug', 0)

" }}}
" Plugin {{{

" internal shebang store
let s:shebangs = {}

command! -nargs=* -bang AddShebangPattern
      \ call s:add_shebang_pattern(<f-args>, <bang>0)
fun! s:add_shebang_pattern(filetype, pattern, force) " {{{ add shebang pattern to filetype
  try
    if !a:force && has_key(s:shebangs, a:pattern)
      throw string(a:pattern) . " is already defined, use ! to overwrite."
    endif

    let s:shebangs[a:pattern] = a:filetype
  catch
    call shebang#error("Add shebang pattern: " . v:exception)
  endtry
endf " }}}

command! -nargs=0 Shebang call s:shebang()
fun! s:shebang() " {{{ set valid filetype based on shebang line
  try
    let line = getline(1)
    if empty(line)
      return
    endif

    let type = shebang#detect_filetype(line, s:shebangs)
    if empty(type)
      throw "Filetype detection failed for line: '" . line . "'"
    endif
    exe 'setfiletype ' . type
  catch
    if g:shebang_enable_debug
      call shebang#error(v:exception)
    endif
  endtry
endf " }}}

" }}}
" Default patterns {{{

" add default shebang patterns, paths of the following form are handled:
" /bin/interpreter
" /usr/bin/interpreter
" /bin/env interpreter
" /usr/bin/env interpreter
" support most of shells: bash, sh, zsh, csh, ash, dash, ksh, pdksh, mksh, tcsh
AddShebangPattern! sh         ^#!.*\s\+\(ba\|c\|a\|da\|k\|pdk\|mk\|tc\)\?sh\>
AddShebangPattern! zsh        ^#!.*\s\+zsh\>
" ruby
AddShebangPattern! ruby       ^#!.*\s\+ruby\>
AddShebangPattern! ruby       ^#!.*[s]\?bin/ruby\>
" python
AddShebangPattern! python     ^#!.*\s\+python\>
AddShebangPattern! python     ^#!.*[s]\?bin/python\>
" js
AddShebangPattern! javascript ^#!.*\s\+node\>

" }}}
" Key bindings {{{

map <silent> !# :Shebang<CR>

" }}}
" Autocommands {{{

augroup shebang
  au!
  " try to detect filetype after enter to buffer
  au BufEnter * if !did_filetype() | call s:shebang() | endif
augroup END

" }}}
