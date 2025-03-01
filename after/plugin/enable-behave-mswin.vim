" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_dubs_edit_juice_enable_behave_mswin
endif

if exists('g:loaded_dubs_edit_juice_enable_behave_mswin') || &cp

  finish
endif

let g:loaded_dubs_edit_juice_enable_behave_mswin = 1

" -------------------------------------------------------------------

" CXREF: Some places you might find mswin.vim:
"
"   /usr/share/vim/vim*/mswin.vim
"
"   /Applications/MacVim.app/Contents/Resources/vim/runtime/mswin.vim
"
"   ~/.local/share/vim/vim*/mswin.vim
"
" - Also in Neovim, e.g.,
"
"   /opt/homebrew/Cellar/neovim/0.10.4/share/nvim/runtime/mswin.vim
"
"   - Aka:
"
"     /opt/homebrew/var/homebrew/linked/neovim/share/nvim/runtime/mswin.vim
"     /opt/homebrew/share/nvim/runtime/mswin.vim
"     /opt/homebrew/opt/nvim/share/nvim/runtime/mswin.vim
"     /opt/homebrew/opt/neovim/share/nvim/runtime/mswin.vim
"
"   - More lately under scripts, e.g.,:
"
"     /opt/homebrew/Cellar/neovim/HEAD-228fe50_1/share/nvim/runtime/scripts/mswin.vim

" -------------------------------------------------------------------

" ------------------------------------------------------
" So-called MS Windows mode
" ------------------------------------------------------

" 2017-04-03: Moved to after-juice from normal plugin/dubs_edit_juice
"   so that mswin.vim's Ctrl-x doesn't just dump "+x to the editor,  "
"   and so that mswin.vim's Ctrl-h doesn't replace our hide highlights map.

" See what OS we're on
let s:running_windows = has("win16") || has("win32") || has("win64")

if s:running_windows

  finish
endif

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

function! s:EnableMswinDotVim() abort
  " Restore <C-F> and <C-H> if user (another plugin) customized them.
  " - mswin.vim changes Vim's builtin <C-F> (PageDown) to opening Find dialog.
  "   - CoC overrides <C-F> to work with its floating window.
  " - mswin.vim changes Vim's builtin <C-H> (<Left>) to opening replace dialog.
  "   - Author's vim-blinky-search plugin changes <C-H> to :nohlsearch.
  " - Note that mswin.vim always sets <C-s>, but it skips <C-f> and <C-h>
  "   unless has('gui'). So unless other plugins have loaded and set these,
  "   the latter two bindings might not be set yet.
  let l:abbrev = 0
  let l:retdict = 1
  let l:old_n_ctrl_f = maparg('<C-f>', 'n', l:abbrev, l:retdict)
  let l:old_i_ctrl_f = maparg('<C-f>', 'i', l:abbrev, l:retdict)
  let l:old_n_ctrl_h = maparg('<C-h>', 'n', l:abbrev, l:retdict)
  let l:old_i_ctrl_h = maparg('<C-h>', 'i', l:abbrev, l:retdict)
  let l:old_n_ctrl_s = maparg('<C-s>', 'n', l:abbrev, l:retdict)
  let l:old_i_ctrl_s = maparg('<C-s>', 'i', l:abbrev, l:retdict)
  let l:old_v_ctrl_s = maparg('<C-s>', 'v', l:abbrev, l:retdict)

  " Map <Ctrl-V>, <Ctrl-X>, and <Ctrl-C> keys, and insert mode <Ctrl-Z>, etc.
  if has('nvim')
    " Neovim v0.10.4
    let l:mswin = $VIMRUNTIME .. "/mswin.vim"

    if ! filereadable(mswin)
      " Neovim v0.11.0-dev-{sha}-Homebrew
      let l:mswin = $VIMRUNTIME .. "/scripts/mswin.vim"
    endif

    if ! filereadable(mswin)
      echom "ERROR: Failed to find mswin.vim"

      return
    endif

    " See also :runtime, though fails silently:
    "   runtime mswin.vim
    exec "source " .. l:mswin
  else
    behave mswin
  endif

  " Unmask mvwin.vim maps.
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
  " NOTE: Ctrl-F and Ctrl-B do not PageDown/PageUp from Insert mode,
  "       but rather enter their respective characters into the buffer.
  "       - Though CoC wires i_CRTL-F to navigating its float window,
  "         or to <Right>.
  call s:RestoreMap(l:old_n_ctrl_f)
  call s:RestoreMap(l:old_i_ctrl_f)
  call s:RestoreMap(l:old_n_ctrl_h)
  call s:RestoreMap(l:old_i_ctrl_h)
  call s:RestoreMap(l:old_n_ctrl_s)
  call s:RestoreMap(l:old_i_ctrl_s)
  call s:RestoreMap(l:old_v_ctrl_s)

  " Unsure why mswin.vim doesn't also map the reverse...
  " - Oh, maybe because it's a <Shift-Ctrl> binding.
  "   - Though still works without any "magic".
  "
  " CTRL-Tab is Previous window
  " - REFER: :h CTRL-W_W
  nnoremap <C-S-Tab> <C-W>W
  inoremap <C-S-Tab> <C-O><C-W>W

  " Note the x, d, c, and s commands copy to the unnamed register,
  " and if you set clipboard=unnamedplus, they also copy to the
  " system clipboard. Which makes mswin.vim's `vnoremap <BS> d`
  " behave like cut, not delete. Here we make it like delete.
  vnoremap <BS> "_d

  " DUNNO/2025-02-23: mswin.vim maps <S-Del> same as <C-x>:
  "   vnoremap <S-Del> "+x
  " but for me, <S-Del> inserts a literal "<S-Del>".
endfunction

" ***

" REFER: maparg w/ Dict includes, e.g.:
"   {'lhs': '<C-F>', 'mode': 'n', 'expr': 1, 'sid': 0, 'lnum': 0, 'noremap': 1, 'nowait': 1,
"    'rhs': 'coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"', 'lhsraw': '<80><fc>^DF',
"    'abbr': 0, 'lhsrawalt': '^F', 'script': 0, 'mode_bits': 1, 'silent': 1, 'buffer': 0,
"    'scriptversion': 0}
function! s:RestoreMap(old_map) abort
  if empty(a:old_map)

    return
  endif

  " DUNNO/2025-02-23: After editing the startup scripts, if I next run
  " nvim via tig to, e.g., craft a commit message, lazy downloads the
  " new plugins, but then there's an error here:
  "   <SNR>156_EnableMswinDotVim[59]..<SNR>156_RestoreMap, line 6:
  "     Vim(let):E716: Key not present in Dictionary: "rhs"
  " Which is weird, because either a:old_map should be {} and we
  " returned, or it's not empty, it should be the return from
  " maparg which should include rhs.
  if !exists('a:old_map.rhs')
    echom 'ERROR: a:old_map.rhs missing?! ' .. string(a:old_map)
  endif

  let l:remap =
    \ a:old_map.mode .. (a:old_map.noremap ? 'noremap ' : 'map ')
    \ .. (a:old_map.buffer ? '<buffer> ' : '')
    \ .. (a:old_map.expr ? '<expr> ' : '')
    \ .. (a:old_map.nowait ? '<nowait> ' : '')
    \ .. (v:version < 900 ? '' : (a:old_map.script ? '<script> ' : ''))
    \ .. (a:old_map.silent ? '<silent> ' : '')
    \ .. a:old_map.lhs .. ' ' .. a:old_map.rhs

  exec l:remap
endfunction

" ***

call s:EnableMswinDotVim()

