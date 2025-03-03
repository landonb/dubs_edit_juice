" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3

" -------------------------------------------------------------------

" ABOUT:
"
" This script originally started to make Vim emulate
" EditPlus, but it's grown considerably since then to
" just make Vim a more comfortable editor all around
" (at least comfortable for the author, well, until
" I got more comfortable with Vim built-in commands
" and motions; but this script still provides some
" familiar GUI text editor niceties).
"
" This file maps a bunch of editing-related features
" to key combinations to help delete text, select text,
" edit text, move the cursor around the buffer, and
" perform single-key text searches within the buffer.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

let s:sourcing = 0

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_dubs_edit_juice_plugin

  let s:sourcing = 1
endif

if exists('g:loaded_dubs_edit_juice_plugin') || &cp

  finish
endif

let g:loaded_dubs_edit_juice_plugin = 1

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Editing Features -- Deleting Text
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Recover from accidental Ctrl-U
" ------------------------------------------------------

" CXREF: http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
"
" SAVVY: <c-g>u starts a new Undo set, so the C-u and C-w commands can be undone.
"
" REFER:
"   :help i_CTRL-U Insert mode: <c-u> deletes text entered in the current line.
"   :help i_CTRL-W Insert mode: <c-w> deletes word before cursor.
"   :help i_CTRL-G_u Insert mode: <c-g>u starts a new change.
"   :help ins-special-special Insert mode: Commands which start a new change.
"   :help undo-break
"
" REFER: Re: |i_backspacing| — Dubs uses backspace=indent,eol,start 
" - If 'start' omitted, you can only backspace over characters you
"   inserted from the current Insert session. Wow, that's a minf duck!
" - Note that 'start' stops at the start position of the current edit.
" - From the help: "allow backspacing over the start position of insert;
"   CTRL-W and CTRL-U stop once at the start position"
" - For example, if you type "foo", then move the cursor (anywhere) and
"   move it back to the end of "foo", then you type "bar", i.e., you've
"   typed "foobar". Now you <C-W> but Vim only deletes "bar", leaving
"   you with the "foo" scraps. So it takes 2 <C-W> sometimes to delete
"   a word. And while I sorta get this behavior, my brain's never adapted.
" - Use the db or dB motion instead.
"   - THANX: https://github.com/vim/vim/issues/964
" TL_DR: This <C-w> deletes to beg. of undo set, not beg. of word:
"   inoremap <c-w> <c-g>u<c-w>
" Here's a basic approach:
"   inoremap <C-w> <C-o>db
" Or more clobbery (which is how terminal readline <Ctrl-w> works):
"   inoremap <C-w> <C-o>dB
" REFER: |i_CTRL-\_CTRL-O| Re: <C-\><C-o> —
"   CTRL-\ CTRL-O is like CTRL-O but don't move the cursor
" - SAVVY: Without the <C-\>, if cursor is at end of line,
"   then <Ctrl-w> leaves last character of word undeleted.
" REFER: |undo-break| "Setting the value of 'undolevels' also closes
" the undo block.  Even when the new value is equal to the old value."
" - Somehow the <C-w> incantation below makes it so if you append to an
"   existing word and press <C-w>, Vim deletes the whole word, and not
"   just what you appended. (Because sometimes with built-in <Ctrl-W>,
"   you have to press it twice to delete to the start of the word.)
" - It took me a while to arrive at this solution, which seems to work
"   precisely how I want.
"   - My first approach was using |db| (or |dB|):
"         inoremap <C-w> <C-g>u<C-\><C-o>db
"     But this has some caveats:
"     - When cursor is at start of line, |db| deletes the last word
"       from the previous line, but it doesn't delete the newline.
"     - Each undo (e.g., <Ctrl-Z>) restores a single word at a time, whereas
"       undoing built-in <Ctrl-W> restores all deleted words at once.
"     - Each undo puts the cursor at the start of the restored word,
"       and not at the end of it (like <Ctrl-W> does).
"     - The operation is not dot-repeatable (not that you're likely to
"       dot-repeat an Insert mode map).
"   - I also tried an approach using a |g@|-repeatable |opfunc|, but I had
"     similar issues as using |db|.
"   - Fortunately this kludgy-feeling &g:undolevels approach seems to work well.
inoremap <silent> <C-w> <C-\><C-o>:if col('.') < col('$') \| let &g:undolevels = &g:undolevels \| endif<CR><C-w>

" Treat <C-u> (delete to start of line) similarly.
" - Here's the basic approach that deletes to start of
"   current insertion:
"     inoremap <C-u> <C-g>u<c-u>
" - Here's an approach whose undo leaves cursor at start of line,
"   not at the end:
"     inoremap <C-u> <C-g>u<C-\><C-o>d0
" And here's the approach same as we do for <C-w>, which means you
" never have to <Ctrl-U> twice to delete a line:
inoremap <silent> <C-u> <C-\><C-o>:if col('.') < col('$') \| let &g:undolevels = &g:undolevels \| endif<CR><C-u>

" -------------------------------------------------------------------

" -------------------------------------------------------------------
" Wire Ctrl-Left/-Right to Jumping Cursor by Word
" -------------------------------------------------------------------

" In both Normal and Insert modes, built-in <Ctrl-Left|Right> moves
" the cursor to start of prev|next word.
" - LazyVim reassigns <Ctrl-Left|Right> to resizing the window.
" - The <Ctrl-Right> here moves the cursor to end of the current word,
"   i.e., before the space, unlike built-in <Ctrl-Right>.
"
" DUNNO: I tried to inhibit the completion menu, which is kinda
" annoying as it pops up for every movement, but adding this
"   <C-O>:lua pcall(function() require("blink-cmp").hide() end)<CR>
" either before or after the <C-O>b and <C-O>e<Right> each causes error:
"   Error in decoration provider blink_cmp_ghost_text.line:
"     Error executing lua:
"       ...y/blink.cmp/lua/blink/cmp/completion/trigger/context.lua:105:
"     Cannot get line number 323 in cmdline mode. Only 0 is supported

function! s:wire_keys_move_to_word_previous_and_next() abort
  nnoremap <C-Left> b
  inoremap <C-Left> <C-O>b
  " Don't vmap C-Left, or after C-S-Left it'll keep selecting without
  " Shift pressed anymore:
  "   vnoremap <C-Left> b

  " Note the <right> (or `l`), otherwise cursor ends up between last two chars.
  nnoremap <C-Right> el
  inoremap <C-Right> <C-O>e<Right>
  " Don't vmap C-Right, or after C-S-Right it'll keep selecting without
  " Shift pressed anymore:
  "   vnoremap <C-Right> e
endfunction

call s:wire_keys_move_to_word_previous_and_next()

" -------------------------------------------------------------------

" -------------------------------------------------------------------
" Wire Alt-Shift-Left/-Right to Selecting from Cursor to Edge of Line
" -------------------------------------------------------------------

" Built-in <Shift-Alt-Left|Right> jumps to start of prev|next word,
" and in Insert mode stops Insert mode.

function! s:wire_keys_select_text_to_line_beg_and_end() abort
  " Alt-Shift-Left selects from cursor to start of line
  " (same as Shift-Home)
  nnoremap <M-S-Left> v0<C-G>
  inoremap <M-S-Left> <C-O>v0<C-G>
  " 2020-05-23: I added <CTRL-G> to switch from Visual mode to Select mode,
  " otherwise if the user Ctrl-C copies, the selection is deselected, which
  " is abnormal behavior.
  " - Because this is a visual mode mapping, is it still needed?
  vnoremap <M-S-Left> 0

  " Alt-Shift-Right selects from cursor to end of line
  " (same as Shift-End)
  nnoremap <M-S-Right> v$<C-G>
  inoremap <M-S-Right> <C-O>v$<C-G>
  vnoremap <M-S-Right> $
endfunction

call s:wire_keys_select_text_to_line_beg_and_end()

" -------------------------------------------------------------------

" ---------------------------------------------------------------------------
" Wire Ctrl-Shift-PageUp/-PageDown to Selecting from Cursor to Edge of Window
" ---------------------------------------------------------------------------

" Built-in <Shift-Ctrl-PageUp|PageDown> does nothing in Insert mode, but
" in Normal mode it starts Insert mode.
" - <Ctrl-PageUp|PageDown> does nothing in either mode.
" - Built-in <Shift-Alt-PageUp|PageDown is same as <Shift-PageUp|PageDown>
" and selects text by the pageful.

function! s:wire_keys_select_lines_to_window_first_and_last() abort
  " Much like Ctrl-PageUp and Ctrl-PageDown move the cursor to the top of
  " the window or to the bottom of the window, respectively, without changing
  " the view, Ctrl-Shift-PageUp and Ctrl-Shift-PageDown select text from the
  " cursor to the top or bottom of the window without shifting the view.

  " Ctrl-Shift-PageUp selects from cursor to first line of window
  nnoremap <C-S-PageUp> vH
  inoremap <C-S-PageUp> <C-O>vH
  vnoremap <C-S-PageUp> H

  " Ctrl-Shift-PageDown selects from cursor to last line of window
  nnoremap <C-S-PageDown> vL
  inoremap <C-S-PageDown> <C-O>vL
  vnoremap <C-S-PageDown> L
endfunction

call s:wire_keys_select_lines_to_window_first_and_last()

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Document Navigation -- Moving the Cursor
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Better Scrolling
" ------------------------------------------------------

" Map Ctrl-Up and Ctrl-Down to scrolling
" the window 'in the buffer', as the :help
" states. Really, it just moves the scrollbar,
" i.e., scrolls your view without moving your
" cursor.
function! s:wire_keys_scroll_window_sticky_cursor() abort
  " 2018-09-17/EXPLAIN: What's the magic that maps <C-y> to
  " scroll window upward, as opposed to Redo (which Dubs maps
  " to <C-y> at some point)? Is it down to load order?
  nnoremap <C-Up> <C-y>
  inoremap <C-Up> <C-O><C-y>

  nnoremap <C-Down> <C-e>
  inoremap <C-Down> <C-O><C-e>
endfunction

call s:wire_keys_scroll_window_sticky_cursor()

" -------------------------------------------------------------------

" ------------------------------------------------------
" Quick Cursor Jumping
" ------------------------------------------------------

function! s:Smart_PageUpDown(direction) abort
  let cursor_cur_line = line(".")
  if a:direction == 1
    let window_first_line = line("w0")
    if cursor_cur_line == window_first_line
      " Cursor on first visible line; scroll window one page up
      execute "normal! \<C-B>"
    endif
    " Move cursor to first visible line; make
    " sure it's in the first column, too
    execute 'normal H0'
  elseif a:direction == -1
    let window_last_line = line("w$")
    if cursor_cur_line == window_last_line
      " Cursor on last visible line; scroll window one page down
      execute "normal! \<C-F>"
    endif
    " Move cursor to last visible line; make
    " sure it's in the first column, too
    execute 'normal L0'
  else
    call confirm('EditPlus.vim: Programmer Error!', 'OK')
  endif
endfunction

" -------

" Builtin <Ctrl-PageUp|PageDown> does nothing in either mode.

" - EditPlus, among other editors, maps Ctrl-PageUp and Ctrl-PageDown to moving the
"   cursor to the top and bottom of the window (equivalent to H and L in Vim (which
"   also defines M to jump to the middle of the window, which is not mapped here)).
" - Note, too, that in some programs, C-PageUp/Down switches to the next/previous
"   tab/pane/window. In Dubs Vim, you can prev/next windows with Ctrl-Shift-Up/Down,
"   and you can prev/next tabs with Alt-Shift-Up/Down.
function! s:wire_keys_cursor_to_line_first_and_last() abort
  " Ctrl-PageUp moves cursor to the top of the window, or, if
  " it's already there, it scrolls up one viewable-window-full.
  nnoremap <C-PageUp> :call <SID>Smart_PageUpDown(1)<CR>
  inoremap <C-PageUp> <C-O>:call <SID>Smart_PageUpDown(1)<CR>
  " Ctrl-PageDown moves cursor to the bottom of the window, or, if
  " it's already there, it scrolls down one viewable-window-full.
  nnoremap <C-PageDown> :call <SID>Smart_PageUpDown(-1)<CR>
  inoremap <C-PageDown> <C-O>:call <SID>Smart_PageUpDown(-1)<CR>
endfunction

call s:wire_keys_cursor_to_line_first_and_last()

" -------

" On my laptop, my right hand spends a lot of time near
" (and using) the arrow keys, which are on the bottom
" of the keyboard, but the other navigation keys (home,
" end, page up and down and the ilk) are far, far away,
" at the top of the keyboard. But we can map those to
" Alt-Arrow Key combinations to make our hands happy
" (or is it to make our fingers frolicsome?).

" 2020-05-23: See long comment in wire_keys_jump_to_window_directionally:
" the fifteen seconds I tried to move Alt-Left/-Right to other keys, so
" that I could wire all Alt-Arrow keys to tmux-esque window pane switching.
" It was a disaster. These two motions, Alt-Left and Alt-Right, are hardwired
" in my brain. I use 'em all the time.

" SAVVY/2024-05-07: gvy: `gv` reselects the previous Visual area; `y` yanks.

" Built-in <M-Left|Right> moves cursor left or right, and stops
" Insert mode when run from Insert mode.

function! s:add_alt_left_alt_right_maps_move_cursor_to_line_beg_line_end() abort
  " Alt-Left moves the cursor to the beginning of the line.
  nnoremap <M-Left> <Home>
  inoremap <M-Left> <C-O><Home>
  vnoremap <M-Left> :<C-U> <CR>gvy :execute "normal! 0"<CR>
  " Alt-Right moves the cursor to the end of the line.
  nnoremap <M-Right> <End>
  inoremap <M-Right> <C-O><End>
  vnoremap <M-Right> :<C-U> <CR>gvy :execute "normal! $"<CR>
endfunction

call <SID>add_alt_left_alt_right_maps_move_cursor_to_line_beg_line_end()

" For macOS Parity (where <Cmd-Left>/<Cmd-Right> move cursor to line start/end).
function! s:add_cmd_left_cmd_right_maps_move_cursor_to_line_beg_line_end() abort
  " Cmd-Left moves the cursor to the beginning of the line.
  nnoremap <D-Left> <Home>
  inoremap <D-Left> <C-O><Home>
  vnoremap <D-Left> :<C-U> <CR>gvy :execute "normal! 0"<CR>
  " Cmd-Right moves the cursor to the end of the line.
  nnoremap <D-Right> <End>
  inoremap <D-Right> <C-O><End>
  vnoremap <D-Right> :<C-U> <CR>gvy :execute "normal! $"<CR>
endfunction

call s:add_cmd_left_cmd_right_maps_move_cursor_to_line_beg_line_end()

" -------

" 2011.01.16 Will I find this useful?
" 2020-02-08: Hahahaha, if I'd even remember to use it!
"             - I like it! Like pressing 'M' and then 'i'.
"
" Alt-F12 moves the cursor to the middle of the window,
" and starts editing.
"
" - This was mapped to Alt-End, but that did not feel right,
"   e.g.,
"
"     nnoremap <M-End> M0i
"     inoremap <M-End> <C-O>M<C-O>0
"     vnoremap <M-End> :<C-U>
"       \ <CR>gvy
"       \ :execute "normal! M0"<CR>
"
function! s:wire_key_insert_mode_middle_line() abort
  nnoremap <M-F12> M0i
  inoremap <M-F12> <C-O>M<C-O>0
  vnoremap <M-F12> :<C-U>
    \ <CR>gvy
    \ :execute "normal! M0"<CR>
endfunction

call <SID>wire_key_insert_mode_middle_line()

" -------------------------------------------------------------------

" NOTE: Adding the 'a' guioptions option as suggested by this unrelated
"       function to start a search with highlights but not moving cursor:
"         http://vim.wikia.com/wiki/Highlight_all_search_pattern_matches
function! s:YankSelectedTextAutomatically_ExceptOnmacOS() abort
  " Automatically copy text when (visually) selected w/ guioptions `a` flag.
  " - When text is selected, it is yanked into register *.
  " - Note that on macOS, this copies into the system clipboard,
  "   unlike on Linux, so we don't enable this on Mac.
  if !has('macunix')
    set guioptions+=a
  endif
endfunction

call s:YankSelectedTextAutomatically_ExceptOnmacOS()

" -------------------------------------------------------------------

" ------------------------------------------------------
" Toggle Tab Highlighting
" ------------------------------------------------------

" Enable to draw tabs with blue underline, and em spaces (digraph 1M).
" - Note that LazyVim shows tab characters with a very light angle >.
"   - SPIKE: What's the LazyVim plugin that does this?
"     - MAYBE: Add a toggle for the LazyVim feature.

if !hasmapto('<Plug>DubsEditJuice_ToggleTabHighlighting')
  " MAYBE/2024-12-28 14:06: Add s:sourcing so you can use <unique>?
  " - FIXME/2024-12-28 14:07: You should at least normalize usage.
  " - FIXME/2024-12-28 14:07: Also everything should be configurable
  "   so that when you change {lhs} you don't Breaking change everything.
  if s:sourcing
    nunmap <Leader>dt
    iunmap <Leader>dt
  endif

  " HSTRY/2024-12-09: Was <Leader>tab (as in \-t-a-b) but this feature
  " is rarely used, and I want to reclaim <Leader>t for motion commands).
  " - Moved under \d prefix along with other Dubs maps.
  nnoremap <silent> <unique> <Leader>dt <Plug>DubsEditJuice_ToggleTabHighlighting
  inoremap <silent> <unique> <Leader>dt <C-o><Plug>DubsEditJuice_ToggleTabHighlighting
  " Map <Plug> to an <SID> function.
  nnoremap <silent> <unique> <script>
    \ <Plug>DubsEditJuice_ToggleTabHighlighting
    \ :call <SID>ToggleTabHighlighting()<CR>
endif

" The function.
function! s:ToggleTabHighlighting() abort
  " Visualizing tabs <http://tedlogan.com/techblog3.html>
  " "So what do you do when you open a new source file and you're trying
  "  to figure out what tab style the last author used? (And how do you make
  "  sure you're doing the Right Thing to avoid mixing tab styles in your new
  "  code intermixed with the old code?) I find syntax highlighting useful. In
  "  gvim, I like seeing my tabs with underlines. (This tends not to work well
  "  on the text terminal for reasons I haven't been able to determine.) The
  "  following incantation will tell vim to match tabs, underline them in gvim,
  "  and highlight them in blue in color terminals."

  " REFER: If you're testing and the highlight remains enabled:
  "
  "   call clearmatches(winnr())

  if !exists('w:whitespace_tab_match_id')
    let w:whitespace_tab_match_id = -1
  endif

  if w:whitespace_tab_match_id == -1
    " some tabs: (		   			       					  	   					)
    " some em spaces: (                                       )
    if !hlexists('WhitespaceTab')
      highlight WhitespaceTab gui=underline guifg=blue ctermbg=blue
    endif
    if !hlexists('WhitespaceEmSpace')
      highlight WhitespaceEmSpace gui=reverse cterm=reverse
    endif
    let l:priority = 100
    let w:whitespace_tab_match_id = matchadd('WhitespaceTab', '\t', l:priority)
    let w:whitespace_ems_match_id = matchadd('WhitespaceEmSpace', ' ', l:priority)
    echo "Enabled Whitespace highlighing"
  else
    silent! call matchdelete(w:whitespace_tab_match_id)
    silent! call matchdelete(w:whitespace_ems_match_id)
    let w:whitespace_tab_match_id = -1
    let w:whitespace_ems_match_id = -1
    echo "Disabled Whitespace highlighing"
  endif
endfunction

" -------------------------------------------------------------------

" ------------------------------------------------------
" Count of Characters Selected
" ------------------------------------------------------

" NOTE I'm using Ctrl-# for now. It hurts my fingers to
"      combine such keys, but I don't use this command
"      that often and using the pound key seems intuitive.
" DEBAR/FIXEM Make this work on word-under-cursor
" NOTE Cannot get this to work on <C-3>, so using Alt instead
"vnoremap <M-3> :<C-U>
"  \ :.s/\S/&/g<CR>
"  \ :'<,'>s/./&/g<CR>

"vnoremap <M-3> :<C-U>
"  \ <CR>gvy
"  \ gV
"  \ g<C-G>

"nnoremap <Leader>k :g<C-G>
"nnoremap <Leader>k "sy:.,$s/<C-r>s//gc<Left><Left><Left>
"nnoremap <Leader>k g<C-G>

" DO THIS INSTEAD:
" I couldn't get the previous to work, so just do this:
"  Select your text, type <Ctrl-o>, then g<Ctrl-g>

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Editing Features -- Editing Text
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Correct Ctrl-Z While Text Selected
" ------------------------------------------------------

" Ctrl-Z is mapped to undo in Normal and Insert
" mode, but in Select mode it just lowercases
" what's selected!
" NOTE To lowercase in Select mode, type
"      <Ctrl-o> to start a command, then type
"        gu{motion},
"      e.g.,
"        <C-o>gu<DOWN>
"      (or <C-o>gu<UP>, it does the same thing).
"      (And guess what? gU uppercases.)
" HINT You can also select text, and then <C-O>U or <C-O>u
"      to uppercase or lowercase the selected text.
" HELP: To get help on <C-u>, in command mode (following the colon), try:
"          h c_CTRL-u
vnoremap <C-Z> :<C-U>
  \ :undo<CR>
vnoremap <C-Y> :<C-U>
  \ :redo<CR>

" NOTE For whatever reason, trying to map C-S-Z also remaps
"      C-Z, so I can't make Ctrl-Shift-Z into redo!
" Doesn't work: nnoremap <C-S-Z> :redo<CR>
" 2015.01.14: Experience shows that the Ctrl-[a-z] key mappings
"             are case insensitive... oh, well, too bad for us.

" -------------------------------------------------------------------

" ------------------------------------------------------
" Character Transposition
" ------------------------------------------------------

" Transpose two characters when in Insert mode.

function! s:CreateMaps_TransposeCharacters() abort
  " BWARE: This steals Vim's built-in i_CTRL-T, which inserts 'one shiftwidth of
  " indent'. But this plugin relocates that command to <Shift-Ctrl-D>, which by
  " default does the same as <C-D> and deletes 'one shiftwidth of indent'.
  " - Stock Vim: i_CTRL-T indents, and i_CTRL-D (and i_CTRL-SHIFT-D) dedents.
  " - Dubs Vim: i_CTRL-T transposes; i_CTRL-D dedents; and i_CTRL-SHIFT-D indents.
  "
  " SAVVY: Not adding a normal mode map. So CTRL-T still the Vim default,
  "          'Jump to [count] older entry in the tag stack (default 1).'
  " - Consequently, this binding findable via `:TabMessage imap`, but not `:TabMessage map`.

  inoremap <silent> <C-T> <C-o>:call g:embrace#edit_juice#TransposeCharacters()<CR>
  " For parity with DepoXy/dot-inputrc:
  "   \et": transpose-chars
  "   \eT": transpose-words
  " https://github.com/DepoXy/dot-inputrc#🎛️
  " - Though note we're not adding transpose-words.
  if has('macunix')
    inoremap <silent> † <C-o>:call g:embrace#edit_juice#TransposeCharacters()<CR>
  else
    inoremap <silent> <M-T> <C-o>:call g:embrace#edit_juice#TransposeCharacters()<CR>
  endif
endfunction

call s:CreateMaps_TransposeCharacters()

" ***

" Vim wires Insert mode <Ctrl-T> to insert indent |i_CTRL-T|.
" - Dubs puts indent at <Shift-Ctrl-D>, opposite <Ctrl-D> dedent.
"   - (Albeit using Alacritty.toml magic to enable <Shift-Ctrl> in
"      MacVim (because normally MacVim doesn't recognize <Shift-Ctrl>
"      differently than <Ctrl>, because of how Control sequences work)).
" - And since insert mode <Ctrl-T> doesn't work in help windows, anyway,
"   we might as well make it work like normal mode <Ctrl-T>, which is a
"   very common command to run in a help window!
function! s:CreateAutocmds_HelpFileInsertModeTagStackJump() abort
  augroup dubs-edit-juice--filetype-help-c-t
    au!

    autocmd FileType help if !&modifiable | inoremap <buffer> <C-t> <C-o>:exe "normal \<C-t>"<CR> | endif
  augroup END
endfunction

call s:CreateAutocmds_HelpFileInsertModeTagStackJump()

" -------------------------------------------------------------------

" ------------------------------------------------------
" Indent Selected Text
" ------------------------------------------------------

" Vim's <Tab> is used to move the cursor
" according to the jump list, but it's silly.
" I.e., in Insert mode, if you have nothing
" selected, <Tab> does what? Inserts a <Tab>.
" What happens if you have text selected?
" And I mean besides entering visual edit mode?
" My computer rings the bell and the Vim window
" does a quiet beep (so... nothing!).
"
" Thusly, use Tab/Shift-Tab to add/remove indents
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" SAVVY: Also remember that == smartly fixes
"        the indent of the line-under-cursor.

" REFER: See Vim's built-in i_CTRL-D and i_CTRL-T
" - i_CTRL-D dedents and i_CTRL-T indents by default.
"   - There is no i_CTRL-SHIFT-D to dedent (it indents).
"     - This is because many terminals (and MacVim) don't distinguish
"       between <Ctrl> and <Shift-Ctrl> keypresses.
" - Above, Dubs reassigns i_CTRL-T to transpose characters.
" - Here, Dubs rebinds dedent to i_CTRL-SHIFT-D (so it complements <C-D>).
"   - Note that this relies on external mechanisms to work, as detailed next.
"
" SAVVY: On macOS, sending <Shift-Ctrl> is tricky business.
" - It requires Alacritty (or similar terminal) bindings to work from terminal Vim:
"     https://github.com/DepoXy/depoxy/blob/1.2.13/home/.config/alacritty/alacritty.toml#L282-L350
" - And it requires Hammerspoon (or similar event interceptor) bindings to work from MacVim:
"     https://github.com/DepoXy/depoxy/blob/1.2.13/home/.hammerspoon/depoxy-hs.lua#L124-L175
" - From DepoXy development environment orchestrator:
"     https://github.com/DepoXy/depoxy#🍯

" SAVVY: This naive approach works, but it either moves the cursor to the first
" non-blank character (:set startofline); or it keeps the cursor position which
" changes relative to the text as you indent (:set nostartofline):
" 
"   inoremap <S-C-D> <C-O>:normal >><CR>
"
" REFER- Fortunately I found copy-pasta:
"   https://vi.stackexchange.com/questions/18310/keep-relative-cursor-position-after-indenting-with
func! CursorFriendlyIndent(ind)
  if &sol
    set nostartofline
  endif
  let vcol = virtcol('.')
  if a:ind
    norm! >>
    exe "norm!". (vcol + shiftwidth()) . '|'
  else
    norm! <<
    exe "norm!". (vcol - shiftwidth()) . '|'
  endif
endfunc
"
" CRUMB: <Shift-Ctrl-D> <S-C-D> <Ctrl-Shift-D> <C-S-D>
inoremap <S-C-D> <C-O>:call CursorFriendlyIndent(1)<CR>
" Except in MacVim where <S-C-*> maps to <C-*>, use <Shift-Alt-D> instead.
" - CRUMB: <Shift-Alt-D> (aka <M-S-D> <S-M-D> <Alt-Shift-D>)
" - Note that macOS `vim`/MacVim does not distinguish <Shift-Ctrl-D> apart
"   from <Ctrl-D> (they're both intrepeted as the same escape sequence),
"   so we'll also map <Shift-Alt-D> to indent.
" - REFER: Note there is a crafty way to make <Ctrl-Shift> work in vim/MacVim.
"   - See comment re: DepoXy in plugin/ctrl-backspace.vim
"     ~/.kit/nvim/landonb/dubs_edit_juice/plugin/ctrl-backspace.vim
inoremap <S-M-D> <C-O>:call CursorFriendlyIndent(1)<CR>
"
" Not necessary (builtin <C-D> behaves the same):
inoremap <C-D> <C-O>:call CursorFriendlyIndent(0)<CR>
"
" But we can 'enchance' built-in << and >>:
nnoremap >> :call CursorFriendlyIndent(1)<cr>
nnoremap << :call CursorFriendlyIndent(0)<cr>
"
" Visual mode is easy, because cursor position doesn't matter.
vnoremap <S-C-D> >gv
" For MacVim, where <S-C> input is stripped of the <S> (see comment above).
vnoremap <S-M-D> >gv

" Note that built-in normal mode CTRL-D Scrolls window Downwards
" (and CTRL-U Upwards).
" - Author mostly scrolls using PgDown and PgUp, as I'm sure lots of folx,
"   do, though sometimes I use <C-D> to scroll when my right hand is busy.
" - Dubs Vim reassigns CTRL-U to moving paragraph up (and CTRL-P down).
"   - This sorta leave normal CTRL-D all alone, i.e., there's no matching
"     binding to scroll up.
" - However, <S-C-D> by default is same as <C-D>.
"   - So we can assign scroll up to <S-C-D>.
"   - And then we can say that while Dubs changes the <C-U> binding, it at
"     least reassigns the original command to a different binding. So in
"     the end, no original command is left unbound, they've just been moved.
nnoremap <S-C-D> <C-U><CR>

" Make visual mode <C-D> work like built-in i_CTRL-D: dedent the selection.
" - Default visual mode <C-D> more like normal mode <C-D>: it scrolls
"   downward (and extends the selection).
"   - This strikes the author as counterintuitive. I generally expect
"     visual mode bindings to behave like their insert mode counterparts.
"     I.e., I'd except <C-D> to dedent the selection; so we do that here.
vnoremap <C-D> <gv

" ***

" -------------------------
" Left Justify Current Line
" -------------------------

" This just left-justifies (completely dedents) the current line.
" - HSTRY/2024-12-11: This was previously \x.
"   - But I've since moved most Dubs maps under \d.
"   - Trying \dd, mnemonic: dedent.
nnoremap <silent> <leader>dd :left<cr><END>a
inoremap <silent> <leader>dd <C-O>:left<cr><END>

" -------------------------------------------------------------------

" ------------------------------------------------------
" Ctrl-P/Ctrl-L Moves Paragraphs
" ------------------------------------------------------

" 2012.08.19: Move paragraphs up and down, like how that
"             one popular app lets you move notes around.
" - DUNNO/2024-05-08: Lost to the ages: Which 'popular' app?

" Move the paragraph under the cursor up a paragraph.
function! s:MoveParagraphUp() abort
  " The '.' is the current cursor position.
  let lineno = line('.')
  if lineno != 1
    let a_reg = @a
    " The basic command is: {"ad}{"aP
    " i.e., move the start-of-paragraph:    {
    "       yank to the 'a' register:       "a
    "       delete to the end-of-paragraph: d}
    "       move up a paragraph:            {
    "       paste from the 'a' register:    "aP
    "       move down a line:               j
    "        (becase the '{' and '}' cmds
    "         go the line above or below
    "         the paragraph)
    normal! {"ad}{"aPj
    let @a = a_reg
  endif
endfunction

" Move the paragraph under the cursor down a paragraph.
function! s:MoveParagraphDown() abort
  " The '.' is the current cursor position.
  let line_1 = line('.')
  " The '$' is the last line in the current buffer.
  " So don't do anything unless not the last line.
  let line_n = line('$')
  if line_1 != line_n
    let a_reg = @a
    " Go to top of paragraph:               {
    " yank and delete to the EOP:           a"d}
    " drop down another paragraph:          }
    " paste the yanked buffer:              "aP
    " move to the end of the paragraph:     }
    " move to the SOP (somehow this works): {
    " move down a line to be at SOP:        j
    normal! {"ad}}"aP}{j
    let @a = a_reg
  endif
endfunction

function! s:CreateMaps_MoveParagraph(seq_up = '<Leader>dK', seq_down = '<Leader>dJ') abort
  " Default Vim makes <Up> and <CTRL-P> map to [count] lines upward |linewise|.
  " Default Vim makes <CTRL-O> Go to [count] Older cursor posit in jump list.
  " Default Vim makes <CTRL-O> in insert mode start a replace operation...
  " Default Vim makes <CTRL-U> "Scroll window Upwards in the buffer."
  "
  " 2017-06-07: I want to use Ctrl-l for what was Ctrl-k (BufferRingForward) so
  "   that Ctrl-k can be used for :digraph insertions.
  "nnoremap <C-p> :call <sid>MoveParagraphUp()<CR>
  "inoremap <C-p> <C-O>:call <sid>MoveParagraphUp()<CR>
  "nnoremap <C-l> :call <sid>MoveParagraphDown()<CR>
  "inoremap <C-l> <C-O>:call <sid>MoveParagraphDown()<CR>
  "
  " 2017-06-10: I was fiddling with the existing Ctrl-j and Ctrl-k mappings,
  " for :BufferRingReverse and :BufferRingForward, and remapped these so that
  " I could use <Ctrl-l> to replace Vim's built-in <Ctrl-k> :digraph feature.
  execute 'nnoremap ' .. a:seq_up .. ' :call <SID>MoveParagraphUp()<CR>'
  execute 'inoremap ' .. a:seq_up .. ' <C-O>:call <SID>MoveParagraphUp()<CR>'
  " Crud. Remapping <C-i> also remaps <TAB>, da fuh!?
  "nnoremap <C-i> :call <sid>MoveParagraphDown()<CR>
  "inoremap <C-i> <C-O>:call <sid>MoveParagraphDown()<CR>
  " 2017-10-17: Crud again. Ctrl-p blocks the auto-complete ctrl-n/ctrl-p...
  "   :TabMessage map <c-p>
  "   o  <C-P>       * <C-C>:call <SNR>28_MoveParagraphDown()<CR>
  "   nv <C-P>       * :call <SNR>28_MoveParagraphDown()<CR>
  " Normally, it's:
  "   n  <C-P>       * :<C-U>CtrlP<CR>
  execute 'nnoremap ' .. a:seq_down .. ' :call <SID>MoveParagraphDown()<CR>'
  "inoremap <C-p> <C-O>:call <sid>MoveParagraphDown()<CR>
  " Without the insert mode blocker, it works.
  " Not sure how to see the old mapping, though...
  "   o  <C-P>       * <C-C>:call <SNR>28_MoveParagraphDown()<CR>
  "   nv <C-P>       * :call <SNR>28_MoveParagraphDown()<CR>
  " And trying to map it myself isn't working, e.g.:
  "   inoremap <C-p> <C-O>:<C-U>CtrlP<CR>
  " though CtrlP seems like the other CtrlP, the "Full path fuzzy
  " file buffer, mru, tag, ... finder with an intuitive interface."
endfunction

call s:CreateMaps_MoveParagraph('<Leader>dK', '<Leader>dJ')

" -------------------------------------------------------------------

" ------------------------------------------------------
" Auto-format selected rows of text
" ------------------------------------------------------

" Select the lines you want to reformat into a pretty paragraph and hit F2.
" NOTE If you select whole lines, back up the cursor one character so the
"      final line isn't selected. Otherwise, par doesn't prepend your new
"      lines with the common comment from each line, since the last line
"      appears as an empty line and its beginning doesn't match the other
"      lines' beginnings, so par doesn't do any prepending.
" NOTE A blog I found online suggests you can use the following command:
"        map <F2> {!}par w81
"      But I couldn't get this to work.
"      Also, I considered mapping from normal and insert mode, but the
"      selection the command makes extends back to the start of the function
"      I'm in, rather than selecting the paragraph I'm in, so for now we'll
"      just do a vmap and force the user to highlight the lines s/he wants
"      formatted.
" NOTE For some reason, I sometimes get a suffix, so explictly set to 0 chars.
" 2015.08.07: The author of par is tabist so I made my own.
"             See: https://github.com/landonb/parT
" FIXME:
"vnoremap <F2> :<C-U>'<,'>!par w79 s0<CR>
"vnoremap <F2> :<C-U>'<,'>!par 79gqr<CR>
"vnoremap <F2> :<C-U>'<,'>!par 79qr<CR>
" FIXME: Implement something like `par 79qrT4` to specify size of tab stop,
"        and then call
"   vnoremap <F2> :<C-U>execute "'<,'>!parT 79qr" . ((&expandtab == 0) ? "T".&tabstop : "")<CR>
vnoremap <F2> :<C-U>'<,'>!parT 79qr<CR>
" For commit files, I like narrower columns, 60 chars in width.
"vnoremap <S-F2> :<C-U>'<,'>!par 59gqr<CR>
"vnoremap <S-F2> :<C-U>'<,'>!par 59qr<CR>
vnoremap <S-F2> :<C-U>'<,'>!parT 67qr<CR>
" 2014.11.25: Can we also throw in seventy-wides?
"vnoremap <C-S-F2> :<C-U>'<,'>!par 69gqr<CR>
"vnoremap <C-S-F2> :<C-U>'<,'>!par 69qr<CR>
" 2020-01-28: Dob development (89 chars).
vnoremap <C-S-F2> :<C-U>'<,'>!parT 89qr<CR>
" 2015.11.25: 64? Hrmm
vnoremap <C-S-F3> :<C-U>'<,'>!parT 55qr<CR>
vnoremap <C-S-F4> :<C-U>'<,'>!parT 44qr<CR>

" Example of fetching input for command on vnoremap:
"    https://stackoverflow.com/questions/12805922/vim-vmap-send-selected-text-as-parameter-to-function
"  function s:My_Function(the_input)
"    echo(a:My_Function)
"  endfunction
"  func! GetSelectedText()
"    normal gv"xy
"    let result = getreg("x")
"    normal gv
"    return result
"  endfunc
"  vnoremap <F2> :<C-U>call <SID>My_Function(GetSelectedText())<CR>

" 2015.01.14: For pesky, very-wide reST tables, do a fluid re-widen,
"             and use the length of the first selected line rather
"             than a hard-coded width.
"             But first, some comments about visual mode maps:
" [lb] thought <C-R> dumped selected text, but this cmd indicates otherwise:
"     vnoremap <M-S-F2> :<C-U>echo '<,'><C-R>
" This works, but as soon as it executes, the "-- (insert) SELECT --"
" message overwrites it in the message tray, so you just see a flicker:
"     vnoremap <M-S-F2> :<C-U>echomsg virtcol("$")<CR>
" '<,'> supplies a range to a function, and when used with !,
"   pipes the range of text to stdout, and the response replaces
"   the selected text, e.g.,
"     vnoremap <M-S-F2> :<C-U>'<,'>!sed 's/.*/yougotjacked/'<CR>
" An example of how to run two commands in visual mode:
"   vnoremap <M-S-F2> :<C-U>let b:foo = virtcol("$")<CR>:<C-U>let b:bar = 77<CR>
" Anyway, here's the best fcn. I figured out: just use 'execute', dummy.
"   - Omit the 'fit' option, which tries to make all lines about the same
"     length, which has the side-effect of possibly making all lines narrower.
"   - Remember virtcol("$") is number of chars + 1 for first selected line.
vnoremap <M-S-F2> :<C-U>execute "'<,'>!parT " . (virtcol("$") - 1) . "qr"<CR>

" NOTE Normal mode and Insert mode <F1> are mapped to toggle-last-user-buffer
"      (:e #) because my left hand got bored or felt left-out or something
"      (my right hand's got the choice of BrowRight or F12 to toggle buffers,
"       which is apparently something I do quite frequently).

" FIXME: When reformatting FIXME and NOTE comments, you can run something like
"          :<,'>!par w40 h1 p8 s0
"        or
"          :<,'>!par w40 p8
"        But the p[N] value depends on the current indent...
"          you need to find the " FIXME and add the indent before that to 8...
" WORK-AROUND: If you run par on the second and subsequent lines (not the
"              FIXME or NOTE line) you can get the formatting you so desire.

" Read also "Formatting Your Source Code" and learn why
" keeping lines to 79 chars or less is a good practice.
"
"   http://www.gnu.org/prep/standards/html_node/Formatting.html

" -------------------------------------------------------------------

" ------------------------------------------------------
" Change Path Delimiters Quickly
" ------------------------------------------------------

" See: http://vim.wikia.com/wiki/Change_between_backslash_and_forward_slash

" Press f/ to change every backslash to a
"          forward slash, in the current line.
" Press f\ to change every forward slash to a
"          backslash, in the current line.
" The mappings save and restore the search
" register (@/) so you can continue a previous
" search, if desired (i.e., the previous search
" doesn't become '/' or '\').
if 0
  nnoremap <silent> f/
    \ :let tmp=@/<CR>:s:\\:/:ge<CR>:let @/=tmp<CR>
  nnoremap <silent> f<Bslash>
    \ :let tmp=@/<CR>:s:/:\\:ge<CR>:let @/=tmp<CR>
endif

" -------------------------------------------------------------------

" ------------------------------------------------------
" Ctrl-Return is Your Special Friend (Who Won't Comment)
" ------------------------------------------------------

" Ctrl-<CR> starts a new line without the comment leader.
nnoremap <C-CR> <Home><Down>i<CR><Up>
inoremap <C-CR> <C-o><Home><Down><CR><Up>

" -------------------------------------------------------------------

" ------------------------------------------------------
" Start Substitution Under Cursor
" ------------------------------------------------------

" Starts a substitution command on whatever the cursor's on.
" Usage: Highlight some text
"        Type Ctrl-o \s
" http://vim.wikia.com/wiki/Search_and_replace_the_word_under_the_cursor
" NOTE "s sets 's' as the next yank register;
"      y yanks the .,$ motion, which searches from the cursor
"      to end of file (so we don't find-replace matches before
"      the cursor; if you want to find-replace the whole file,
"      start from the first match or before);
"      C-r pastes from the 's' register;
"      the 3 lefts position the cursor between the second set of sticks.
"
" 2018-06-11: Here's the mapping that's served so well these past many years:
"   nnoremap <Leader>s "sy:.,$s/<C-r>s//gc<Left><Left><Left>
"
" 2018-06-11: SO RAD!! And here's the mapping that'll serve me even better:
" Center each substitution candidate as it's selected and highlighted!
" - SAVVY: Sometimes when you can the substitute command, the window
"   will continue to center as you change lines.
"   - Run :ZZwrap again if this happens (or let &so=0).
"
" BWARE/2025-01-24: Using this before :substitute command inhibits
" live preview if you `set inccommand=nosplit` or `=split`.
" - Depends how badly you like the `zz` behavior while you sub.
com! -nargs=* -complete=command ZZWrap
  \ call histadd(':', ':ZZWrap ' .. <q-args>)
  \ | let &scrolloff=999
  \ | exec <q-args>
  \ | let &so=0

" FIXME/2024-12-28: The maps below should be <Plug> maps,
" and the map sequences should be moved to init.lua/.vimrc.
" - Until then, dubs_edit_juice is simply very opinionated.

" BUGGN/2025-02-23: Since when did this start happening? (Neovide)
" - Normal mode \s doesn't affect cursor, though if you type, it
"   updates the command line correctly. And <Left>/<Right> work
"   in the command line, but there's no cursor (there's an errant
"   one in the buffer that didn't move when you pressed \n, though).
"   So it ~sorta~ works...
" - It's not an issue with ZZWrap — this has same problem:
"   nnoremap <Leader>s :.,$s/<C-R><C-W>//gc<Left><Left><Left>
" - WEIRD: This works and sends cursor to command line immediately:
"     nnoremap <Leader>s :.,$s/<C-R><C-W>//gc
"   - This sorta works but cursor doesn't go their until you use
"     the <Left> arrow or type a character! Huh:
"     nnoremap <Leader>s :ZZWrap .,$s/<C-R><C-W>//gc
" - At least the vmap approach works correctly! Which is what I
"   almost exclusively use. Which is probably why I hadn't noticed
"   this yet.
"   - Also I'd suggest demoing more advanced tree-sitter and LSP
"     substitute commands... though I appreciate this raw take on
"     it, and it "just works".
if exists('g:neovide')
  " KLUGE
  nnoremap <Leader>s :.,$s/<C-R><C-W>//gc
else
  nnoremap <Leader>s :ZZWrap .,$s/<C-R><C-W>//gc<Left><Left><Left>
endif
"
" Don't do insert mode, as \s is common enough in regex. Try \S# instead.
"  inoremap <Leader>s <C-o>:ZZWrap .,$s/<C-R><C-W>//gc<Left><Left><Left>
vnoremap <Leader>s :<C-U><CR>gv"sy:ZZWrap .,$s/<C-r>s//gc<Left><Left><Left>

" 2024-08-07: Alternative \S# uses '#' delims instead of '/', e.g., to
"             make it easier to write patterns that include path strings.
if exists('g:neovide')
  " KLUGE
  nnoremap <Leader>SS :.,$s#<C-R><C-W>##gc
else
  nnoremap <Leader>SS :ZZWrap .,$s#<C-R><C-W>##gc<Left><Left><Left>
endif
" We'll try this map in insert mode — in |regexp|, \S is opposite of \s and
" selects non-whitespace characters, which author rarely uses. So the few
" times you do use this, just be aware that you'll see the UX pause as Vim
" waits to see if you're typing this map or something else.
if exists('g:neovide')
  " KLUGE
  inoremap <Leader>SS <C-o>:.,$s#<C-R><C-W>##gc
else
  inoremap <Leader>SS <C-o>:ZZWrap .,$s#<C-R><C-W>##gc<Left><Left><Left>
endif
vnoremap <Leader>SS :<C-U><CR>gv"sy:ZZWrap .,$s#<C-r>s##gc<Left><Left><Left>

" When inccommand=nosplit, if you select multiple iskeywords, it yanks
" the word after what's selected. So disable it.
if get(g:, 'dubs_edit_juice_inccommand', 0)
  " ALTLY: These maps work with inccommand=nosplit
  "
  nnoremap <Leader>Ss :.,$s/<C-R><C-W>//gc<Left><Left><Left>
  vnoremap <Leader>Ss :<C-U><CR>gv"sy:.,$s/<C-r>s//gc<Left><Left><Left>
  "
  nnoremap <Leader>SS# :.,$s#<C-R><C-W>##gc<Left><Left><Left>
  inoremap <Leader>SS# <C-o>:.,$s#<C-R><C-W>##gc<Left><Left><Left>
  vnoremap <Leader>SS# :<C-U><CR>gv"sy:.,$s#<C-r>s##gc<Left><Left><Left>
endif

" See also: QuickfixSubstituteAll in plugin/dubs_quickfix_wrap.vim,
" which defines <Leader>S (\S) which find-replaces in all files
" listed in the quickfix window.

" -------------------------------------------------------------------

" Show substitute changes as you craft the :s command.
" - Though note this doesn't work with the :ZZWrap commands, above.
"
" THANX:
" https://bluz71.github.io/2019/03/11/find-replace-helpers-for-vim.html

if has("nvim")
  if get(g:, 'dubs_edit_juice_inccommand', 0)
    " Enable :substitute live preview.
    set inccommand=nosplit
  else
    set inccommand=
  endif
endif

" -------------------------------------------------------------------

" SAVVY/2024-12-18: Send cursor line to middle of window — Now from Insert mode!
" - AKA reposition the cursor line vertically in the middle of the window.

nnoremap <Leader>dz zz
inoremap <Leader>dz <C-O>zz

" Reposition cursor line 5 from the top.
nnoremap <Leader>dZ :exec "normal! zt5\<C-y>"<CR>
inoremap <Leader>dZ <C-O>:exec "normal! zt5\<C-y>"<CR>

" REFER: One user's mnemonic:
"
"     +--------------------------------+
"     ↑                                |
"     | c-e (keep cursor)              |
"     | H(igh)             zt (top)    |
"     |                    ^           |
"     |            ze      |      zs   |
"     | M(iddle)  zh/zH <--zz--> zl/zL |
"     |                    |           |
"     |                    v           |
"     | L(ow)              zb (bottom) |
"     | c-y (keep cursor)              |
"     ↓                                |
"     +--------------------------------+
"
" THANX: MacMartin
" https://stackoverflow.com/a/60607857/5332257

" -------------------------------------------------------------------

" ------------------------------------------------------
" Truncate and Pad Line to Specific Width
" ------------------------------------------------------
"
"http://vim.wikia.com/wiki/Add_trailing_blanks_to_lines_for_easy_visual_blocks

" truncate line 'line' to no more than 'limit' width
function! Truncate(line, limit) abort
  call cursor(a:line,a:limit)
  norm d$
endfunc

" Pad all lines with trailing blanks to 'limit' length.
function! AtOnce(limit) abort
  norm mm
  g/^/norm 100A
  g/^/call Truncate(getline('.'), a:limit)
  let @/=""
  norm 'm
endfunc
" AtOnce same as:
"  :g/^/exe "norm! 100A" | call cursor(getline('.'), 79) | norm d$

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Simple keyboard mappings to toggle special windows to help insert text.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Toggle ASCII Character Table
" ----------------------------
" - ~~Alt-Shift-1~~ // Toggle Cliptext
" EditPlus has a cool ANSI chart you can bring up quickly (<Alt-Shift-1>)
" (who isn't always referring to ANSI charts?).
" - Our Vim substitute is an even awesomer interactive ASCII table
"   by Christian Habermann,
"   - CharTab
"     http://www.vim.org/scripts/script.php?script_id=898
" - SAVVY: Does not work: nnoremap <M-!> <Leader>ct
"
" REFER/2024-12-10: Author for past number of years has referred
" to a Unicode table instead. I have it wired to OS <Cmd-U>, so
" I can open it from any app.
"   https://github.com/DepoXy/emoji-lookup#🙄
"
" HSTRY/2024-12-10: Was \ct but I've been moving Dubs maps under \d prefix.
" - HSTRY/2024-04-29: These used to be more prominent bindings, but this
"   resource is rarely (if ever) accessed.
"     nnoremap <M-!> <Plug>CT_CharTable
"     inoremap <M-!> <C-o><Plug>CT_CharTable<ESC>
" - Mnemonic: \dA → Dubs ASCII
nnoremap <Leader>dA <Plug>CT_CharTable
inoremap <Leader>dA <C-o><Plug>CT_CharTable<ESC>

" TODO imap does not restore i-mode when ct done
" NOTE Modified chartab.vim to alias <ESC> and
"      <M-!> to 'q'
" NOTE chartab.vim opens in new buffer in same
"      window, rather than creating new vertical
"      window on left of view and opening there
"      NOTE You can work-around by opening in
"           QFix window
"           i.e., Alt-Shift-2 followed by
"                 Alt-Shift-1

" -------------------------------------------------------------------

" Toggle Tag List
" ---------------------------------------
" Show the ctags list.
" - HSTRY/2024-04-29: Previously at <Shift-Alt-6>. Promoted to see
"   if tag list will get used now. (Decade-long A/B testing.)
"     nnoremap <M-^> :TlistToggle<CR>
"     inoremap <M-^> <C-O>:TlistToggle<CR>
"     " cmap <M-^> <C-C>TlistToggle<ESC>
"     " omap <M-^> <C-C>TlistToggle<ESC>
if has('macunix')
  nnoremap ⁄ :TlistToggle<CR>
  inoremap ⁄ <C-O>:TlistToggle<CR>
else
  nnoremap <M-!> :TlistToggle<CR>
  inoremap <M-!> <C-O>:TlistToggle<CR>
endif

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Setup ctags
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Jump to tag under cursor
" ------------------------------------------------------

" Note that Vim maps Ctrl-] differently in Insert and Normal modes:
" - In Normal mode, Ctrl-] jumps to the tag under the cursor
" - In Insert mode, Ctrl-] completes the abbreviation being typed,
"   without inserting a character (normally an abbreviation is not
"   completed until a non-abbrev character is typed, and then both
"   the abbreviation and the non-abbrev character are inserted).
"   Or as Vim puts it:
"     *Trigger abbreviation, without inserting a character.*
" DUNNO/2025-01-24: <Ctrl-]> works in Insert mode for me...
"
" 2021-01-16: For the past, I dunno, decade, I guess, I've mapped
" Ctrl-] to jump to declaration from either Insert or Normal mode.
" - Then recently I was reminded of the other Ctrl-] behavior, and
"   I realized I sometimes complete an abbreviation and then delete
"   the extra character (usually the `TTT` abbreviation).
" - So let's resurrect the silent abbreviation completer,
"   but at a new key combination.
" - I don't use this command *too* often, so I didn't think too hard
"   about the mapping -- I just went with something close, something
"   with a Levenshtein distance of just 2:
"
"     Change `Ctrl-]` → `Meta-[`.
"
"   (Note that, AFAICT i_Meta-[ unused, and free for the taking.)
" - Ref: i_Ctrl-], i_Ctrl-], but not i_Meta-[ (no help).
"
"     #better-Vim-defaults
"
" if has('macunix')
"   inoremap <silent> “ <C-]>
" else
"   inoremap <silent> <M-[> <C-]>
" endif

" Ctrl-] jumps to the tag under the cursor, but only in normal mode.
" Let's make it work in Insert mode, too.
" - SPIKE/2024-12-11: Does this inhibit <C-]> from completing iabbrev?
"nnoremap <silent> <C-]> :call <SID>GrepPrompt_Auto_Prev_Location("<C-R><C-W>")<CR>
inoremap <silent> <C-]> <C-O>:tag <C-R><C-W><CR>
" Selected word
vnoremap <silent> <C-]> :<C-U>
  \ <CR>gvy
  \ :execute "tag " . @@<CR>

" Ctrl-t jumps back after a Ctrl-], but I have two issues with this. One,
" I've got Ctrl-t mapped to Transpose Characters in Insert mode. But more
" importantly, Two, Why isn't this Ctrl-[? That seems intuitive, and it's
" closer to the key you just pressed (by default, Ctrl-[ does the same thing as
" <Esc>, and I've already got enough escapes mapped).

" Hmpf. I cannot get this to work right now. It remaps all my other Escapes,
" too... and <C-}>, <C-S-]> and <C-S-}> don't work, either
"inoremap <C-[> <C-O>:normal <C-t><CR>
"vnoremap <C-[> :<C-U>
"  \ <CR>gvy
"  \ gV
"  \ :normal <C-t><CR>
" Whatever, use Alt-] to jump a tag back.
nnoremap <M-]> :normal <C-t><CR>
inoremap <M-]> <C-O>:normal <C-t><CR>
vnoremap <M-]> :<C-U>
  \ <CR>gvy
  \ gV
  \ :normal <C-t><CR>

" ctags
" cd $cp/pyserver
" ctags -R
" cd $cp/flashclient
" # NOTE --exclude=build is all that works, not flashclient/build or
" #      even /build or build/. I even tried using "./quotes".
" #      But if you run the following command with --verbose=yes
" #        ctags -R --exclude=build --verbose=yes
" #      You can verify that the build directory (and only the build directory)
" #      is excluded by looking for the line
" #        excluding "build"
" ctags -R --exclude=build

"       vi -t tag   Start vi and position the cursor at the  file  and  line
"                   where "tag" is defined.
"
"       :ta tag     Find a tag.
"
"       Ctrl-]      Find the tag under the cursor.
"
"       Ctrl-T      Return  to  previous  location  before  jump to tag

"Jumping to a tag

"    * You can use the 'tag' ex command. For example, the command ':tag <tagname>' will jump to the tag named <tagname>.
 "   * You can position the cursor over a tag name and then press Ctrl-].
 "   * You can visually select a text and then press Ctrl-] to jump to the tag matching the selected text.
 "   * You can click on the tag name using the left mouse button, while pressing the <Ctrl> key.
 "   * You can press the g key and then click on the tag name using the left mouse button.
 "   * You can use the 'stag' ex command, to open the tag in a new window. For example, the command ':stag func1' will open the func1 definition in a new window.
 "   * You can position the cursor over a tag name and then press Ctrl-W ]. This will open the tag location in a new window.
"
"Help: :tag, Ctrl-], v_CTRL_], <C-LeftMouse>, g<LeftMouse>, :stag, Ctrl-W_]

"    * You can list all the tags matching a particular regular expression pattern by prepending the tag name with the '/' search character. For example,
"
":tag /<pattern>
":stag /<pattern>
":ptag /<pattern>
":tselect /<pattern>
":tjump /<pattern>
":ptselect /<pattern>
":ptjump /<pattern>

" -------------------------------------------------------------------

" ------------------------------------------------------
" easytags configuration
" ------------------------------------------------------

" Don't print message when tags are updated.
let g:easytags_suppress_report = 1

" Use project-specific tags files and not the global ~/.vimtags.
" 2017-11-08: Ug. This is the culprit. Out, damn spot!
"   (Let project-specific tags= work on boot, e.g., via .trustme.vim.)
"set tags=./tags

"let g:easytags_dynamic_files = 1
let g:easytags_dynamic_files = 2

" [lb] seeing a sluggish Vim after saving a file (closing and reopening
" the file works until the next save; this problem does not always happen,
" either), so trying aynchronous easytags updating.
let g:easytags_async = 1

let g:easytags_auto_update = 0

" -------------------------------------------------------------------

" ------------------------------------------------------
" Vim Wild Menu (wildmenu)
" ------------------------------------------------------

" In Insert mode, use Ctrl-P and Ctrl-N to cycle through
" an auto-completion list from your tags file.
" Completion happens according to wildmode.
" See also :help cmdline-completion
set wildmode=list:longest,full

" -------------------------------------------------------------------

" ------------------------------------------------------
" Obsolete ActionScript tags code...
" ------------------------------------------------------

" From
" http://vim-taglist.sourceforge.net/extend.html
" actionscript language
let tlist_actionscript_settings = 'actionscript;c:class;f:method;p:property;v:variable'

" FIXME add ctags to Makefile instead of daily.sh
"CTAGLANGS = --langdef=actionscript \
"--langmap=actionscript:.as \
"--regex-actionscript='/^[ \t]*[(private| public|static) ( \t)]*function[\t]+([A-Za-z0-9_]+)[ \t]*\(/\1/f, function, functions/' \
"--regex-actionscript='/^[ \t]*[(public) ( \t)]*function[ \t]+(set|get) [ \t]+([A-Za-z0-9_]+)[ \t]*\(/\1 \2/p,property, properties/' \
"--regex-actionscript='/^[ \t]*[(private| public|static) ( \t)]*var[  \t]+([A-Za-z0-9_]+)[\t]*/\1/v,variable, variables/' \
"--regex-actionscript='/.*\.prototype \.([A-Za-z0-9 ]+)=([ \t]?)function( [  \t]?)*\(/\1/f,function, functions/' \
"--regex-actionscript='/^[ \t]*class[ \t]+([A-Za-z0-9_]+)[ \t]*/\1/c,class, classes/'
"
".PHONY: ctags
"ctags:
"-rm -f TAGS
"find . -name "*.as" -or -name "*.mxml" | ctags -eL - $(CTAGLANGS)
"
" FIXME The article at http://vim-taglist.sourceforge.net/extend.html
"       is wrong
"       Specifically, it doesn't recognize override or protected, and set|get
"       is broken. See my .ctags file for the appropriate command.

"--regex-actionscript=/^[ \t]*[(override)[ \t]+]?[(private|protected|public)][ \t]+[(static)[ \t]+]?function[ \t]+[(set|get)]*[ \t]+([A-Za-z0-9_]+)[ \t]*\(/\1 \2/p,property, properties/

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Macros
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Think of 'em as personal assistants:
" teach 'em once, then have them repeat.

" Single-Key Replays with Q
" --------------------------------
" This is a shortcut to playback the recording in
" the q register.
"   1. Start recording with qq
"   2. End recording with q (or with
"      Ctrl-o q if in Insert mode)
"   3. Playback with Q
"
" BWARE: This replaces builtin `Q` command, which switches to "Ex" mode.
" - SAVVY: But you can run `gQ` instead. It's the same as `Q`, but with
"   command-line editing and completion enabled.
" - DUNNO: Why doesn't `normal! Q` or `execute 'normal! Q'` bypass the map?

nnoremap Q @q

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Developer Specials
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ------------------------------------------------------
" Capture Ex Output So You Can
"     Do With It As You Please
" ------------------------------------------------------
" http://vim.wikia.com/wiki/Capture_ex_command_output

" ------------------------------------------------------
" Basic Ex output Capture
" ------------------------------------------------------

"   :redir @a
"   :set all " or other command
"   :redir END
" and use "ap to put the yanked

" ------------------------------------------------------
" Advanced Ex output Capture
" ------------------------------------------------------

" SAVVY/2024-12-11: You can also print command output to
" the current buffer.
"
" - E.g., to see messages, run:
"
"     pu=execute('messages')

" TabMessage runs the specified command
" and pastes the output to a new buffer
" in a new tab
function! s:TabMessage(cmd) abort
  " Avoid "E121: Undefined variable: l:message":
  let l:message = ''
  " Redirect Ex output to a varibale
  " we'll call 'message'
  redir => l:message
  silent execute a:cmd
  redir END
  " Create a new tab and put the
  " captured output
  tabnew
  silent put=l:message
  " Tell Vim not to ask us to save
  " when we close the buffer
  setlocal buftype=nowrite
  " Hide new buffers when they're unloaded from a window,
  " so you don't end up with a bunch on [No Name] buffers.
  setlocal bufhidden=wipe
endfunction
" Map our TabMessage function to an Ex :command
" of the same name
command! -nargs=+ -complete=command TabMessage call <SID>TabMessage(<q-args>)
" Usage, e.g.,
"   :TabMessage highlight
"   :TabMessage ec g:
" Shortcut
"   :Tab<TAB>     using autocompletion
"   :ta<TAB><TAB> also works

" ***

" CALSO: <Alt-W>o aliases <Ctrl-W>o | <Alt-F>o aliases \dT
" - From https://github.com/landonb/dubs_appearance#💅
"   ~/.kit/nvim/landonb/dubs_appearance/plugin/mimic_menu_keymap.vim

nnoremap <silent> <Leader>dT :exec 'tabedit ' .. expand('%')<CR>
inoremap <silent> <Leader>dT <C-o>:exec 'tabedit ' .. expand('%')<CR>

" -------------------------------------------------------------------

" ------------------------------------------------------
" Start Command w/ Selected Text
" ------------------------------------------------------

" Default: let &history=50
" - REFER: |'history'|
set history=1000

" For help with Command Line commands, see :h cmdline
" Note that <C-R> is search in Insert mode but starts a
" put in Command mode. Also note that <Ctrl-R> is
" interpreted literally and does nothing; use <C-R>.

" The :? :" :> maps are restricted to certain files types,
" but :: seems like it might be useful from any buffer.
"  vnoremap : :<C-U><CR>gvy:<C-R>"

" REFER: Neovim (0.10+?) supports
"        `:lua` to run selected code, or
"        `:.lua` to run current line.

" SAVVY: Without histadd, only adds to history if you edit command first.
vnoremap :: :<C-U>
  \ <CR>gvy
  \ :call histadd('cmd', @")<CR>
  \ :<C-R>"

function! s:CreateAutocmdMapsVimFunctions(noshowmode = 1) abort
  augroup dubs_edit_juice-vim-commands
    au!

    " SAVVY/2024-12-09: Select text and type `:?` to run |:help| on it.
    " - Question is, what's a visual mode binding you're not likely to type
    "   normally? I'll often select text and start typing to replace it.
    "   - I considered ':h' at first (seems obvious; matches the `:h` command).
    "   - But ':?' is also an interesting choice, and it's quicker to type
    "     (you can hold down <Shift> with your right hand and thump-thump
    "     colon-question easily with another finger).
    " - Note that :help |tags-definitions| may contain |single 'quotes'|,
    "   but Vim returns error if help tag |uses "double"| quotes, e.g.,
    "     E149: Sorry, no help for vim-"double"-mint
    "   though you'll see the tag listed in the tags file.
    "   - We'll still escape them, though, so user doesn't see error
    "     from the map, just from :help.
    autocmd FileType vim,lua,rst,markdown,txt vnoremap <buffer>
      \ :? :<C-U><CR>gvy:call histadd('cmd', 'help ' .. escape(@", '"'))<CR>:help <C-R>"<CR>

    " SAVVY/2024-12-22: Select text and type `:?` to |:echom| it.
    " - BWARE: If modeline shows `-- INSERT --`, user won't see echom
    "   message. They can read it via :messages, but it feels weird that
    "   nothing seems to happen.
    "   - As such, disable showmode |smd| by default so user sees `echom`
    "     message immediately when they run the `:"` command.
    if a:noshowmode == 1
      set noshowmode
    endif
    " - Note the escape in case selection contains double quotes,
    "   e.g., --> 'foo "bar" <-- --> "'baz' quux" <--
    autocmd FileType vim,lua,rst,markdown,txt vnoremap <buffer>
      \ :" :<C-U><CR>gvy:call histadd('cmd', 'echom ' .. escape(@", '"'))<CR>:echom <C-R>"<CR>

    " SAVVY/2024-12-26 08:14: Select text and type :> to |:call| it.
    " - Dunno, :) seems obvious, because Fcn() has parentheses. But :>
    "   is easier to type (and period sometimes means to run something?).
    " - FTREQ: Strip leading 'function!' and esp. trailing 'abort'
    autocmd FileType vim,lua,rst,markdown,txt vnoremap <buffer> <silent>
      \ :> :<C-U><CR>gvy:call <SID>CallSelected(@")<CR>
  augroup END
endfunction

call s:CreateAutocmdMapsVimFunctions()

function! s:CallSelected(text) abort
  let l:fcncall = a:text
  let l:fcncall = substitute(l:fcncall, '^\%(\s\|\r\|\n\)*function!\?\%(\s\|\r\|\n\)\+', '', '')
  let l:fcncall = substitute(l:fcncall, '\%(\s\|\r\|\n\)\+abort\%(\s\|\r\|\n\)*$', '', '')

  call histadd('cmd', 'call ' .. l:fcncall)

  execute 'call ' .. l:fcncall
endfunction

" -------------------------------------------------------------------

" ------------------------------------------------------
" Lorem Ipsum Dump
" ------------------------------------------------------
" By Harold Giménez
"   http://awesomeful.net/posts/57-small-collection-of-useful-vim-tricks
"   http://github.com/hgimenez/vimfiles/blob/c07ac584cbc477a0619c435df26a590a88c3e5a2/vimrc#L72-122

" Define :Lorem command to dump a paragraph of lorem ipsum
command! -nargs=0 Lorem :normal! iLorem ipsum dolor sit amet, consectetur
      \ adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore
      \ magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
      \ ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
      \ irure dolor in reprehenderit in voluptate velit esse cillum dolore eu
      \ fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non
      \ proident, sunt in culpa qui officia deserunt mollit anim id est
      \ laborum.

" HSTRY/2024-12-09: Not that we need a metasyntactic jargon dumper, but
" I just added :?, looked down, saw :Lorem, and adding a foobar dumper
" immediately came to mind!
" - REFER: https://en.wikipedia.org/wiki/Metasyntactic_variable#General_usage
"          https://en.wikipedia.org/wiki/Foobar
"          https://en.wikipedia.org/wiki/Colossal_Cave_Adventure
"          https://en.wikipedia.org/wiki/Jargon_File
"   - Wibble, wobble, wubble, and flob are also used in the UK.
"       http://www.catb.org/~esr/jargon/html/M/metasyntactic-variable.html
"         "Ah, that's the quux of the matter!”"
command! -nargs=0 Foobar :normal! ifoo, bar, baz, qux, quux, quuz, corge, grault,
      \ garply, waldo, fred, plugh, xyzzy, thud,
      \ wibble, wobble, wubble, flob, bazola, ztesch,
      \ foo, bar, thud, grunt,
      \ foo, bar, bletch,
      \ foo, bar, fum,
      \ fred, barney, jim, sheila,
      \ flarp,
      \ zxc, spqr, wombat,
      \ shme,
      \ foo, bar, baz, bongo, 
      \ spam, eggs,
      \ snork,
      \ foo, bar, zot,
      \ blarg, wibble,
      \ toto, titi, tata, tutu,
      \ pippo, pluto, paperino,
      \ aap, noot, mies,
      \ oogle, foogle, boogle; zork, gork, bork,
      \ foobar, foobaz, barf, mumble, baaaaaaz,
      \ quuxo, quuxare, quuxandum, quux, quuces, quuxes, quuxu, quuxuum.

" -------------------------------------------------------------------

" ------------------------------------------------------
" From /usr/share/vim/vim74/vimrc_example.vim
"      /usr/share/vim/vim74/gvimrc_example.vim
" ------------------------------------------------------

" Convenient command to see the difference between the current
" buffer and the file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
    \ | wincmd p | diffthis
endif

" ------------------------------------------------------
" Toggle diff highlighting in a single window
" ------------------------------------------------------
" From:
"   http://vim.wikia.com/wiki/A_better_Vimdiff_Git_mergetool
" Disable one diff window during a three-way diff allowing you to cut out the
" noise of a three-way diff and focus on just the changes between two versions
" at a time. Inspired by Steve Losh's Splice
" - DUNNO/2024-12-09: Why was this called Toggle when it did no such thing?
"   - I added a guard clause to restore non-diff mode when called again.
function! s:DiffToggle(window) abort
  if &diff
      let l:prev_window = winnr()
      let l:prev_cursor = getpos('.')

      windo diffoff
      windo set noscrollbind
      windo set nocursorbind

      exe l:prev_window . "wincmd w"
      call setpos('.', l:prev_cursor)

      return
  endif

  " Save the cursor position and turn on diff for all windows
  let l:save_cursor = getpos('.')
  windo diffthis
  " Turn off diff for the specified window (but keep scrollbind) and move
  " the cursor to the left-most diff window
  exe a:window . "wincmd w"
  diffoff
  set scrollbind
  set cursorbind
  exe a:window . "wincmd " . (a:window == 1 ? "l" : "h")
  " Update the diff and restore the cursor position
  diffupdate
  call setpos('.', l:save_cursor)
endfunction
" Toggle diff view on the left, center, or right windows
nnoremap <silent> <Leader>dDl :call <SID>DiffToggle(1)<cr>
nnoremap <silent> <Leader>dDc :call <SID>DiffToggle(2)<cr>
nnoremap <silent> <Leader>dDr :call <SID>DiffToggle(3)<cr>

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Other Functions
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" -------------------------------------------------------------------

" -------------------------------------------------------------------------------
" 2017-08-02: Source a .vim file in or up path, to support continuous integration
" -------------------------------------------------------------------------------
" E.g., run a rake task when Ruby files are saved.
" E.g., set tags= when a file is opened.

" FIXME/2017-08-02: Document this. And maybe move to a different file/new plugin.

" WHATEVER/2017-08-02: If you use the project.vim plugin and double click a
" file, neither BufEnter nor BufRead get called on the newly opened file.
" BufEnter instead gets called on the .vimprojects file in the left window,
" and BufRead isn't triggered at all. If you leave the window and reenter it,
" then BufEnter is triggered (but not BufRead).
" (TabEnter and WinEnter seemed to be called, but not BufWinEnter or BufNew.
"  I think.)
" FORTUNATELY! The project.vim plugin has a feature that sources a Vim file
" when you open a file in or under a directory. Just set in="somefile.vim".
" That, in conjunction with the BufEnter hook, provide the complete solution.
" 2017-11-08: Actually, no. The path is still wrong from project.vim...
"   it's still project.vim's path...

if ! exists("g:DUBS_TRUST_ME_PLUGIN_FILE")
  let g:DUBS_TRUST_ME_PLUGIN_FILE = ".trustme.vim"
endif

if ! exists("g:DUBS_TRUST_ME_PLUGIN_DIR")
  let g:DUBS_TRUST_ME_PLUGIN_DIR = ".trustme"
endif

autocmd BufEnter * call s:SeekForSecurityHolePluginFileToLoad(0, 'BufEnter')
autocmd BufWritePost * call s:SeekForSecurityHolePluginFileToLoad(1, 'BufWritePost')

" Search updards for a specially named file to be sourced at runtime,
" whenever the buffer of a file in a directory thereunder is opened.
function! s:SeekForSecurityHolePluginFileToLoad(on_save, because) abort
  " Avoid looking for trustme.vim plugin for unsaved (new) buffers,
  " e.g., those without a path; and for other special buffer types.
  " - E.g., vim-fugitive paths look like:
  "   fugitive:///repo/path/.git//SHA1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/some/file
  if (expand('%:p') == '') || !empty(matchstr(expand('%:p'), '^fugitive://.*'))
    return
  endif

  " Likewise skip unlisted buffers, Quickfix buffer, and preview window buffer. 

  let l:bufnr = bufnr("%")

  if !buflisted(l:bufnr) || &ft == 'qf' || &previewwindow
    return
  endif

  " ***

  " NOTE: If using the project.vim plugin, if you double click files from
  "   there, for some reason this function (when called from BufEnter)
  "   runs in the context of the project window. I.e., the path is to
  "   .vimprojects. I'm not sure why; and I spent too much time trying to
  "   make it work that I finally don't care anymore.

  " echomsg 'Trust-Me running on ' .. expand('%') .. ' / because: ' .. a:because

  " ***

  " Prefer a .trustme/ directory on path.
  let l:start_dir = s:SeekForSecurityHolePlugin_SeekupForTrustmeDotDir()

  " If no .trustme/ directory found, start from current directory.
  if (l:start_dir == '')
    let l:start_dir = '.'
  endif

  " Look up for the .trustme.vim plugin to load.
  let l:project_plugin_f = s:SeekForSecurityHolePlugin_SeekUpForTrustmeDotVim(l:start_dir)

  if (l:project_plugin_f != '')
    let l:plugin_path = fnamemodify(expand(l:project_plugin_f), ':p')

    if (filereadable(l:plugin_path))
      let l:cwd = getcwd()

      " echomsg 'cwd: ' .. l:cwd

      exec 'cd ' .. fnamemodify(expand(l:project_plugin_f), ':h')
      let g:DUBS_TRUST_ME_ON_FILE = expand('%:t')
      let g:DUBS_TRUST_ME_ON_SAVE = a:on_save
      exec 'source ' .. l:plugin_path
      exec 'cd ' .. l:cwd
    else
      " Unexpected branch.
      echomsg 'ERROR: Unexpected: .trustme.vim not readable: ' .. l:plugin_path
    endif
  endif
endfunction

" Look for a '.trustme/' dir., walking from the current directory (same
" as expand('%:h')) to the root directory. Note the path syntax: a sole
" '.' searches just the current dir., or child (downward) directories if
" you add ** globs; but if the path ends with ';', findfile will 'search
" upward till the root directory' (per :h file-searching). So '.;' searches
" up from the current directory. Note, too, the semi-colon can be followed
" by a list of stop-directories, which behave as one might expect.
function! s:SeekForSecurityHolePlugin_SeekupForTrustmeDotDir() abort
  let l:trustme_dir = finddir(g:DUBS_TRUST_ME_PLUGIN_DIR, '.;')

  " echomsg 'Find-up for dir ‘' .. g:DUBS_TRUST_ME_PLUGIN_DIR .. '’ / found: ' .. l:trustme_dir

  return l:trustme_dir
endfunction

function! s:SeekForSecurityHolePlugin_SeekUpForTrustmeDotVim(start_dir) abort
  let l:trustme_vim = findfile(g:DUBS_TRUST_ME_PLUGIN_FILE, a:start_dir .. ';')

  " echomsg 'Find-up for plug from: ' .. a:start_dir .. ' / found: ' .. l:trustme_vim

  return l:trustme_vim
endfunction

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" 2017-12-01: Show the :highlight of the word under the cursor.
" -------------------------------------------------------------------------

" 2017-12-01: This is awesome! "vim identify highlight of word under cursor"
"   http://vim.wikia.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
" See also :help synstack()
map <F10> :echo "hi<"
  \ . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" -------------------------------------------------------------------

" 2017-12-10 01:07: Would a highlight-word-under-cursor help me find search results?
" http://vim.wikia.com/wiki/Highlight_current_word_to_find_cursor
"nnoremap <C-i> :call HighlightNearCursor()<CR>
"inoremap <C-i> <C-o>:call HighlightNearCursor()<CR>
" 2017-12-10 14:09: I really don't know if I'll use this, and burning
"   a limited-edition Command-key sequence makes me uneasy; but I can
"   always steal this back later.
" FIXME/MAYBE: If you scroll, the highlight moves to other words...
"   this function really is very crude.
" This screws <TAB>:
"   inoremap <C-I> <C-O>:call HighlightNearCursor()<CR>
" HSTRY/2024-12-03 02:52: I've never used this, and, as I commented
" in 2017, it's crude and works weirdly. E.g., if you <F1> to start
" a search on some word, those words are highlighted; but then you
" can <C-B> another word, and that word (but not others like it)
" will *also* be highlighted. And it's unaffected by :nohlsearch,
" which clears the search highlight. And if you page-up/page-down,
" the highlight jumps to some other word, or if you move the cursor
" <Left> or <Right> repeatedly, the highlight also moves around.
" Then if you leave/re-enter the buffer, the highlight disappears,
" but not the toggle state, so then you need two <C-B> presses to
" start it back up.
" - But more importantly, coc.nvim defaults to (or at least its README
"   congiguration suggests) using <C-b> to scroll the floating window.
"   - Not that we couldn't use a different scroll mapping for coc.nvim,
"     but that alerted me to this stale feature that we might as well nix.
"     - Though I do sorta like the realtime `match` usage, kinda nifty.
"     - ALTLY: Change <C-B> → <S-C-B>, long live HighlightNearCursor!
"       - Well, not <S-C-B>, MacVim doesn't honor <Shift-Ctrl>, so
"         how about <S-M-B>.
"       - We'll keep this alive as a zombie feature that you'll forget
"         about, but when you rediscover this comment, at least you can
"         demo the feature without needing to change anything.
inoremap <S-M-B> <C-O>:call <SID>HighlightNearCursor()<CR>
function! s:highlight_cursor_match_id() abort
  if !exists("w:highlight_cursor_match_id")
    let l:priority = 100
    let w:highlight_cursor_match_id = matchadd('Todo', '\k*\%#\k*', l:priority)
  else
    silent! call matchdelete(w:highlight_cursor_match_id)
    unlet w:highlight_cursor_match_id
  endif
endfunction

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" 2018-02-20: Remove word under cursor. Sorta like Bash's Alt-d.
" -------------------------------------------------------------------------

" https://stackoverflow.com/questions/833838/delete-word-after-or-around-cursor-in-vim
" See:
"  :help diw
if has('macunix')
  nnoremap ∂ diw
  inoremap ∂ <C-o>diw
else
  nnoremap <M-d> diw
  inoremap <M-d> <C-o>diw
endif

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" 2020-02-05: Change cursor shape in different modes.
" -------------------------------------------------------------------------

" Thank you!!
" https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes

" 'Set IBeam shape in insert mode, underline shape in replace mode
"  and block shape in normal mode.'
"  https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes
" From 'VTE-compatible terminals' ('includes mate-terminal 1.18.1').
" 2020-02-05: (lb): I'm running 'MATE Terminal 1.20.0'.
" - Works close to perfect, except on escape to vim insert mode, the
"   I-beam cursor appears to go backward one character, but what really
"   happens is the cursor changes back to block but does not get updated
"   until you now type a movement command.
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" -------------------------------------------------------------------

" -------------------------------------------------------------------------
" 2024-12-12: Helpful joiner
" -------------------------------------------------------------------------

" As inspired by tpope/vim-sensible:
" 'Delete comment character when joining commented lines.'
" - USAGE: Works with the `J` command.
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j
endif

" -------------------------------------------------------------------------
" -------------------------------------------------------------------------

