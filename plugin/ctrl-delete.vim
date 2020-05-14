" Improved `db` motion, to work at end of line ($).
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Online: https://github.com/landonb/dubs_edit_juice
" License: https://creativecommons.org/publicdomain/zero/1.0/

" ========================================================================

" YOU: 1.) Uncomment the `let` to enable this feature; then
"      2.) Use <F9> to reload this script.
"      - HINT: <F9> defined by: landonb/dubs_ftype_mess or run:
"        noremap <silent><buffer> <F9> :exec 'source '.bufname('%')<CR>
"
"  let s:reloadable = 1
if exists("s:reloadable") && s:reloadable &&
    \ exists("g:loaded_plugin_edit_juice_ctrl_delete")
  unlet g:loaded_plugin_edit_juice_ctrl_delete
endif

" ***

if exists("g:loaded_plugin_edit_juice_ctrl_delete") || &cp
  finish
endif
let g:loaded_plugin_edit_juice_ctrl_delete = 1

" ========================================================================

" ------------------------------------------------------
" A Delicious Delete
" ------------------------------------------------------

" In EditPlus, Ctrl-Delete deletes characters
" starting at the cursor and continuing to the
" end of the word, or until certain punctuation.
" If the cursor is on whitespace instead of a
" non-whitespace character, Ctrl-Delete just
" deletes the continuous block of whitespace,
" up until the next non-whitespace character.
"
" In Vim, the 'dw' and 'de' commands perform
" similarly, but they include whitespace, either
" after the word is deleted ('dw'), or before
" it ('de'). Therefore, to achieve the desired
" behaviour -- such that contiguous blocks of
" whitespace and non-whitespace are treated
" independently -- we need a function to tell
" if the character under the cursor is whitespace
" or not, and to call 'dw' or 'de' as appropriate.
"
" NOTE Was originally called
"        DeleteToEndOfWord
"      and then at some point renamed to
"        DeleteToEndOfWhitespaceAlphanumOrPunctuation
"      but after that rename-abbreviated to
"        Del2EndOfWsAz09OrPunct
"      where Ws: whitespace, Az: a-z, 09: 0-9, and Punct: uation.

" ========================================================================

" --------------------------------
"  [DEPRECATED] Original Function
function! s:Del2EndOfWsAz09OrPunct_ORIG()
  " If the character under the cursor is
  " whitespace, do 'dw'; if it's an alphanum, do
  " 'dw'; if punctuation, delete one character
  " at a time -- this way, each Ctrl-Del deletes
  " a sequence of characters or a chunk of
  " whitespace, but never both (and punctuation
  " is deleted one-by-one, seriously, this is
  " the way's I like's it).
  let char_under_cursor =
    \ getline(".")[col(".") - 1]
  " Can't get this to work:
  "    if l:char_under_cursor =~ "[^a-zA-Z0-9\\s]"
  " But this works:
  if (l:char_under_cursor =~ "[^a-zA-Z0-9]")
        \ && (l:char_under_cursor !~ "\\s")
    " Punctuation et al.; just delete the
    " char or sequence of the same char.
    " Well, I can't get sequence-delete to
    " work, i.e.,
    "      execute 'normal' .
    "        \ '"xd/' . l:char_under_cursor . '*'
    " doesn't do squat. In fact, any time I try
    " the 'd/' motion it completely fails...
    " Anyway, enough boo-hooing, just delete the
    " character-under-cursor:
    execute 'normal' . '"xdl'
  elseif l:char_under_cursor =~ '[a-zA-Z0-9]'
    " This is an alphanum; and same spiel as
    " above, using 'd/' does not work, so none of
    " this:
    "   execute 'normal' . '"xd/[a-zA-Z0-9]*'
    " Instead try this:
    "execute 'normal' . '"xde'
    execute 'normal' . '"xdw'
  elseif l:char_under_cursor =~ '\s'
    " whitespace
    " Again -- blah, blah, blah -- this does not
    " work: execute 'normal' . '"xd/\s*'
    execute 'normal' . '"xdw'
  " else
  "   huh? this isn't/shouldn't be
  "         an executable code path
  endif
endfunction

" ========================================================================

" --------------------------------
"  [CURRENT] Better Function
function! s:Del2EndOfWsAz09OrPunct(wasInsertMode, deleteToEndOfLine)
  " If the character under the cursor is
  " whitespace, do 'dw'; if it's an alphanum, do
  " 'dw'; if punctuation, delete one character
  " at a time -- this way, each Ctrl-Del deletes
  " a sequence of characters or a chunk of
  " whitespace, but never both (and punctuation
  " is deleted one-by-one, seriously, this is
  " the way's I like's it).
  " 2010.01.01 First New Year's Resolution
  "            Fix Ctrl-Del when EOL (it cur-
  "            rently deletes back a char, rath-
  "            er than sucking up the next line)
  " MAYBE/2020-05-14: I might want to consider the @/ I use elsewhere:
  "            let @/ = "\\(\\(\\_^\\|\\<\\|\\s\\+\\)\\zs\\|\\>\\)"
  let l:char_under_cursor = getline(".")[col(".") - 1]
  " echom('char ' . l:char_under_cursor
  "       \ . ' / char2nr ' . char2nr(l:char_under_cursor)
  "       \ . ' / col. ' . col(".")
  "       \ . ' / col$ ' . col("$"))
  " 2020-05-14: This condition seems overly complicated...
  if (       ( ((col(".") + 1) == col("$"))
        \     && (col("$") != 2) )
        \ || ( ((col(".") == col("$"))
        \     && (col("$") == 1))
        \     && (char2nr(l:char_under_cursor) == 0) ) )
    " At end of line; delete newline after cursor
    " (what vi calls join lines)
    normal! gJ
    "execute 'j!'
    " [2020-05-14: Wicked old comment. Could probably solve with getcurpos()
    "  and the 'curswant' value.]
    " BUGBUG Vi returns the same col(".") for both
    " the last and next-to-last cursor positions (in insert mode),
    " so we're not sure whether to join lines or
    " to delete the last character on the line.
    " Fortunately, we can just go forward a
    " character and then delete the previous char,
    " which has the desired effect
    " Or not, I can't get this to work...
    "execute 'normal ^<Right'
    "execute 'normal X'
    "let this_col = col(".")
    "execute 'normal l'
    "let prev_col = col(".")
    "call confirm('this ' . this_col . ' prev ' . prev_col)
    "
    let l:cur_col = col(".")
    let l:tot_col = col("$")
    " This is a little hack; the d$ command below, which executes if the
    " cursor is not in the last position, moves the cursor one left, so the
    " callee moves the cursor back to the right. However, our gJ command
    " above doesn't move the cursor, so, since we know the callee is going
    " to move it, we just move it left
    " Fix cursor position, but avoid screen blinking if cannot move cursor.
    if a:deleteToEndOfLine == 1 && l:cur_col > 1
      normal! h
    endif
  else
    let l:cur_col = col(".")
    let l:tot_col = col("$")
    "let l:char_under_cursor =
    "  \ getline(".")[col(".")]
    " Can't get this to work:
    "    if l:char_under_cursor =~ "[^a-zA-Z0-9\\s]"
    " But this works:
    if a:deleteToEndOfLine == 1
      normal! d$
      if a:wasInsertMode
        " Ensure when changing back to insert mode the Vim does
        " not move cursor back one, to penultimate position.
        normal! $
      endif
    else
      let last_pttrn = @/
      " NOTE: (lb): I use this pattern in vim-select-mode-stopped-down plugin:
      "         let @/ = "\\(\\(\\_^\\|\\<\\|\\s\\+\\)\\zs\\|\\>\\)"
      "       but the final \> causes edge case when trying to delete final
      "       word in a line: it leaves the last character behind.
      let @/ = "\\(\\(\\_^\\|\\<\\|\\s\\+\\)\\zs\\)"
      " FIXME/2020-05-14 02:13: C-Del deletes '78' but not '9': 7ddd89
      normal! dn
      let @/ = l:last_pttrn
    endif
  endif
  if a:wasInsertMode && ((l:cur_col + 2) == l:tot_col)
    " <ESC> Made us back up, so move forward one,
    " but not if we're the first column or the
    " second-to-last column
    "execute 'normal h'
  endif
endfunction

" ========================================================================

function! s:free_keys_delete_forwards_c_del()
  silent! nunmap <C-Del>
  silent! iunmap <C-Del>
endfunction

function! s:free_keys_delete_forwards_c_s_del()
  silent! nunmap <C-S-Del>
  silent! iunmap <C-S-Del>
endfunction

function! s:free_keys_delete_forwards_m_del()
  silent! nunmap <M-Del>
  silent! iunmap <M-Del>
endfunction

function! s:free_keys_delete_forwards_m_s_del()
  silent! nunmap <M-S-Del>
  silent! iunmap <M-S-Del>
endfunction

function! s:free_keys_delete_forwards()
  call s:free_keys_delete_forwards_c_del()
  call s:free_keys_delete_forwards_c_s_del()
  call s:free_keys_delete_forwards_m_del()
  call s:free_keys_delete_forwards_m_s_del()
endfunction

" ***

function! s:wire_keys_delete_forwards_c_del()
  " Map the function to Ctrl-Delete in normal and
  " insert modes.
  noremap <C-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 0)<CR>
  " BUGBUG To call a function from Insert Mode -- or to even get
  "        the current column number of the cursor -- we need
  "        to either <C-O> or <Esc> out of Insert mode. If
  "        we <C-O> and the cursor is on either the last
  "        column or the second-to-last-column, the cursor
  "        is moved to the last column. Likewise, if we
  "        <Esc> and the cursor is on either the first column
  "        or the second column, the cursor is moved to the
  "        first column. I cannot figure out a work-around.
  "        I choose <Esc> as the lesser of two evils. I.e.,
  "        using <C-O>, if the cursor is at the second-to-
  "        last column, a join happens but the last character
  "        remains; using <Esc>, if you <Ctrl-Del> from the
  "        second column, both the first and second columns
  "        are deleted. I <Ctrl-Del> from the end of a line
  "        much more ofter than from the second column of a
  "        line.
  "inoremap <C-Del>
  "         \ <C-O>:call <SID>Del2EndOfWsAz09OrPunct()<CR>
  inoremap <C-Del> <C-O>:call <SID>Del2EndOfWsAz09OrPunct(1, 0)<CR>
endfunction

function! s:wire_keys_delete_forwards_c_s_del()
  " Ctrl-Shift-Delete deletes to end of line
  "noremap <C-S-Del> d$
  "inoremap <C-S-Del> <C-O>d$
  noremap <C-S-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 1)<CR>
  inoremap <C-S-Del> <C-O>:call <SID>Del2EndOfWsAz09OrPunct(1, 1)<CR>
endfunction

function! s:wire_keys_delete_forwards_m_del()
  " 2011.02.01 Doing same [as Ctrl-Shift-Delete] for Alt-Delete
  noremap <M-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 1)<CR>
  inoremap <M-Del> <C-O>:call <SID>Del2EndOfWsAz09OrPunct(1, 1)<CR>
endfunction

function! s:wire_keys_delete_forwards_m_s_del()
  " Alt-Shift-Delete deletes entire line
  noremap <M-S-Del> dd
  inoremap <M-S-Del> <C-O>dd
endfunction

function! s:wire_keys_delete_forwards()
  call s:wire_keys_delete_forwards_c_del()
  call s:wire_keys_delete_forwards_c_s_del()
  call s:wire_keys_delete_forwards_m_del()
  call s:wire_keys_delete_forwards_m_s_del()
endfunction

" ***

function! s:inject_maps_delete_forwards()
  call <SID>free_keys_delete_forwards()
  call <SID>wire_keys_delete_forwards()
endfunction

call <SID>inject_maps_delete_forwards()

