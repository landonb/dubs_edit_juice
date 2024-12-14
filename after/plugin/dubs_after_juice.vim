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

" ------------------------------------------------------
" Swap selection and clipboard contents
" ------------------------------------------------------

" 2021-01-31: Trying a Clipboard Paste-Copy-Swapper.
"
" Ref:
"
"   https://stackoverflow.com/questions/1502218/copy-from-one-register-to-another
"   https://vim.fandom.com/wiki/Comfortable_handling_of_registers
"
" Use Case: I want to highlight something to paste over it, but I want
"           selection to become next clipboard contents.
"
" - I.e., press `\dS` to swap highlighted text with clipboard contents.
" How it works:
"   "ax       Delete selection and store deleted text in register 'a'.
"   "+gP      Put text (from @+ register, aka Paste clipboard), and leave
"             the cursor after the pasted text (so ends in insert mode).
"   :let ...  Swap @a and @+ registers, using @x for temporary storage.
"             (The Vim tip has an example where `\s` rotates @", @a, and @b,
"              which seems cool, but I'm not sure I'd use it; I mean, I've
"              survived almost two decades using just the 1 clipboard value!
"              So I'm not sure that I'd know how to manage *3* such values!!
"              I'm not even sure I'll use this mapping that often; it's just
"              something every once in a while I think about... and who does
"              not love to grind their Vim teeth every once in a while to put
"              out a new, slightly novel mapping?)
" - Thanks @quickcougar for the great find! This was not working with `put`.
"   - Copy something with <Ctrl-c>, run :reg, and it updates three registers:
"     <""> <"*> <"+> (without the <>'s, which are just a highlight jammer)
"     - "": unnamed register (*always* filled on "d", "c", "s", "x" and "y")
"     - "*: clipboard (not system)
" HSTRY/2024-12-10: Was <Leader>cl, but I'm moving all the Dubs maps to \d prefix.
" - HSTRY: Mnemonic: 'cl'ippy swap. (Not really sold on it, just using... something.)
" - Also note normal mode \cl has been CoC 'codeLensAction' for a while.
"   And I haven't used this feature much/at all.
"   - See also YankRing
"       https://github.com/vim-scripts/YankRing.vim
"     Or consider using built-in numbered registers that contain last 9 deletes.
" - Let's try \dS for 'swap'
silent! unmap <Leader>dS
vnoremap <Leader>dS "ax"+gP:let @x=@+ \| let @+=@a \| let @a=@x \| let @"=@+ \| let @*=@+<CR>
nnoremap <Leader>dS :let @x=@+ \| let @+=@a \| let @a=@x \| let @"=@+ \| let @*=@+<CR>
inoremap <Leader>dS <C-O>:let @x=@+ \| let @+=@a \| let @a=@x \| let @"=@+ \| let @*=@+<CR>

" -------------------------------------------------------------------

" ------------------------------------------------------
" Ctrl-H Hides Highlighting
" ------------------------------------------------------

" Once you initiate a search, Vim highlights all matches.
" Type Ctrl-H to turn 'em off.

" Vim's default Ctrl-H is the same as <BS>.
" It's also the same as h, which is the
" same as <Left>. WE GET IT!! Ctrl-H won't
" be missed....
" NOTE: Highlighting is back next time you search.
" NOTE: Ctrl-H should toggle highlighting (not
"       just turn it off), but nohlsearch doesn't
"       work that way
" NOTE: Set this after calling `behave mswin`, which overrides C-h.
noremap <C-h> :nohlsearch<CR>
inoremap <C-h> <C-O>:nohlsearch<CR>
cnoremap <C-h> <C-C>:nohlsearch<CR>
onoremap <C-h> <C-C>:nohlsearch<CR>
" (NEWB|NOTE: From Insert mode, Ctrl-o
"  is used to enter one command and
"  execute it. If it's a :colon
"  command, you'll need a <CR>, too.
"  Ctrl-c is used from command and
"  operator-pending modes.)

" -------------------------------------------------------------------



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

" -------------------------------------------------------------------------
" -------------------------------------------------------------------------

