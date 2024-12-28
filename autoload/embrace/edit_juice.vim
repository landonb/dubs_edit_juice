" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3

" -------------------------------------------------------------------

" ------------------------------------------------------
" Character Transposition
" ------------------------------------------------------

" NOTE We can't just 'Xp' and be all happy --
"      rather, if we're at the first column
"      (start) of the line, 'Xp' does something
"      completely different. So use 'Xp' if the
"      cursor is anywhere but the first column,
"      but use 'xp' otherwise.
function! g:embrace#edit_juice#TransposeCharacters() abort
  if !&modifiable
    echom "Cannot modify this buffer"

    return
  endif

  let l:cursorCol = col('.')

  if 1 == l:cursorCol
    execute 'normal ' . 'xp'
  else
    execute 'normal ' . 'Xp'
  endif
endfunction

