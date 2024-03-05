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
  let c0 = col(".")
  normal! i
  let c1 = col(".")
  " KLUGE/2024-03-05: Nudge cursor one right for specific cases:
  " - compensate for i<ESC> moving the cursor left:
  "   - when you copy-paste selection that's not EOL, c1 == c0 - 1
  "       (c1 < c0)
  "   - when you copy-paste selection that goes to EOL, c1 == c0
  "       (c1 <= c0)
  "   - check that col not 1 before and after (means newline is final char
  "     in selection, e.g., user selected line of text; don't move cursor
  "     right, but keep at ^ position)
  "       (c0 != 1) || (c1 != 1)
  if (c1 <= c0) && ((c0 != 1) || (c1 != 1))
    normal! l
  endif
  let &ve = ove
endfunc
