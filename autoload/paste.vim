" Vim support file to help with paste mappings and menus
" Maintainer:	The Vim Project <https://github.com/vim/vim>
" Last Change:	2023 Aug 10
" Former Maintainer:	Bram Moolenaar <Bram@vim.org>

" KLUGE/2024-03-05: See KLUGE comment, below, and commit notes.
" USYNC: Check the Vim source file occasionally.
" - CXREF: ~/.local/share/vim/vim91/autoload/paste.vim
"   - DXY: ~/.kit/clang/vim/runtime/autoload/paste.vim
" REFER: See also the <C-c> Copy and <C-v> Paste mappings:
" - CXREF: ~/.local/share/vim/vim91/mswin.vim
"   - DXY: ~/.kit/clang/vim/runtime/mswin.vim

" Define the string to use for items that are present both in Edit, Popup and
" Toolbar menu.  Also used in mswin.vim and macmap.vim.

let paste#paste_cmd = {'n': ":call paste#Paste()<CR>"}
let paste#paste_cmd['v'] = '"-c<Esc>' . paste#paste_cmd['n']
let paste#paste_cmd['i'] = "\<c-\>\<c-o>\"+gP"

func! paste#Paste()
  let ove = &ve
  set ve=all
  normal! `^
  if @+ != ''
    normal! "+gP
  endif
  let c = col(".")
  normal! i
  " KLUGE/2024-03-05: Use <= not <, so cursor at EOL after pasting to EOL selection.
  if col(".") <= c	" compensate for i<ESC> moving the cursor left
    normal! l
  endif
  let &ve = ove
endfunc
