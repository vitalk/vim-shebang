" File: shebang.vim
" Author: Vital Kudzelka
" Description: Filetype detection by shebang at file.


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
fun! s:add_shebang_pattern(filetype, pattern, ...) " {{{ add shebang pattern to filetype
  if a:0 == 2
    let [pre_hook, force] = [a:1, a:2]
  else
    let [pre_hook, force] = ['', a:000[-1]]
  endif

  try
    if !force && has_key(s:shebangs, a:pattern)
      throw string(a:pattern) . " is already defined, use ! to overwrite."
    endif

    let s:shebangs[a:pattern] = {
          \ 'filetype': a:filetype,
          \ 'pre_hook': pre_hook
          \ }
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

    let match = shebang#detect_filetype(line, s:shebangs)
    if empty(match)
      throw "Filetype detection failed for line: '" . line . "'"
    endif
    exe match.pre_hook
    exe 'setfiletype ' . match.filetype
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
AddShebangPattern! sh         ^#!.*[s]\?bin/sh\>    let\ b:is_sh=1|if\ exists('b:is_bash')|unlet\ b:is_bash|endif
AddShebangPattern! sh         ^#!.*[s]\?bin/bash\>  let\ b:is_bash=1|if\ exists('b:is_sh')|unlet\ b:is_sh|endif
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
