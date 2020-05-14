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
    \ exists("g:loaded_plugin_edit_juice_ctrl_backspace")
  unlet g:loaded_plugin_edit_juice_ctrl_backspace
endif

" ***

if exists("g:loaded_plugin_edit_juice_ctrl_backspace") || &cp
  finish
endif
let g:loaded_plugin_edit_juice_ctrl_backspace = 1

" ========================================================================

" ------------------------------------------------------
" A Better Backspace
" ------------------------------------------------------

" ========================================================================

function! s:delete_back_word(mode)
  " Mimic `db`, but behave different at end of line, and at beginning.
  let curr_col = col(".")
  if l:curr_col == 1
    let was_ww = &whichwrap
    set whichwrap=h
    normal! dh
    execute "set whichwrap=" . l:was_ww
    if a:mode == 'i'
      normal! $
    endif
  else
    let line_nbytes = len(getline(line(".")))
    let last_pttrn = @/
    let @/ = "\\(\\(\\_^\\|\\<\\|\\s\\+\\)\\zs\\|\\>\\)"
    normal! dN
    if l:curr_col >= l:line_nbytes
      normal! x
    endif
    let @/ = l:last_pttrn
  endif
endfunction

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
function! s:delete_back_line(mode)
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

function! s:free_keys_delete_backwards_c_bs()
silent! nunmap <C-BS>
  silent! iunmap <C-BS>
endfunction

function! s:free_keys_delete_backwards_m_bs()
  silent! nunmap <M-BS>
  silent! iunmap <M-BS>
endfunction

function! s:free_keys_delete_backwards_c_s_bs()
  silent! nunmap <C-S-BS>
  silent! iunmap <C-S-BS>
endfunction

function! s:free_keys_delete_backwards()
  call s:free_keys_delete_backwards_c_bs()
  call s:free_keys_delete_backwards_m_bs()
  call s:free_keys_delete_backwards_c_s_bs()
endfunction

" ***

function! s:wire_keys_delete_backwards_c_bs()
  " Ctrl-Backspace deletes to start of word.
  " - 2020-05-13: What I've been using the past 10 years:
  "     noremap <C-BS> db
  "     inoremap <C-BS> <C-O>db
  " But let's behave more elegantly when the cursor is at
  " the begining or the end of the line.
  nnoremap <C-BS> :<C-U>call <SID>delete_back_word('n')<CR>
  inoremap <C-BS> <C-O>:<C-U>call <SID>delete_back_word('i')<CR>
endfunction

function! s:wire_keys_delete_backwards_m_bs()
  " Map Alt-Backspace to same as Ctrl-Backspsace, if not just
  " because Readline (e.g., the Bash prompt) maps Alt-Backspace
  " to the same (similar) behavior.
  " - 2020-05-13: Here's what I had been using for past number of years:
  "   noremap <M-BS> db
  "   inoremap <M-BS> <C-O>db
  nnoremap <M-BS> :<C-U>call <SID>delete_back_word('n')<CR>
  inoremap <M-BS> <C-O>:<C-U>call <SID>delete_back_word('i')<CR>
endfunction

function! s:wire_keys_delete_backwards_c_s_bs()
  " Ctrl-Shift-Backspace deletes to start of line
  " - 2020-05-13: The old, simple way:
  "     noremap <C-S-BS> d<Home>
  "     inoremap <C-S-BS> <C-O>d<Home>
  "   And now for something completely more complicated.
  nnoremap <C-S-BS> :<C-U>call <SID>delete_back_line('n')<CR>
  inoremap <C-S-BS> <C-O>:<C-U>call <SID>delete_back_line('i')<CR>
endfunction

function! s:wire_keys_delete_backwards()
  call s:wire_keys_delete_backwards_c_bs()
  call s:wire_keys_delete_backwards_m_bs()
  call s:wire_keys_delete_backwards_c_s_bs()
endfunction

" ***

function! s:inject_maps_delete_backwards()
  call <SID>free_keys_delete_backwards()
  call <SID>wire_keys_delete_backwards()
endfunction

call <SID>inject_maps_delete_backwards()

