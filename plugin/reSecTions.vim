" File: dubs_edit_juice.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Last Modified: 2017.12.19
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: EditPlus-inspired editing mappings
" License: GPLv3
" vim:tw=0:ts=2:sw=2:et:norl:
" -------------------------------------------------------------------
" Copyright © 2009, 2015-2017 Landon Bouma.
"
" This file is part of Dubs Vim.
"
" Dubs Vim is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
"
" Dubs Vim is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with Dubs Vim. If not, see <http://www.gnu.org/licenses/>
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

if exists("g:plugin_edit_juice_resections_vim") || &cp
  " 2019-02-08: This script is now reloadable; you
  " can comment out the `finish` and hit <F9> to see!
  " MAYBE/2019-02-08: Can/Should we remove the `finish`?
  "finish
  :
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
"   And now that Dubs Vim rst.vim supports 'em all, so
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
  exe 'nunmap <Leader>' . a:knum
  exe 'nunmap <Leader>' . a:punc
  exe 'nunmap <Leader>\|' . a:punc
  "
  exe 'nnoremap <Leader>' . a:knum . ' yyp<C-Q>$r' . a:punc . '<UP>'
  exe 'nnoremap <Leader>' . a:punc . ' yyp<C-Q>$r' . a:punc . 'yykP<DOWN>'
  " 2017-12-08: What's the point of this? And other <l><l>; they seem redundant.
  "exe 'nnoremap <Leader><Leader>' . a:punc . ' yyp<C-Q>$r' . a:punc
  exe 'nnoremap <Leader>\|' . a:punc . ' yyp<C-Q>$r' . a:punc . 'yykP<DOWN>'
endfunction

function! s:map_shift_only_punctuation_replace(knum, punc)
  "echom "knum:punc: " . a:knum . ':' . a:punc
  exe 'nunmap <Leader><Leader>' . a:knum
  exe 'nunmap <Leader><Leader>' . a:punc
  exe 'nunmap <Leader><Leader>\|' . a:punc
  "
  exe 'nnoremap <Leader><Leader>' . a:knum . ' <DOWN>dd<UP>yyp<C-Q>$r' . a:punc . '<UP>'
  exe 'nnoremap <Leader><Leader>' . a:punc . ' <UP>dd<DOWN>dd<UP>yyp<C-Q>$r' . a:punc . 'yykP<DOWN>'
  exe 'nnoremap <Leader><Leader>\|' . a:punc . ' <UP>dd<DOWN>dd<UP>yyp<C-Q>$r' . a:punc . 'yykP<DOWN>'
endfunction

function! s:map_shift_only_punctuation_reverse(lower, upper)
  "echom "knum:punc: " . a:knum . ':' . a:punc
  exe 'nunmap <Leader>' . a:lower
  exe 'nunmap <Leader>' . a:upper
  exe 'nunmap <Leader>\|' . a:lower
  "
  exe 'nnoremap <Leader>' . a:lower . ' yyp<C-Q>$r' . a:lower . '<UP>'
  exe 'nnoremap <Leader>' . a:upper . ' yyp<C-Q>$r' . a:lower . 'yykP<DOWN>'
  exe 'nnoremap <Leader>\|' . a:lower . ' yyp<C-Q>$r' . a:lower . 'yykP<DOWN>'
endfunction

function! s:map_lower_or_upper_punctuation(punc)
  "echom "punc: " . a:punc
  exe 'nunmap <Leader>' . a:punc
  exe 'nunmap <Leader>\|' . a:punc
  "
  exe 'nnoremap <Leader>' . a:punc . ' yyp<C-Q>$r' . a:punc . '<UP>'
  exe 'nnoremap <Leader>\|' . a:punc . ' yyp<C-Q>$r' . a:punc . 'yykP<DOWN>'
endfunction

function! s:map_insider_punctuation(lpunc, rpunc)
  " (((((((((((((((((((((((((((((((((((
  " Inside Inside Inside The Delimiters
  " )))))))))))))))))))))))))))))))))))
  "echom "lpunc:rpunc: " . a:lpunc . ':' . a:rpunc
  exe 'nunmap <Leader>' . a:lpunc . a:rpunc
  "
  exe 'nnoremap <Leader>' . a:lpunc . a:rpunc . ' yyP<C-Q>$r' . a:lpunc . '<DOWN>yyp<C-Q>$r' . a:rpunc . '<UP>'
endfunction

function! s:map_doubled_punctuation(dpunc)
  "echom "dpunc: " . a:dpunc
  exe 'nunmap <Leader>' . a:dpunc . a:dpunc
  exe 'nunmap <Leader>\|' . a:dpunc . a:dpunc
  "
  exe 'nnoremap <Leader>' . a:dpunc . a:dpunc . ' yyp<C-Q>$r' . a:dpunc . '<UP>'
  exe 'nnoremap <Leader>\|' . a:dpunc . a:dpunc . ' yyp<C-Q>$r' . a:dpunc . 'yykP' . '<DOWN>'
endfunction

function! s:map_special_keys()
  " We don't use '+' as a section delimiter because the
  "   reST syntax parser sees that as a table delimiter.
  " Instead, map <Leader>= to under-section with equal signs
  "   and then map <Leader>+ to over-under-section with equals.
  "
  "   =======
  "   SECTION
  "   =======
  "
  nunmap <Leader>=
  nunmap <Leader>+
  nunmap <Leader>\|+
  nnoremap <Leader>= yyp<C-Q>$r=<UP>
  nnoremap <Leader>+ yyp<C-Q>$r=yykP<DOWN>
  nnoremap <Leader>\|+ yyp<C-Q>$r=yykP<DOWN>

  " 2019-02-08: Whatever: I couldn't get -d | +d | normal k to work,
  " but that's okay, UP DOWN (LEFT RIGHT) also works! (The minus ``-``
  " key is apparently mapped to NerdTree, so typing ``-d`` does not
  " exactly work, as the minus press immediately triggers NerdTree.)
  " Oh, anyway: this mapping removes the line above and line below,
  " and replaces the section border.
  "   e.g., if::
  "
  "     ======
  "     header got longer
  "     ======
  "
  "   then the mapping could, in one swoop, produce::
  "
  "     =================
  "     header got longer
  "     =================
  nunmap <Leader><Leader>=
  nunmap <Leader><Leader>+
  nnoremap <Leader><Leader>= <DOWN>dd<UP>yyp<C-Q>$r=<UP>
  nnoremap <Leader><Leader>+ <UP>dd<DOWN>dd<UP>yyp<C-Q>$r=yykP<DOWN>

  " The pipe character is not sent to map_lower_or_upper_punctuation
  " because it needs to be escaped.
  nunmap <Leader>\|
  nunmap <Leader>\|\|
  nnoremap <Leader>\| yyp<C-Q>$r\|<UP>
  nnoremap <Leader>\|\| yyp<C-Q>$r\|yykP<DOWN>
endfunction

function! s:apply_leadership_punctuation()
  let l:number_punc = [
    \ ['1', '!'], ['2', '@'], ['3', '#'], ['4', '$'],
    \ ['5', '%'], ['6', '^'], ['7', '&'], ['8', '*'],
    \ ]

  " 2017-12-18: Skip underscore. It is not vertically symmetric,
  "   so looks odd, and I'd prefer to be able to Shift-``-`` to
  "   get an upper and lower dash boundary.
  let l:reverse_punc = [
    \ ['-', '_'],
    \ ]

  let l:simple_punc = [
    \ '`', '~', '-', '\', ';', ':', ',', '.', '?', "'", '"',
    \ ]

  let l:crazy_punc = [
    \ ['(', ')'], [')', '('],
    \ ['[', ']'], [']', '['],
    \ ['{', '}'], ['}', '{'],
    \ ['<', '>'], ['>', '<'],
    \ ['\', '/'], ['/', '\'],
    \ ]

  let l:double_punc = [
    \ '(', ')', '[', ']', '{', '}', '<', '>', '\', '/',
    \ ]

  for [l:knum, l:punc] in l:number_punc
    call s:map_shift_only_punctuation(l:knum, l:punc)
    call s:map_shift_only_punctuation_replace(l:knum, l:punc)
  endfor

  for [l:lower, l:upper] in l:reverse_punc
    call s:map_shift_only_punctuation_reverse(l:lower, l:upper)
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

