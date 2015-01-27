" File: after/dubs_edit_juice.vim
" Author: Landon Bouma (dubsacks &#x40; retrosoft &#x2E; com)
" Last Modified: 2015.01.24
" Project Page: https://github.com/landonb/dubs_edit_juice
" Summary: EditPlus-inspired editing mappings
" License: GPLv3
" -------------------------------------------------------------------
" Copyright © 2015 Landon Bouma.
" 
" This file is part of Dubsacks.
" 
" Dubsacks is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
" 
" Dubsacks is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
" 
" You should have received a copy of the GNU General Public License
" along with Dubsacks. If not, see <http://www.gnu.org/licenses/>
" or write Free Software Foundation, Inc., 51 Franklin Street,
"                     Fifth Floor, Boston, MA 02110-1301, USA.
" ===================================================================

" ------------------------------------------
" About:

if exists("g:after_edit_juice_vim") || &cp
  finish
endif
let g:after_edit_juice_vim = 1

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

" We need to call an AutoAdapt function, which would normally work
" since the AutoAdapt script loads from an autoload plugin. But
" since we're using Pathogen, we have to use an after script
" to wait for it to be loaded, since bundles are loaded whenever
" and Pathogen only defers the after scripts.
"
" Note: We do, however, have to set a few other globals *before*
"       AutoAdapt loads; search: g:AutoAdapt_FirstLines/_LastLines.

" HINT: Toggle with :NoAutoAdapt and then :Adapt

" See: ~/.vim/bundle/AutoAdapt/plugin/AutoAdapt.vim

" The plugin defaults to checking the top 25 and bottom 10 lines.
" [lb] is skipping the end of the file, though, since I never put
" my infos in the footer (and I'd rather not worry about something
" accidentally changing down there), and I'm halving the top count.

let g:AutoAdapt_FirstLines = 13
let g:AutoAdapt_LastLines = 0

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

  " The copyright starts must start the line or follow one or more comment
  " characters or spaces. The match is case-insensitive and you can use
  " the actuak © mark, if you want, or (c).
  let s:aa_patt_copyright = '\c\_^\%("\|#\|\/\*\|\/\/\|\.\.\)\?\s*\<Copyright:\?\%(\s\+\%((C)\|&copy;\|\%xa9\)\)\{0,2\}\s\+'

  " LastChangedModified must also start a line or follow opening comment.
  let s:aa_patt_last_modd = '\v\C\_^%("|#|\/\*|\/\/|\.\.)?\s*%(<%(Last)?\s*%([cC]hanged?|[mM]odified)\s*:?\s+)\zs'

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
  \]

else

  echomsg "Missing: AutoAdapt#DateTimeFormat#ShortTimezone"

endif

