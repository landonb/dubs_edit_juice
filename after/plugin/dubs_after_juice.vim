" File: after/dubs_after_juice.vim
" Author: Landon Bouma (landonb &#x40; retrosoft &#x2E; com)
" Last Modified: 2018.01.05
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: AutoAdapt wrapper.
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

" ------------------------------------------
" About:

if exists("g:after_juice_vim") || &cp
  finish
endif
let g:after_juice_vim = 1

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" After Effects
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Configure AutoAdapt
" ------------------------------------------------------

" AutoAdapt: "Automatically adapt timestamps, copyright notices, etc."
"   http://www.vim.org/scripts/script.php?script_id=4654
" Uses that author's ingo-library: "Vimscript library of common functions."
"   http://www.vim.org/scripts/script.php?script_id=4433

" We need to call an AutoAdapt function, which is exposed from an autoload
" plugin. Use an after script to ensure that autoload plugin is available.
"
" Note: We do, however, set a few globals *before* AutoAdapt loads. Search:
"         g:AutoAdapt_FirstLines/_LastLines

" HINT: Toggle with :NoAutoAdapt and then :Adapt

" See: ~/.vim/pack/vim-scripts/start/AutoAdapt/plugin/AutoAdapt.vim

" The plugin defaults to checking the top 25 and bottom 10 lines.
" [lb] is skipping the end of the file, though, since I never put
" my infos in the footer (and I'd rather not worry about something
" accidentally changing down there), and I'm halving the top count.

"let g:AutoAdapt_FirstLines = 13
"let g:AutoAdapt_LastLines = 0
" 2018-01-05: It might finally be time... just use :Gblame.
autocmd BufEnter,BufRead * NoAutoAdapt

" If AutoAdapt is running, you can't edit any datelines and save without
" AutoAdapt undoing what you just did (which is to try to pre-date things).
" You could :NoAutoAdapt, but that's annoying.
" I wanted to edit AutoAdapt's BufWritePre,FileWritePre autocmd, #Trigger,
" to see if the only changed line is the dateline, but I couldn't figure
" out how to get '[ and '] to work with the command.
" I got '[,']!meld <afile> to work, sorta: it would open meld, but
" 1. the original file is the _original_ file, and not even
"    what's saved on disk (so probably an old swap file?), and
" 2. after quiting meld so Vim can continue, Vim empties the buffer
"    and saves, and your file is now truncated.
" I would like to remap Ctrl-Shift-S, but Vim doesn't distinguish
" between upper and lowercase A to Z with Ctrl (though it does with
" the number/symbol row and the F1 keys, go figure). But we can map
" a crazier combo, Ctrl-Alt-S, which for some whatever reason isn't
" already mapped to an OS-level feature (like how Ctrl-Alt-L triggers
" the desktop manager to lock the machine and sleep the monitors).
" Built-ins:
"  vnoremap <C-S> <C-C>:update<CR>
"  noremap <C-S> :update<CR>
"  inoremap <C-S> <C-O>:update<CR>

" MAYBE: We should preserve the user's current NoAutoAdapt setting; for
"        now, always re-enabling it. Probably okay, since Ctrl-Alt-S is
"        a very deliberate thing keystroke.
nnoremap <C-M-S> :NoAutoAdapt<CR>:update<CR>:AutoAdapt<CR>
inoremap <C-M-S> <C-O>:NoAutoAdapt<CR><C-O>:update<CR><C-O>:AutoAdapt<CR>
" TEVS: I cannot seem to override visual select and Ctrl-Alt-S, always says,
"         E481: No range allowed
noremap <C-M-S> :NoAutoAdapt<CR>:update<CR>:AutoAdapt<CR>
snoremap <C-M-S> <C-O>:NoAutoAdapt<CR><C-O>:update<CR><C-O>:AutoAdapt<CR>

" 2017-11-05: I was thinking of disabling AutoAdapt if the user undid all
"   changes to the buffer, to allow them to go back to original Date and not
"   have it get updated when they save. (I usually forget about the "feature",
"   and then have to undo again, and then Ctrl-Shift-Save.)
" You maybe can tell if the user undid all changes by checking undo stack:
"   changenr() == 0
" but what if they have multiple undo trees?
" In any case, it doesn't matter, because setting noremap <C-S> here
" doesn't stick. (You can manually set it after Vim starts, but then
" you cannot use the <SID> identified but have to use a global function,
" e.g., capitalized:
"   function Autoadapt_aware_update()
" Here's the code I tried:
"   function s:autoadapt_aware_update()
"     if changenr() == 0
"       NoAutoAdapt
"     endif
"     update
"     if changenr() == 0
"       " FIXME/2017-11-05: Should honor whatever original setting was,
"       "   rather than blindly re-enabling.
"       "   Should also let user set bool to disable AutoAdapt...
"       AutoAdapt
"     endif
"   endfunction
"   noremap <C-S> :call <SID>autoadapt_aware_update()<CR><CR>
"   nnoremap <C-S> :call <SID>autoadapt_aware_update()<CR><CR>
"   inoremap <C-S> <C-O>:call <SID>autoadapt_aware_update()<CR><C-O><CR><C-O>
"   snoremap <C-S> <C-O>:call <SID>autoadapt_aware_update()<CR><C-O><CR><C-O>

" Copy 'n paste tests -- copy to top of file and uncomment, then save.
"   
"   " Last Changed: Fri 23 Jan 2015 00:57:07 C
"   " Modifiedddd: 2014 Jan 15
"   " Copyright: © 2009-2010, 2014 Your Name
"   " Copyright © 2011-2013 Your Name
"   " Copyright © 2009, 2009-2014 Your Name
"   " Copyright © 2009, 2009-2013 Your Name
"   " Copyright © 2014-2015 Your Name
"   " Copyright © 2014 Your Name
"   " Copyright © 2013, 2014-2015 Your Name
"   
"    Last Changed: Fri 23 Jan 2015 02:01:49 C
"   /// Last Changed: Fri 22 Jan 2015 00:57:07 C
"   /** Last Changed: Fri 22 Jan 2015 00:57:07 C
"   "Last Changed: Fri 23 Jan 2015 02:01:55 C
"   " Last Changed: Fri 23 Jan 2015 02:06:12 C
"   Last Changed: Fri 23 Jan 2015 02:07:15 C
"   /* Last Changed: Fri 23 Jan 2015 02:07:15 C
"   // Last Changed: Fri 23 Jan 2015 02:07:15 C
"   # Last Changed: Fri 23 Jan 2015 02:07:15 C
"   & Last Changed: Fri 22 Jan 2015 00:57:07 C
"   .. Last Changed: Fri 22 Jan 2015 00:57:07 C
"   ^ Last Changed: Fri 22 Jan 2015 00:57:07 C
"   $ Last Changed: Fri 22 Jan 2015 00:57:07 C
"   # Last Changed: 2015.01.22
"   /* Last Changed: 2015.01.22
"   // Last Changed: 2015-01-22
"   " Last Modified: 2015.01.08

if exists('*AutoAdapt#DateTimeFormat#ShortTimezone') != 0

" FIXME: I don't think the plugin is pushing the change on the Undo stack?

  " :h regexp  

  " The copyright starts must start the line or follow one or more comment
  " characters or spaces. The match is case-insensitive and you can use
  " the actuak © mark, if you want, or (c).
  let s:aa_patt_copyright = '\c\_^\%("\|#\|\/\*\|\/\/\|\.\.\||\)\?\s*\<Copyright:\?\%(\s\+\%((C)\|&copy;\|\%xa9\)\)\{0,2\}\s\+'

  " LastChangedModified must also start a line or follow opening comment.
  "  \C is match case
  "  \_^ is start of line
  "  \v means 'very magic'
  "  \%(\) is like \(\) but doesn't count it as a sub-expression.
  "  \zs matches at any position, and sets the start of the match there:
  "      the next char is the first char of the whole match.
  let s:aa_patt_last_modd = '\v\C\_^%("|#|\/\*|\/\/|\.\.|\|)?\s*%(<%(Last)?\s*%([cC]hanged?|[mM]odified)\s*:?\s+)\zs'
  "  The sole < does, um, not sure, but it may not be needed, cause it's not needed here:
  " script_last_modified starts a line.
  let s:aa_patt_script_last_modd = '\v\C\_^\s*%(script_last_modified\s*\=\s*%(''|")?)\zs'

  let g:AutoAdapt_Rules = [
  \   {
  \       'name': '(c) notice / {-LastYear} / E.g., "Copyright © 2009, 2011-2014 Your Name" to "Copyright © 2009, 2011-2015 Your Name"',
  \       'patternexpr': string(s:aa_patt_copyright) . '. ''[-, 0-9]*-\zs\('' . (strftime("%Y")-1) . ''\)\ze\>''',
  \       'replacement': '\=strftime("%Y")'
  \   },
  \   {
  \       'name': '(c) notice / {, LastYear} / E.g., "Copyright © 2009-2010, 2014 Your Name" to "Copyright © 2009-2010, 2014-2015 Your Name"',
  \       'patternexpr': string(s:aa_patt_copyright) . '. ''[-, 0-9]*,\s*\zs\('' . (strftime("%Y")-1) . ''\)\ze\%([-, 0-9]*'' . strftime("%Y") . ''\)\@!\>''',
  \       'replacement': '\=submatch(1) . "-" . strftime("%Y")'
  \   },
  \   {
  \       'name': '(c) notice / {LastYear} / E.g., "Copyright © 2014 Your Name" to "Copyright © 2014-2015 Your Name"',
  \       'patternexpr': string(s:aa_patt_copyright) . '. ''\zs\('' . (strftime("%Y")-1) . ''\)\ze\%([-, 0-9]*'' . strftime("%Y") . ''\)\@!\>''',
  \       'replacement': '\=submatch(1) . "-" . strftime("%Y")'
  \   },
  \   {
  \       'name': '(c) notice / {LastLastYear+} / E.g., "Copyright: © 2006, 2009-2013 Your Name" to "Copyright: © 2006, 2009-2013, 2015 Your Name"',
  \       'patternexpr': string(s:aa_patt_copyright) . '. ''[-, 0-9]*\s*\zs\%('' . strftime("%Y") . ''\)\@!\(\d\{4\}\)\ze[^,-]\+\>''',
  \       'replacement': '\=submatch(1) . ", " . strftime("%Y")'
  \   },
  \
  \   {
  \       'name': 'Last Change full timestamp 12h',
  \       'pattern': s:aa_patt_last_modd . '\a{3}(,?) \d{1,2} \a{3} \d{4} \d{2}:\d{2}:\d{2} [AP]M \u+',
  \       'replacement': '\=strftime("%a" . submatch(1) . " %d %b %Y %I:%M:%S %p ") . ' . string(AutoAdapt#DateTimeFormat#ShortTimezone())
  \   },
  \   {
  \       'name': 'Last Change full timestamp 24h day-month-year time',
  \       'pattern': s:aa_patt_last_modd . '\a{3}(,?) \d{1,2} \a{3} \d{4} \d{2}:\d{2}:\d{2} %([AP]M)@!\u+',
  \       'replacement': '\=strftime("%a" . submatch(1) . " %d %b %Y %H:%M:%S ") . ' . string(AutoAdapt#DateTimeFormat#ShortTimezone())
  \   },
  \   {
  \       'name': 'Last Change full timestamp 24h month-day time year',
  \       'pattern': s:aa_patt_last_modd . '\a{3}(,?) \a{3} \d{1,2} \d{2}:\d{2}:\d{2} \u+ \d{4}',
  \       'replacement': '\=strftime("%a" . submatch(1) . " %b %d %H:%M:%S ") . ' . string(AutoAdapt#DateTimeFormat#ShortTimezone()) . '. " " . strftime("%Y")'
  \   },
  \
  \   {
  \       'name': 'Last Change date year-month-day',
  \       'patternexpr': string(s:aa_patt_last_modd) . '. ''%('' . strftime("%Y[- ]%%(%b|%B)[- ]%d") . '')@!\d{4}([- ])(\a{2,16})\1\d{1,2}''',
  \       'replacement': '\=tr(strftime("%Y " . AutoAdapt#DateTimeFormat#MonthFormat(submatch(2)) . " %d"), " ", submatch(1))'
  \   },
  \   {
  \       'name': 'Last Change date year-mm-day [or year.mm.day]',
  \       'patternexpr': string(s:aa_patt_last_modd) . '. ''%('' . strftime("%Y[-. /]%m[-. /]%d") . '')@!\d{4}([-. /])(0\d|1[012])\1\d{1,2}''',
  \       'replacement': '\=tr(strftime("%Y %m %d"), " ", submatch(1))'
  \   },
  \   {
  \       'name': 'Last Change date day-month-year',
  \       'patternexpr': string(s:aa_patt_last_modd) . '. ''%('' . strftime("%d[- ]%%(%b|%B)[- ]%Y") . '')@!\d{1,2}([- ])(\a{2,16})\1\d{4}''',
  \       'replacement': '\=tr(strftime("%d " . AutoAdapt#DateTimeFormat#MonthFormat(submatch(2)) . " %Y"), " ", submatch(1))'
  \   },
  \   {
  \       'name': 'Last Change date month day, year',
  \       'patternexpr': string(s:aa_patt_last_modd) . '. ''%('' . strftime("%%(%b|%B) %d, %Y") . '')@!(\a{2,16}) \d{1,2}, \d{4}''',
  \       'replacement': '\=strftime(AutoAdapt#DateTimeFormat#MonthFormat(submatch(1)) . " %d, %Y")'
  \   },
  \
  \   {
  \       'name': 'script_last_modified = year-mm-day [or year.mm.day]',
  \       'patternexpr': string(s:aa_patt_script_last_modd) . '. ''%('' . strftime("%Y[-. /]%m[-. /]%d") . '')@!\d{4}([-. /])(0\d|1[012])\1\d{1,2}''',
  \       'replacement': '\=tr(strftime("%Y %m %d"), " ", submatch(1))'
  \   },
  \]

" \@! Matches with zero width if the preceding atom does NOT match at the current position.

else

  echomsg "Missing: AutoAdapt#DateTimeFormat#ShortTimezone"

endif

" So-called MS Windows mode
" ------------------------------------------------------

" 2017-04-03: Moved to after-juice from normal plugin/dubs_edit_juice
"   so that mswin.vim's Ctrl-x doesn't just dump "+x to the editor,
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
"     (In Vaniall Vim, Ctrl-X would "Subtract [count] from the number
"     or alphabetic character at or after the cursor." Seems like a
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
"     (In Vanilla Vim, Ctrl-Y would "Scroll window [count] lines
"     upwards in the buffer" which is not a feature I ever used.)
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

" ***

" New ``\cl`` command to swap selection and clipboard contents.

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
" - I.e., press `\cl` to swap highlighted text with clipboard contents.
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
" Mnemonic: 'cl'ippy swap. (Not really sold on it, just using... something.)
silent! unmap <leader>cl
vnoremap <leader>cl "ax"+gP:let @x=@+ \| let @+=@a \| let @a=@x \| let @"=@+ \| let @*=@+<CR>
nnoremap <leader>cl :let @x=@+ \| let @+=@a \| let @a=@x \| let @"=@+ \| let @*=@+<CR>
inoremap <leader>cl <C-O>:let @x=@+ \| let @+=@a \| let @a=@x \| let @"=@+ \| let @*=@+<CR>

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

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Switching Buffers/Windows/Tabs
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Ctrl-Tab is for Tabs, Silly... no wait, Buffers!
" --------------------------------
" mswin.vim maps Ctrl-Tab to Next Window. To be
" more consistent with Windows (the OS), Ctrl-Tab
" should map to Next Tab... but in this case, I'm
" going to deviate from the norm and ask that you
" tab-holders-onners let go and try thinking in
" terms of buffers. It's all about the buffers,
" benjamin! (baby?)

" TODO The cursor is not preserved between
"      buffers! So make code that restores
"      the cursor...

" This is Ctrl-Tab to Next Buffer
"noremap <C-Tab> :bn<CR>
"inoremap <C-Tab> <C-O>:bn<CR>
""cnoremap <C-Tab> <C-C>:bn<CR>
"onoremap <C-Tab> <C-C>:bn<CR>
"snoremap <C-Tab> <C-C>:bn<CR>
" 2017-06-10: C-S-Tab works, but C-Tab overridden by `behave mswin`.
"   So making these mappings an 'after' thought.
noremap <C-Tab> :call <SID>BufNext_SkipSpecialBufs(1)<CR>
inoremap <C-Tab> <C-O>:call <SID>BufNext_SkipSpecialBufs(1)<CR>
"cnoremap <C-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(1)<CR>
onoremap <C-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(1)<CR>
snoremap <C-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(1)<CR>

" This is Ctrl-Shift-Tab to Previous Buffer
"noremap <C-S-Tab> :bN<CR>
"inoremap <C-S-Tab> <C-O>:bN<CR>
""cnoremap <C-S-Tab> <C-C>:bN<CR>
"onoremap <C-S-Tab> <C-C>:bN<CR>
"snoremap <C-S-Tab> <C-C>:bN<CR>
noremap <C-S-Tab> :call <SID>BufNext_SkipSpecialBufs(-1)<CR>
inoremap <C-S-Tab> <C-O>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>
"cnoremap <C-S-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>
onoremap <C-S-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>
snoremap <C-S-Tab> <C-C>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>

"map <silent> <unique> <script>
"  \ <Plug>DubsBufferFun_BufNextNormal
"  \ :call <SID>BufNext_SkipSpecialBufs(1)<CR>
"map <silent> <unique> <script>
"  \ <Plug>DubsBufferFun_BufPrevNormal
"  \ :call <SID>BufNext_SkipSpecialBufs(-1)<CR>
""   2. Thunk the <Plug>
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
" FIXME Diff against previous impl
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

