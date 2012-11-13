" File: shebang.vim
" Author: Vital Kudzelka
" Version: 0.1
" Description: Filetype detection by shebang at file.
" Last Modified: Nov 13, 2012

if exists('g:loaded_shebang') || &cp || version < 700
  finish
endif
" let g:loaded_shebang = 1

" internal shebang store
let s:shebangs = {}

if did_filetype()
  finish
endif

" Add shebang pattern to filetype
command! -nargs=* -bang AddShebangPattern
      \ call s:add_shebang_pattern(<f-args>, <bang>0)

fun! s:add_shebang_pattern(filetype, pattern, force)
  try
    if !a:force && has_key(s:shebangs, a:pattern)
      throw string(a:pattern) . " is already defined, use ! to overwrite."
    endif

    let s:shebangs[a:pattern] = a:filetype
  catch
    call shebang#error("Add shebang filetype: " . v:exception)
  endtry
endf


" set valid filetype based on shebang line
command! -nargs=0 Shebang call s:shebang()

fun! s:shebang()
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
    call shebang#error(v:exception)
  endtry
endf

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


map <silent> <Plug>(shebang-do) :Shebang<CR>
map <silent> !# <Plug>(shebang-do)


" try to detect filetype after enter to buffer
au! BufEnter * if !did_filetype() | call s:shebang() | endif
