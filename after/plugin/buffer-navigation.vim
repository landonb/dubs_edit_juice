" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

" -------------------------------------------------------------------

" CXREF:
" ~/.kit/git/tig-newtons/bin/editor-vim-0-0-insert-minimal.vimrc
if $VIM_EDIT_JUICE_EXIT_ON_SAVE != ''

  finish
endif

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Switching Buffers/Windows/Tabs
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Ctrl-Alt-Tab / Shift-Ctrl-Alt-Tab
" ------------------------
" → Next / Previous Buffer
"
" - mswin.vim maps <Ctrl-Tab> to Next Window.
"   - And our `behave mswin` script maps <Shift-Ctrl-Tab> to Prev Window.
" - Dubs maps <M-S-Up> / <M-S-Down> to Next Window / Prev Window.
" - Dubs maps <Ctrl-Tab> / <C-S-Tab> to Next Buffer / Prev Buffer,
"   sorted by buffer number.
"   - CXREF: See also vim-buffer-ring, which maps <C-j> / <C-k> to
"     Prev Buffer / Next Buffer, sorted by recently viewed order:
"       https://github.com/landonb/vim-buffer-ring#💍

" Ctrl-Alt-Tab: Next Buffer
" - Note that `behave mswin` sets <C-Tab>,
"   so keep this code under after/.
" - A simple approach:
"   noremap <C-M-Tab> :bn<CR>
"   inoremap <C-M-Tab> <C-O>:bn<CR>
noremap <C-M-Tab> :call <SID>BufNext_SkipSpecialBufs(1)<CR>
inoremap <C-M-Tab> <C-O>:call <SID>BufNext_SkipSpecialBufs(1)<CR>

" Shift-Ctrl-Alt-Tab: Previous Buffer
" - A simple approach:
"   noremap <C-S-M-Tab> :bN<CR>
"   inoremap <C-S-M-Tab> <C-O>:bN<CR>
noremap <C-S-M-Tab> :call <SID>BufNext_SkipSpecialBufs(-1)<CR>
inoremap <C-S-M-Tab> <C-O>:call <SID>BufNext_SkipSpecialBufs(-1)<CR>

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
    " echom 'n = ' .. n .. ' / start_bufnr = ' .. start_bufnr
    "   \ .. ' / buftype = ' .. getbufvar(n, '&buftype')
    " if (getbufvar(n, '&buftype') == '')
    "   echo '- buffer has no buftype'
    " endif
    if (start_bufnr == n)
        \ || (getbufvar(n, "&modified") == 1)
        \ || ( (getbufvar(n, "&buftype") == "")
        \   && ((getbufvar(n, "&filetype") != "")
        \     || (getbufvar(n, "&fileencoding") != "")) )
      " (start_bufnr == n) means just 1 buffer or no candidates found
      " (buftype == "") means not quickfix, help, etc., buffer
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
nnoremap <silent> <C-j> :if exists('*BufferRingReverse') \|
  \ exec 'BufferRingReverse' \| else \| exec ':bprev' \| endif<CR>
inoremap <silent> <C-j> <C-O>:if exists('*BufferRingReverse') \|
  \ exec 'BufferRingReverse' \| else \| exec ':bprev' \| endif<CR>
" Enable these if you want <C-j> to work from command mode
" or operator-pending mode. Which seems silly, IMO.
"   cnoremap <C-j> <C-C>:BufferRingReverse<CR>
"   onoremap <C-j> <C-C>:BufferRingReverse<CR>

" 2017-06-06: Remap <C-k>, so digraph insertion works from <C-l>,
"   and then I can continue using <C-j> and <C-k> for burfing surfing
"   (Ctrl-Tab and Ctrl-Shift-Tab also work, but my brain is really
"   wired to using C-j and C-k, so I prefer to keep those mappings.)
inoremap <C-l> <C-k>

" 2017-06-10: Vim's Ctrl-K maps to a :digraph feature, and we cannot remap
"  otherwise access the feature except through Ctrl-K...
nnoremap <silent> <C-k> :if exists('*BufferRingForward') \|
  \ exec 'BufferRingForward' \| else \| exec ':bnext' \| endif<CR>
inoremap <silent> <C-k> <C-O>:if exists('*BufferRingForward') \|
  \ exec 'BufferRingForward' \| else \| exec ':bnext' \| endif<CR>

" Enable these if you want <C-k> to work from command mode
" or operator-pending mode. Which seems silly, IMO.
"   cnoremap <C-k> <C-C>:BufferRingForward<CR>
"   onoremap <C-k> <C-C>:BufferRingForward<CR>

