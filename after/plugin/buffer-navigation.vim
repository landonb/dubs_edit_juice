" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/landonb/dubs_edit_juice#🧃
" License: GPLv3
" Copyright © 2015, 2017-2018, 2024 Landon Bouma.

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

