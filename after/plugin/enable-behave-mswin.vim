" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

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
  " Map <Ctrl-V>, <Ctrl-X>, and <Ctrl-C> keys, and insert mode <Ctrl-Z>.
  "	  - CXREF: ~/.local/share/vim/vim91/mswin.vim
  "	    /Applications/MacVim.app/Contents/Resources/vim/runtime/mswin.vim @ 117
  source $VIMRUNTIME/mswin.vim
  behave mswin
endif

" Unmask nasty maps.
" - Do not overtake Ctrl-F. Not that I use Ctrl-F/Ctrl-B, because I generally
"   navigate away from the home row and use PageDown/PageUp instead, but I
"   know some hardcore Vimmers would riducule me for taking these keys away.
"   (In my defense, Ctrl-F and Ctrl-B are akward to type; I'd rather use one
"   hand and one finger and not have to stretch pinky and another finger to
"   scroll down and up through a file.)
" - SAVVY/2024-12-14: This doesn't seem to matter in MacVim — there is not
"   <C-f> find dialog map. Also in console (Mac)Vim, <C-f> in both insert
"   and normal modes starts a / search. In GUI MacVim, normal <C-f> pages
"   down, and insert <C-f> moves cursor forward a character.
"   - SPIKE: I'm curious if latest Linux Vim is the same.
"     - Also do we really need *two* unmap commands?
if has("gui_running")
  unmap <C-F>
endif
" Make sure to remove Find dialog response for Insert mode.
if has("gui_running")
  unmap! <C-F>
endif
" NOTE: Ctrl-F and Ctrl-B do not PageDown/PageUp from Insert mode,
"       but rather enter their respective characters into the buffer.

" Unsure why mswin.vim doesn't also map the reverse...
"
" CTRL-Tab is Previous window
" - REFER: :h CTRL-W_W
noremap <C-S-Tab> <C-W>W
inoremap <C-S-Tab> <C-O><C-W>W
cnoremap <C-S-Tab> <C-C><C-W>W
onoremap <C-S-Tab> <C-C><C-W>W

