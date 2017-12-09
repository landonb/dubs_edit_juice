" File: dubs_edit_juice.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Last Modified: 2017.12.08
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: EditPlus-inspired editing mappings
" License: GPLv3
" vim:tw=0:ts=2:sw=2:et:norl:
" -------------------------------------------------------------------
" Copyright © 2009, 2015-2017 Landon Bouma.
"
" This file is part of Dubsacks.
"
" Dubsacks is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
"
" Dubsacks is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with Dubsacks. If not, see <http://www.gnu.org/licenses/>
" or write Free Software Foundation, Inc., 51 Franklin Street,
"                     Fifth Floor, Boston, MA 02110-1301, USA.
" ===================================================================

" ------------------------------------------
" About:

" These mappings make reStructered Text-style section headers.
"
"   E.g., write a header:
"
"     My Awesome Section Header
"
"   and then switch to normal mode and type \#
"   (first a backslash, then shift-3), and your
"   text transforms to:
"
"     #########################
"     My Awesome Section Header
"     #########################

" HINT: To test:
"   unlet g:plugin_edit_juice_resections_vim
"   Then press <F9> to reload script.
unlet g:plugin_edit_juice_resections_vim

if exists("g:plugin_edit_juice_resections_vim") || &cp
  finish
endif
let g:plugin_edit_juice_resections_vim = 1

" -------------------------------------------------------------------------
" 2017-03-28: [lb] now tired of manually setting up reST header decoration.
" -------------------------------------------------------------------------

" The section delimiter hierarchy I commonly use in reST documents:
"    ###################
"    ===================
"    -------------------
"    ^^^^^^^^^^^^^^^^^^^
"    ~~~~~~~~~~~~~~~~~~~
"    '''''''''''''''''''
"    :::::::::::::::::::

" I.e.,: ``### === --- ^^^ ~~~ ''' :::``

" Acceptable adornments (14 total):
"   - = ~ ` : ' " ~ ^ _ * + # < >
" Ones I don't normally use (7):
"   ` " _ * + < >
" 2017-12-08: Actually, all punctuation is acceptable!
"   And now that Dubsacks rst.vim supports 'em all, so
"   we we!
" The Forgotten Punctuation
"   $ % & ( ) [ ] { } | \ ; : , . / ?
"

" Hints about the motion, yank, and put commands used below.
"
" With a little help from:
"
"   http://vim.wikia.com/wiki/Underline_using_dashes_automatically
"
" HINT: Ctrl-Q is the CTRL-V-alternative, since Ctrl-V is paste.
"        Ctrl-Q starts a blockwise Visual selection.
"       $ selects to the end of the line.
"       r starts a replace,
"        and the last character is the replacement character.
"       Oh, and you know yyp, right?
"        y is a yank, and yy is a yank line, and p is a put.
"       And then yykP: k moves up a line, and P puts above.
"
" HINT: Replace selected: Select text, then <C-O>rX
"   where X is the replacement character.
"
" For the populate ornament characters, and those that occupy
" their key along on an American English keyboard:
"   Map <Leader>{char} to underline using the indicated header character.
"   Map <Leader>{CHAR} to underline and overline using said character.
" For all ornament characters, you can
"   <leader>-<leader>-{char}
" or
"   <leader>-<shift-leader>-{char}
" to select the underline or underline/overline character.

function! s:map_shift_only_punctuation(knum, punc)
  "echom "knum:punc: " . a:knum . ':' . a:punc
  exe 'nnoremap <Leader>' . a:knum . ' yyp<C-Q>$r' . a:punc
  exe 'nnoremap <Leader>' . a:punc . ' yyp<C-Q>$r' . a:punc . 'yykP'
  " 2017-12-08: What's the point of this? And other <l><l>; they seem redundant.
  "exe 'nnoremap <Leader><Leader>' . a:punc . ' yyp<C-Q>$r' . a:punc
  exe 'nnoremap <Leader>\|' . a:punc . ' yyp<C-Q>$r' . a:punc . 'yykP'
endfunction

function! s:map_lower_or_upper_punctuation(punc)
  "echom "punc: " . a:punc
  exe 'nnoremap <Leader>' . a:punc . ' yyp<C-Q>$r' . a:punc
  exe 'nnoremap <Leader>\|' . a:punc . ' yyp<C-Q>$r' . a:punc . 'yykP'
endfunction

function! s:map_insider_punctuation(lpunc, rpunc)
  " (((((((((((((((((((((((((((((((((((
  " Inside Inside Inside The Delimiters
  " )))))))))))))))))))))))))))))))))))
  "echom "lpunc:rpunc: " . a:lpunc . ':' . a:rpunc
  exe 'nnoremap <Leader>' . a:lpunc . a:rpunc . ' yyP<C-Q>$r' . a:lpunc . '<DOWN>yyp<C-Q>$r' . a:rpunc . '<UP>'
endfunction

function! s:map_doubled_punctuation(dpunc)
  "echom "dpunc: " . a:dpunc
  exe 'nnoremap <Leader>' . a:dpunc . a:dpunc . ' yyp<C-Q>$r' . a:dpunc . '<UP>'
  exe 'nnoremap <Leader>\|' . a:dpunc  . a:dpunc . ' yyp<C-Q>$r' . a:dpunc . 'yykP' . '<DOWN>'
endfunction

function! s:map_special_keys()
  " We don't map '+' because the reST syntax parser sees
  "   that as a table delimiter, so let's just not use it.
  " Instead, map <Leader>= to under-section with equal signs
  "   and then map <Leader>+ to over-under-section with equals.
  "
  "   =======
  "   SECTION
  "   =======
  "
  nnoremap <Leader>= yyp<C-Q>$r=
  nnoremap <Leader>+ yyp<C-Q>$r=yykP
  nnoremap <Leader><Leader>= yyp<C-Q>$r=
  nnoremap <Leader>\|+ yyp<C-Q>$r=yykP

  " The pipe character is not sent to map_lower_or_upper_punctuation
  " because it needs to be escaped.
  nnoremap <Leader>\| yyp<C-Q>$r\|
  nnoremap <Leader>\|\| yyp<C-Q>$r\|yykP
endfunction

function! s:apply_leadership_punctuation()
  let l:number_punc = [
    \ ['1', '!'], ['2', '@'], ['3', '#'], ['4', '$'],
    \ ['5', '%'], ['6', '^'], ['7', '&'], ['8', '*']]

  let l:simple_punc = [
    \ '`', '~', '-', '_', '\', ';', ':', ',', '.', '?', "'", '"']
  " NOTE: '\' is a little weird, since it's the leader key.
  "         It works after Vim takes a brief pause to see if
  "         more keys follow. We can skip it.
  " \ '\'

  let l:crazy_punc = [
    \ ['(', ')'], [')', '('],
    \ ['[', ']'], [']', '['],
    \ ['{', '}'], ['}', '{'],
    \ ['<', '>'], ['>', '<'],
    \ ['\', '/'], ['/', '\']]

  let l:double_punc = [
    \ '(', ')', '[', ']', '{', '}', '<', '>', '\', '/']

  for [l:knum, l:punc] in l:number_punc
    call s:map_shift_only_punctuation(l:knum, l:punc)
  endfor

  for l:punc in l:simple_punc
    call s:map_lower_or_upper_punctuation(l:punc)
  endfor

  for [l:lpunc, l:rpunc] in l:crazy_punc
    call s:map_insider_punctuation(l:lpunc, l:rpunc)
  endfor

  for l:dunc in l:double_punc
    call s:map_doubled_punctuation(l:dunc)
  endfor

  call s:map_special_keys()
endfunction

call s:apply_leadership_punctuation()

