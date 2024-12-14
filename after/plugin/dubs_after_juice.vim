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
" Automatically center curson on search
" -------------------------------------------------------------------------
"  [2018-06-11: Just created this. I am so behind the Vim-times!]

" How did I not Google this before? Such an obvious feature!
" NOTE: You could :set scrolloff=999 to keep the cursor centered, but then
"       it applies not just to every command, but to the whole interaction.
"       I.e., the cursor will always be centered! You won't be able to arrow-
"       up, arrow-down, Ctrl-PgUp, etc. to move the cursor outside the middle.
"       So that's not an option.
" Use `zz` after search commands to center the cursor, so your eye doesn't
" have to scan to see where where the cursor is. Also, if you have more than
" one search result highlighted in view, and if your syntax colors sometimes
" make it difficult to see upon which highlight is the cursor is situated,
" centering the cursor makes it obvious.

" BLARGH/2018-06-13: The n/N maps do not stick. You can set manually and they
" work, but something is clobbering them on startup...
" - Ha! I even put these two lines at the bottom and ~/.vimrc, and it still
"   doesn't stick!
" - As suspected: You can map another key, e.g., m/M, and it'll stick to them.
" DISABLE/MAYBE/2018-06-13: I feel weird leaving this code uncommented, because
"   it doesn't work; however, I'd like to see if it even magically starts working
"   again...
nnoremap n nzz
nnoremap N Nzz
" WHATEVER/2018-06-13: So be it! We can map Alt-n/N, at least in the GUI; in the
"   terminal, I think I'm stuck with */#.
nnoremap <M-n> nzz
nnoremap <M-N> Nzz

nnoremap * *zz
nnoremap # #zz
" (lb): Ha. I don't use the g-commands. g* is like '*' but without \<word\>
" boundaries. And g# is like '#" (reverse-'*'), but without word boundaries.
nnoremap g* g*zz
nnoremap g# g#zz

" Meh. If you find other instances where you want to enable the centering
" behavior, you could add a toggle command. But I think I've got all the
" bases covered that I care about. (And I'm not a sports fan, so not sure
" why the baseball reference.)
"
"  :nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR>

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

