" Improved `db` motion, to work at end of line ($).
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: https://creativecommons.org/publicdomain/zero/1.0/

" ========================================================================

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_plugin_edit_juice_ctrl_backspace
endif

if exists('g:loaded_plugin_edit_juice_ctrl_backspace') || &cp

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
  let line_nbytes = len(getline("."))
  if l:curr_col == 1
    let was_ww = &whichwrap
    set whichwrap=h
    normal! dh
    if a:mode == 'i' && l:line_nbytes == 0
      " A `dh` on an empty line deletes the newline but moves the cursor one
      " before the final character (probably because of virtualedit behavior),
      " so jump to the final cursor position.
      normal! $
    endif
    execute "set whichwrap=" . l:was_ww
  else
    let curpos = getcurpos()
    let curswant = curpos[4]
    let last_col = virtcol("$")

    let last_pttrn = @/
    let @/ = "\\(\\(\\_^\\|\\<\\|\\s\\+\\)\\zs\\|\\>\\)"
    normal! dN
    if (a:mode == 'i' && l:curswant >= l:last_col)
      \ || (a:mode == 'n' && (l:curswant + 1) >= l:last_col)
      " The final character escaped the dN motion. Delete it.
      normal! x
      " Weird: I'm seeing getcurpos() report incoorect curswant.
      " E.g., if the line is
      "         foo bar
      " and I C-BS to delete the 'bar' in insert mode, so what's
      " left is 'foo ', and the cursor is after the space, the
      " curswant should be 5, but getcurpos says 4. If I hit
      " '$' though, the cursor does not move, but curswant updates
      " to 5. So ensure curswant is accurate if this function
      " called again.
      normal! $
    endif
    let @/ = l:last_pttrn
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
  " Ctrl-Shift-Backspace deletes to start of line. Aka *<C-S-Backspace>*
  " - 2020-05-13: The old, simple way:
  "     noremap <C-S-BS> d<Home>
  "     inoremap <C-S-BS> <C-O>d<Home>
  "   And now for something completely more complicated.
  nnoremap <C-S-BS> :<C-U>call dubs_edit_juice_backspace#delete_back_line()<CR>
  inoremap <C-S-BS> <C-O>:<C-U>call dubs_edit_juice_backspace#delete_back_line()<CR>
  " Ctrl-Shift-W like Ctrl-Shift-BS (default <c-s-w> is same as <c-w>).
  " - SAVVY: Works in Debian Vim, but not MacVim (where Shift-Control
  "   input maps to unshifted Control-only).
  inoremap <C-S-W> <C-O>:<C-U>call dubs_edit_juice_backspace#delete_back_line()<CR>
  " OKILL: Also map to <Shift-Alt-W> (aka <M-S-W> <S-M-W> <Alt-Shift-W>)
  " - Note that macOS `vim`/MacVim does not distinguish <Shift-Ctrl-W> apart
  "   from <Ctrl-W> (they're both intrepeted as the same escape sequence),
  "   so now you have 3 options to delete_back_line: <C-S-BS>, <C-S-W>, <M-S-W>
  "   all three of which work in Debian, but only 2 of them in macOS.
  " - SAVVY: <Shift-Alt-W> prints '×' by default if no mapping set (tho dunno why),
  "   so this binding does not change anything important.
  " - REFER: There is a crafty way to make <Ctrl-Shift> work in vim/MacVim
  "   if you use a keyboard 'driver' to substitute a different keypress for
  "   <Ctrl-Shift> combinations. DepoXy does this using Alacritty.toml to
  "   modify `vim` combinations, and Hammerspoon to modify MacVim inputs.
  "   - You'll find more in the DepoXy project:
  "       https://github.com/DepoXy/depoxy#🍯
  "     Specifically the three files:
  "       https://github.com/DepoXy/depoxy/blob/release/home/.config/alacritty/alacritty.toml#L282-L350
  "       https://github.com/DepoXy/depoxy/blob/release/home/.hammerspoon/depoxy-hs.lua#L124-L175
  "       https://github.com/DepoXy/vim-depoxy/blob/release/plugin/vim-shift-ctrl-bindings.vim
  inoremap <M-S-W> <C-O>:<C-U>call dubs_edit_juice_backspace#delete_back_line()<CR>
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

