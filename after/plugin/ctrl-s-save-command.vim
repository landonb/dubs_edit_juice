" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3 | Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" More silent <Ctrl-S>
" -------------------------------------------------------------------------

" Add <silent> to mswin.vim <C-S> maps (and change noremap → nnoremap).
" BECUZ: When you save actual changes Vim prints
"   "{path}" {lines}L, {bytes}B written
" but when you <C-S> a file without modifications, prints
"   :update
" - LATER: Determine if you like the nonresponsive effect here.
" CXREF:
"   /Applications/MacVim.app/Contents/Resources/vim/runtime/mswin.vim
"   ~/.local/share/vim/vim91/mswin.vim

" SAVVY: When loaded via |Plug|, after/ loads alphabetically, so this file
" loads before 'enable-behave-mswin.vim', and `behave mswin` reassigns <C-S>.
" - But our load wrapper saves and restores <C-S>, so we don't have to worry
"   about load order; these assignments will always stick.

function! s:MapSilentCtrlSSave()
  if get(g:, 'dubs_edit_juice_silent_save', 1) == 0

    return
  endif

  if $VIM_EDIT_JUICE_EXIT_ON_SAVE == ''
    nnoremap <silent> <C-S> :update<CR>
    vnoremap <silent> <C-S> <C-C>:update<CR>
    inoremap <silent> <C-S> <Esc>:update<CR>gi
  endif
endfunction

call s:MapSilentCtrlSSave()

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" Fast save-and-exit for special apps (opt-in feature)
" -------------------------------------------------------------------------

" Commands can opt-in to these maps using special ENVIRON.
" - Use case: `pass edit`, `dob edit`, `git commit`,
"   anywhere you want to make it easy to save and exit
"   (and where you can use readline <Up><Enter> to re-
"   run the command if you forgot special <C-s> exits
"   you).

function! s:MapCtrlSSaveAndExitForSpecialApps()
  if $VIM_EDIT_JUICE_EXIT_ON_SAVE != ''
    " Ctrl-s to save and exit from any mode.
    nnoremap <C-s> :wq<CR>
    vnoremap <C-s> <C-o>:wq<CR>
    inoremap <C-s> <C-o>:wq<CR>
  endif
endfunction

call s:MapCtrlSSaveAndExitForSpecialApps()

