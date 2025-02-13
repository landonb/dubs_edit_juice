" vim:tw=0:ts=2:sw=2:et:norl:
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3

" -------------------------------------------------------------------

" GUARD: Press <F9> to reload this plugin (or :source it).
" - Via: https://github.com/embrace-vim/vim-source-reloader#↩️

if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_dubs_edit_juice_plugin_inject_date_and_time
endif

if exists('g:loaded_dubs_edit_juice_plugin_inject_date_and_time') || &cp

  finish
endif

let g:loaded_dubs_edit_juice_plugin_inject_date_and_time = 1

" -------------------------------------------------------------------

" *** Insert today's date using iabbrev and map

" Note that completing an iabbrev requires <CR>, space, or punctuation
" (or <C=]> expect dubs_edit_juice.vim assigns an imap to that, so it
" doesn't work).
"
" - So depending on the iabbrev, you might not want a carriage return,
"   punction, or a space after the inserted text.
"
" - But for some iabbrev, it works out okay!
"
"   - For instance, I use the `TTT` abbreviation to enter todays'
"     date, and I almost always follow that with a colon. Which
"     is perfect, because you can type `TTT:` and you'll end up
"     with, e.g.,
"
"       2024-12-11:{cursor}

" REFER: An old dog can learn new tricks,
"        - like the P in <CR>P
"        - and the <expr> in iabbrev <expr>.
"
" http://vim.wikia.com/wiki/Insert_current_date_or_time
"
" “The uppercase P at the end inserts before the current character,
"  which allows datestamps inserted at the beginning of an existing line.”
"
"   " :nnoremap <F5> "=strftime("%Y-%m-%d")<CR>P
"   :inoremap <F5> <C-R>=strftime("%Y-%m-%d")<CR>
"
" REFER: Re: <expr>, see:
" http://vimdoc.sourceforge.net/htmldoc/map.html#:map-expression

" -------------------------------------------------------------------

" YYYY-MM-DD
iabbrev <expr> TTT strftime("%Y-%m-%d")

" YYYY_MM_DD
iabbrev <expr> TTT_ strftime("%Y_%m_%d")

" YYYY-MM-DD HH:MM
iabbrev <expr> TTTtt strftime("%Y-%m-%d %H:%M")
iabbrev <expr> ::: strftime("%Y-%m-%d %H:%M:")

" YYYY-MM-DDTHH:MM
iabbrev <expr> TTTTtt strftime("%Y-%m-%dT%H:%M")

" HH:MM
iabbrev <expr> ttt strftime("%H:%M")

" TRYME/2025-02-07: Trying a quicker abbreviation, under the assumption
" that you'd never type comma *not* followed by a space in text or code.
" - BEGET: https://www.reddit.com/r/neovim/comments/16mijcz/comment/k18jbee/
"   https://www.reddit.com/r/neovim/comments/16mijcz/anyone_here_use_iabbrev/
"   - FOREX:
"       vim.cmd("iabbrev <expr> ,d strftime('%Y-%m-%d')")
"       vim.cmd("iabbrev <expr> ,t strftime('%Y-%m-%dT%TZ')")
iabbrev <expr> ,t strftime("%Y-%m-%d")
iabbrev <expr> ,T strftime("%Y-%m-%d %H:%M")

" -------------------------------------------------------------------

" /YYYY-MM-DD HH:MM:
"
" TRYME/2023-06-03: For adding datetime after a FIVER.
"
" - Type `FIVER\T` and you get `FIVER/TTT: `
"
" - Type `FIVER<F12>` and you get `FIVER/TTTtt: `
"
" - The author had been typing 'FIXME/TTT:` and 'FIXME/TTTtt:'
"   often enough that I wanted something quicker.
"
" - I tried using the abbreviation, '::', but the '/' after the FIVER is
"   not a keyword character, and neither is ':', so an iabbrev doesn't work.
inoremap <silent> <Leader>t <C-R>=strftime("/%Y-%m-%d: ")<CR>
inoremap <silent> <F12> <C-R>=strftime("/%Y-%m-%d %H:%M: ")<CR>

