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

let s:_trace_level = 0
" YOU: Uncomment to see trace messages.
"
"  let s:_trace_level = 1

function! s:trace(msg)
  if s:_trace_level > 0
    echom a:msg
  endif
endfunction

" ========================================================================

" ------------------------------------------------------
" A Delicious Delete
" ------------------------------------------------------

" In EditPlus, Ctrl-Delete deletes characters
" starting at the cursor and continuing to the
" end of the word, or until certain punctuation.
" If the cursor precedes whitespace instead of a
" non-whitespace character, Ctrl-Delete just
" deletes the continuous block of whitespace,
" up until the next non-whitespace character.
"
" In Vim, the 'dw' and 'de' commands perform
" similarly, but they include whitespace, either
" after the word is deleted ('dw'), or before
" it ('de'). Here we bake our own delete-forward
" using `dn` and a specially-crafted @/ regex
" to get the deletion *just* right.
"
" We also handle other special cases, such as
" when the cursor is at the end of the line,
" which is tricky in Vim because of how the two
" modes, insert and normal, behave, and because
" virtualmode. Also the special case of an empty
" line. And a few others. Tricky, tricky business.

" ========================================================================

function! s:Del2EndOfWsAz09OrPunct(wasInsertMode, deleteToEndOfLine)
  call s:DeleteForwardLogically(a:wasInsertMode, a:deleteToEndOfLine)
  call s:FixCursorIfAtEndOfLine(a:wasInsertMode)
endfunction

" ========================================================================

function! s:DeleteForwardLogically(wasInsertMode, deleteToEndOfLine)
  let last_col = virtcol("$")

  let curpos = getcurpos()
  let curswant = curpos[4]
  if a:wasInsertMode && (l:last_col == (l:curswant + 1))
    " Use case: In insert mode, and in penultimate column.
    " - Just delete the last character, and fix the cursor.
    normal! x
    call s:trace("X marks the spot")
    return
  endif

  if len(getline(".")) == 0
    " Use case: (Cursor is on) an empty line.
    normal! gJ
    call s:trace("Emptied empty")
    return
  endif

  let l:curs_col = virtcol(".")
  if l:last_col == (l:curs_col + 1)
    " Use case: At the end of the line.
    " Delete the newline after the cursor using the 'join lines' feature.
    " I also tried `,s/\n/` which sorta works but feels wonky.
    normal! gJ
    call s:trace("Join together (with the band)")
    return
  endif

  if a:deleteToEndOfLine == 1
    normal! d$
    call s:trace("d<money> to the end of line")
    return
  endif

  if 1
    let last_pttrn = @/
    " NOTE: (lb): I use a search pattern in another plugin I maintain
    "       that implements meta- and arrow-based motion selection,
    "       vim-select-mode-stopped-down, which looks like this:
    "         let @/ = "\\(\\(\\_^\\|\\<\\|\\s\\+\\)\\zs\\|\\>\\)"
    "       which we can repurpose here to delete words. But note that
    "       the final "\\>" tickles an edge case when trying to delete
    "       the last word in a line: it leaves the last character behind.
    "       - So remove the \>, but with the caveat that when you
    "         C-Del the last word from a line, the newline is also removed,
    "         and the cursor moves to the first visible character.
    "         (lb): This is not quite in line with how I would naturally
    "         expect this operation to behave -- e.g., imagine two words
    "         on the line, 'foo bar', if you ctrl-del from the first
    "         column 'foo ' is removed; and then I'd expect another
    "         ctrl-del to delete the 'bar', but here it deletes the
    "         'bar\n', which I think should be two separate operations.
    "         Nonetheless, I've already invested enough time in this
    "         function today (2020-05-14) so calling it good (at least
    "         for another 5-10 years, because this function, per a comment
    "         I deleted today, was writ '2010.01.01', and remained largely
    "         untouched since 2015; a staple in my repertoire, for sure,
    "         but not something that has to behave exactly how I want;
    "         but something that, after years of enough wanting, I'll
    "         finally get around to tweaking).
    "       - Here's the regex without the final \\>, end-of-word boundary
    "         match, but we can move it inside the regex, like so:
    "           let @/ = "\\(\\(\\_^\\|\\<\\|\\>\\|\\s\\+\\)\\zs\\)"
    "         However, that leaves an edge case with the final word on the
    "         line, where all but the last character are deleted.
    "         So add a not-followed-by-newline [^\\n] check,
    "         and sprinkle the \zs sets-start-of-match appropriately,
    "         which lets us check not-newline without using a lookahead.
    " Match:
    "   at beginning of line;
    "   at beginning of word boundary;
    "   at end of word boundary but not end of line (otherwise the final word
    "     is not fully deleted, but the final character remains undeleted); or
    "   after whitespace.
    let @/ = ""
      \ . "\\(\\_^\\zs"
      \ . "\\|\\<\\zs"
      \ . "\\|\\>\\zs[^\\n]"
      \ . "\\|\\s\\+\\zs"
      \ . "\\)"
    normal! dn
    let @/ = l:last_pttrn
    call s:trace("the pattern is the pattern")
  endif
endfunction

" ========================================================================

" If we bopped outta insert mode to run the deletion and are returning
" to insert mode, it's tricky to get the cursor back to where we want.
" - If we did not join lines and if we deleted everything from the
"   cursor until the end of the line, the default Vim behaviour will
"   be to put the insert mode cursor in the penultimate position
"   (because Vim generally moves the cursor back one when transitioning
"   from normal to inert mode).
"   - We could use `$` here, which sets `curswant` very large, which
"     would essentially move the cursor to the last column -- but
"     then if the user moves the cursor to the line above or to
"     the line below, the cursor shoots off to the right if it can.
"     Which is annoying if you're using this feature to delete the ends
"     of multiple lines from the same column, e.g., if you're typing
"     <Ctrl-Shift-Delete> <Down> <Ctrl-Shift-Delete> <Down>, etc.
"   - We cannot use <Right> or call, say, `normal l` either, because,
"     technically, since we bopped out to normal mode, the cursor
"     *is* in the final column position! (So a <Right> would move the
"     cursor to the nexst line, and an `l` might blink the screen,
"     (unless whichwrap) because the cursor cannot move further right.)
"   - I tried using a mark as a work-around, as suggested by this post:
"       https://sanctum.geek.nz/arabesque/vim-annoyances/
"     e.g., instead of just ‘gJ’, call ‘mzJg`z’. But this has same issue,
"     and the insert cursor still appears leftward one column of desired.
"   - I first tried calling cursor() with a [List] that included curswant,
"     and then setpos() with the same, but it seems a simple cursor with
"     just two parameters, lnum and col, is sufficient (where lnum==0
"     means to 'stay in the current line').
function! s:FixCursorIfAtEndOfLine(wasInsertMode)
  if a:wasInsertMode && (virtcol(".") + 1) == virtcol("$")
    call cursor(0, col('.') + 1)
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
  " 2020-05-15: I switched from using <Esc> to <C-O>,
  " to break out of insert mode. My rationale was:
  "   - If we <C-O> and the cursor is on either the last
  "     column or the second-to-last-column, the cursor
  "     is moved to the last column.
  "   - If we <Esc> and the cursor is on either the first
  "     column or the second column, the cursor is moved
  "     to the first column.
  "   - At the time I chose <Esc> (5-10 years ago), I did not solve the
  "     problem, but I figured I had to live with one of two scenarios:
  "     - With <C-O>, if the cursor is at the second-to-last column,
  "       a join happens, but the last character remains.
  "     - With <Esc>, if you <Ctrl-Del> from the second column, both the
  "       first and second columns are deleted.
  "     - And I chose <Esc>'s behavior, because, I noted:
  "       I <Ctrl-Del> from the end of a line much more often than from
  "       the second column of a line.
  " - But now it's 2020 and I seem to have been able to handle both
  "   those issues, and I prefer <C-O>, so that I can run a one-off
  "   command and not have to worry about 'i' later, or explicitly
  "   re-entering insert mode.
  inoremap <C-Del> <C-O>:call <SID>Del2EndOfWsAz09OrPunct(1, 0)<CR>
endfunction

function! s:wire_keys_delete_forwards_c_s_del()
  " Ctrl-Shift-Delete deletes to end of line.
  " - Sort like
  "       noremap <C-S-Del> d$
  "       inoremap <C-S-Del> <C-O>d$
  "   but more robuster.
  noremap <C-S-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 1)<CR>
  inoremap <C-S-Del> <C-O>:call <SID>Del2EndOfWsAz09OrPunct(1, 1)<CR>
endfunction

function! s:wire_keys_delete_forwards_m_del()
  " 2011.02.01 Doing same [as Ctrl-Shift-Delete] for Alt-Delete.
  noremap <M-Del> :call <SID>Del2EndOfWsAz09OrPunct(0, 1)<CR>
  inoremap <M-Del> <C-O>:call <SID>Del2EndOfWsAz09OrPunct(1, 1)<CR>
endfunction

function! s:wire_keys_delete_forwards_m_s_del()
  " Alt-Shift-Delete deletes the entire line. Which `dd` does perfectly.
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

