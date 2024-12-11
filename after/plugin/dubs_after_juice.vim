" File: after/dubs_after_juice.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Last Modified: 2018.01.05
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: AutoAdapt wrapper. And more.
" License: GPLv3
" -------------------------------------------------------------------
" Copyright © 2015, 2017-2018 Landon Bouma.
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
" So-called MS Windows mode
" ------------------------------------------------------

" 2017-04-03: Moved to after-juice from normal plugin/dubs_edit_juice
"   so that mswin.vim's Ctrl-x doesn't just dump "+x to the editor,  "
"   and so that mswin.vim's Ctrl-h doesn't replace our hide highlights map.

" See what OS we're on
let s:running_windows = has("win16") || has("win32") || has("win64")

" So-called MS Windows mode
" ------------------------------------------------------
" 2017-04-03: After updating to Vim 8.0, I've noticed that the new mswin,
"     /srv/opt/bin/share/vim/vim80/mswin.vim
"  sets <c-f> and <c-h> (to find, and find-replace, respectively)
"  which overrides Dubs Vim's <c-h> (clear highlight!)
"  and also overrides default Vim's <c-f> (pagedown)
"  (and, oddly, <c-b>, pageup, I notice only works in Normal mode, and not Insert mode?)

" The default Vim keyboard mappings were created to keep one's fingers on
" the home row, so certain key combinations that seem ubiquitous in GUI
" editors are mapped to different commands in Vim.
"
" Enable mswin mode to add more recognizable mappings some of these commands.
"
" NOTE: I (lb) don't 100% agree with mswin mode. I appreciate some mappings,
"       but I'm not a fan of them all, especially those that steal existing,
"       commonly used default Vim mappings. (For instance, I use `/` to start
"       search, so I'd rather leave <Ctrl-f> as PageDown rather than bringing
"       up the GUI find dialog. On the other hand, the default <Ctrl-h> map
"       seems completely unnecessary, so I don't mind re-mapping that combo.)
"
" NOTES:
" - Visual mode is CTRL-Q in mswin; in basic mode it's CTRL-V.
"   (You can also quadruple-click to select by row,column!)
"   - Because Ctrl-V is remapped to paste.
" - When the cursor is at the start or end of a line, the
"   backspace and cursor keys now wrap to previous/next line,
"   rather than sounding the system bell and not moving the cursor
"     (an-noy'ing!).
" - CTRL-X and SHIFT-Del are Cut.
"     (In Vaniall Vim, Ctrl-X would 'Subtract [count] from the number
"     or alphabetic character at or after the cursor.' Seems like a
"     very obscure usage scenario for using such a feature. And it
"     is really weird, I tested and it just decrements the number under
"     the cursor!)
" - CTRL-A is Select all.
"     (In Vanilla Vim, Ctrl-A is complement to Ctrl-X, it adds [count]
"     to the number or alphabetic character at or after the cursor. How
"     often would I ever use this feature, if at all? So mapping to
"     select-all seems like an okay re-mapping of a default Vim map.)
" - CTRL-C and CTRL-Insert are Copy.
" - CTRL-V and SHIFT-Insert are Paste.
" - Use CTRL-Q to do what CTRL-V used to do.
" - Use CTRL-S for saving, also in Insert mode.
"     (I'm not sure Ctrl-S has a Vanvilla Vim map. The only use I can find is
"     Ctrl-W Ctrl-S to split the current window in two. Which still works in
"     Dubs Vim (in Normal mode; in Insert mode, Ctrl-W deletes previous word.)
" - CTRL-Z is Undo.
"     (In Vanilla Vim, Ctrl-Z would Suspend Vim in Normal or Visual mode,
"     and in Insert or Command-line mode, it would insert Ctrl-Z as a
"     normal character. Are either of those behaviors useful?)
" - CTRL-Y is Redo (although not repeat).
"     (In Vanilla Vim, Ctrl-Y would 'Scroll window [count] lines
"     upwards in the buffer' which is not a feature I ever used.)
" - Alt-Space is System menu.
" - CTRL-Tab is Next window.
" - CTRL-F4 is Close window.
"
" HINTS:
" - To start Vim without sourcing vimrc, use the -u NONE option:
"     vim -u NONE
" - To get help on a command key, you might need to use regex to persuade
"   Vim to find the correct help, e.g., `:help Ctrl-B` returns dubs' help
"   for Ctrl-BS; in order to get the help for Ctrl-B (the 'b' character),
"   try `:help Ctrl-B\>`
if !s:running_windows
  " Map <Ctrl-V>, <Ctrl-X>, and <Ctrl-C> keys.
  source $VIMRUNTIME/mswin.vim
  " 2017-04-03: In Insert mode, Ctrl-X is inserting "+x -- what the hell.
  " 2017-06-10: See:
  "     ~/.vim/pack/landonb/start/dubs_edit_juice/after/plugin/dubs_after_juice.vim
  "  - See:
  "     ~/.vim/pack/landonb/start/dubs_appearance/after/plugin/dubs_appearance.vim
  "  - Something must be getting sourced after this that screws it up...
  " :echom "XXXXXXXXXXXXXXXXXXXXXXXXXXX SOURCED ". $VIMRUNTIME . "/mswin.vim"
  "  /usr/share/vim/vim80/mswin.vim
  behave mswin
endif

" Unmask nasty maps.
" - Do not overtake Ctrl-F. Not that I use Ctrl-F/Ctrl-B, because I generally
"   navigate away from the home row and use PageDown/PageUp instead, but I
"   know some hardcore Vimmers would riducule me for taking these keys away.
"   (In my defense, Ctrl-F and Ctrl-B are akward to type; I'd rather use one
"   hand and one finger and not have to stretch pinky and another finger to
"   scroll down and up through a file.)
if has("gui_running")
  unmap <C-F>
endif
" Make sure to remove Find dialog response for Insert mode.
if has("gui_running")
  unmap! <C-F>
endif
" NOTE: Ctrl-F and Ctrl-B do not PageDown/PageUp from Insert mode,
"       but rather enter their respective characters into the buffer.

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

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Switching Buffers/Windows/Tabs
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Ctrl-Tab / Shift-Ctrl-Tab
" ------------------------
" → Next / Previous Buffer
"
" - mswin.vim maps <Ctrl-Tab> to Next Window, which Dubs changes.
" - Dubs maps <M-S-Up> / <M-S-Down> to Next Window / Prev Window.
" - Dubs maps <Ctrl-Tab> / <C-S-Tab> to Next Buffer / Prev Buffer,
"   sorted by buffer number.
"   - CXREF: See also vim-buffer-ring, which maps <C-j> / <C-k> to
"     Prev Buffer / Next Buffer, sorted by recently viewed order:
"       https://github.com/landonb/vim-buffer-ring

" Ctrl-Tab: Next Buffer
" - Note that `behave mswin` sets <C-Tab>,
"   so keep this code under after/.
" - A simple approach:
"   noremap <C-Tab> :bn<CR>
"   inoremap <C-Tab> <C-O>:bn<CR>
"   onoremap <C-Tab> <C-C>:bn<CR>
"   snoremap <C-Tab> <C-C>:bn<CR>
noremap <C-Tab> :call <SID>BufNext_SkipSpecialBufs(1)<CR>
inoremap <C-Tab> <C-O>:call <SID>BufNext_SkipSpecialBufs(1)<CR>
onoremap <C-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(1)<CR>
snoremap <C-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(1)<CR>

" Ctrl-Shift-Tab: Previous Buffer
" - A simple approach:
"   noremap <C-S-Tab> :bN<CR>
"   inoremap <C-S-Tab> <C-O>:bN<CR>
"   onoremap <C-S-Tab> <C-C>:bN<CR>
"   snoremap <C-S-Tab> <C-C>:bN<CR>
noremap <C-S-Tab> :call <SID>BufNext_SkipSpecialBufs(-1)<CR>
inoremap <C-S-Tab> <C-O>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>
onoremap <C-S-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>
snoremap <C-S-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>

"map <silent> <unique> <script>
"  \ <Plug>DubsBufferFun_BufNextNormal
"  \ :call <SID>BufNext_SkipSpecialBufs(1)<CR>
"map <silent> <unique> <script>
"  \ <Plug>DubsBufferFun_BufPrevNormal
"  \ :call <SID>BufNext_SkipSpecialBufs(-1)<CR>
function s:BufNext_SkipSpecialBufs(direction)
  let start_bufnr = bufnr("%")
  let done = 0
  while done == 0
    if 1 == a:direction
      execute "bn"
    elseif -1 == a:direction
      execute "bN"
    endif
    let n = bufnr("%")
    "echo "n = ".n." / start_bufnr = ".start_bufnr." / buftype = ".getbufvar(n, "&buftype")
    "if (getbufvar(n, "&buftype") == "")
    "    echo "TRUE"
    "endif
     " Just 1 buffer or none are editable
    "if (start_bufnr == n)
    "      \ || ( (getbufvar(n, "&buftype") == "")
    "        \   && ( ((getbufvar(n, "&filetype") != "")
    "        \       && (getbufvar(n, "&fileencoding") != ""))
    "        \     || (getbufvar(n, "&modified") == 1)))
" FIXME Doesn't switch to .txt --> so set filetype for *.txt? another way?
    if (start_bufnr == n)
        \ || (getbufvar(n, "&modified") == 1)
        \ || ( (getbufvar(n, "&buftype") == "")
        \   && ((getbufvar(n, "&filetype") != "")
        \     || (getbufvar(n, "&fileencoding") != "")) )
      " (start_bufnr == n) means just 1 buffer or no candidates found
      " (buftype == "") means not quickfix, help, etc., buffer
      " NOTE My .txt files don't have a filetype...
      " (filetype != "" && fileencoding != "") means not a new buffer
      " (modified == "modified") means we don't skip dirty new buffers
      " HACK Make sure previous buffer works
      execute start_bufnr."buffer"
      execute n."buffer"
      let done = 1
    endif
  endwhile
endfunction

" NOTE Change :bn to :tabn and :bN to :tabN
"      if you'd rather have your tabs back

" -------------------------------------------------------------------

" ------------------------------------------------------
" Ctrl-J/Ctrl-K Traverse Buffer History
" ------------------------------------------------------
noremap <C-j> :BufferRingReverse<CR>
inoremap <C-j> <C-O>:BufferRingReverse<CR>
"cnoremap <C-j> <C-C>:BufferRingReverse<CR>
"onoremap <C-j> <C-C>:BufferRingReverse<CR>

" 2017-06-06: Remap <C-k>, so digraph insertion works from <C-l>,
"   and then I can continue using <C-j> and <C-k> for burfing surfing
"   (Ctrl-Tab and Ctrl-Shift-Tab also work, but my brain is really
"   wired to using C-j and C-k, so I prefer to keep those mappings.)
inoremap <C-l> <C-k>

" 2017-06-10: Vim's Ctrl-K maps to a :digraph feature, and we cannot remap
"  otherwise access the feature except through Ctrl-K...
noremap <C-k> :BufferRingForward<CR>
inoremap <C-k> <C-O>:BufferRingForward<CR>
"cnoremap <C-k> <C-C>:BufferRingForward<CR>
"onoremap <C-k> <C-C>:BufferRingForward<CR>

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

