" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

if exists("g:after_juice_vim") || &cp
  finish
endif
let g:after_juice_vim = 1

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" After Effects
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" Fast save-and-exit for special commands
" -------------------------------------------------------------------------

" Commands can opt-in to these maps using special ENVIRON.
" - Use case: `pass edit`, `dob edit`, `git commit`,
"   anywhere you want to make it easy to save and exit
"   (and where you can use readline <Up><Enter> to re-
"   run the command if you forgot special <C-s> exits
"   you).

function! s:MapCtrlSSaveAndExitForSpecialApps()
  if $VIM_EDIT_JUICE_EXIT_ON_SAVE != ""
    " Ctrl-s to save and exit from any mode.
    noremap <C-s> :wq<CR>
    vnoremap <C-s> <Esc>:wq<CR>
    inoremap <C-s> <Esc>:wq<CR>
  endif
endfunction

call s:MapCtrlSSaveAndExitForSpecialApps()

