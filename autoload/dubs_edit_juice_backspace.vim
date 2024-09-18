" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Online: https://github.com/landonb/dubs_edit_juice
" License: https://creativecommons.org/publicdomain/zero/1.0/

" ========================================================================

" Enhanced `d<Home>` motion.
" - When cursor is in second or greater column, delete from the cursor
"   back to the start of the line, just like `d<HOME>`.
"   - Except handle edge case when in normal mode where cursor is atop the
"     final column, and don't not delete the final character like `d<Home>`
"     (the 'x', below, deletes the final character that `d0` misses).
" - When cursor is in first column, delete the line above.
"   - This feels like the most natural behavior for this motion.
"   - We could alternatively do nothing, like `d0`/`d<HOME>`, and 'stop'
"     when the cursor is at the first column (so, e.g., pressing C-S-BS
"     deletes to the start of the line, but then every C-S-BS after that
"     does nothing until the user moves the cursor). But this feature
"     feels more powerful/useful if it can be used to keep deleting lines.
"   - The delete-the-line-above behavior adds another quick-line-delete
"     option, like `dd`, but the user will not have to leave insert mode.
"   - We can also take this behavior one step further, such that if/when
"     the cursor is at the beginning of the buffer (in the first column
"     on the first line), C-S-BS will start behaving just like `dd`, and
"     can be used to trim leading lines one-by-one. E.g., you could C-S-BS
"     on a line to delete to its start, then hit C-S-BS again to delete the
"     line above, etc., until the cursor moved up to the first line, and then
"     each C-S-BS after than deletes the current (first) line, shortening the
"     the file (buffer) every time, until the buffer itself is empty -- and
"     all it would take to clear the entire buffer would be n+1 C-S-BS
"     presses, where n is the number of lines originally in the file.

function! dubs_edit_juice_backspace#delete_back_line(mode) abort
  " SAVVY: <c-g>u starts a new Undo set, so the deletion can be undone.
  " - REFER: :help undo-break
  " - BWARE: Note that running <c-g>u moves the cursor, e.g., if the
  "   user <S-C-W>'s from the end of a line and this fcn. starts with:
  "     execute "normal i\<C-g>u\<ESC>"
  "   then the final 2 chars from that line are left behind.
  "   - So use the other trick to close the undo block, assign to undolevels:
  let &g:undolevels = &g:undolevels

  " Mimic `d<Home>`, but behave better at end of line.
  let curr_col = col(".")
  let line_nbytes = len(getline(line(".")))
  if l:curr_col == 1
    if line(".") > 1
      normal! k
    endif
    " If the line has leading whitespace, Vim will put the cursor over
    " the first visible character, so ensure cursor finishes on col 1
    " by running `0` after the `dd`.
    normal! dd0
  else
    normal! d0
    if l:curr_col >= l:line_nbytes
      normal! x
    endif
  endif
endfunction

" ========================================================================

