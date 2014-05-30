" Pathogen load
filetype off

call pathogen#infect()
call pathogen#helptags()

" Common editor settings
filetype plugin indent on
syntax on

set tabstop=4
set expandtab
set shiftwidth=4
set wrap

" Dumps a shell's output into a buffer
command! -complete=shellcmd -nargs=+ SB call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
    echo a:cmdline
    let expanded_cmdline = a:cmdline
    for part in split(a:cmdline, ' ')
        if part[0] =~ '\v[%#<]'
            let expanded_part = fnameescape(expand(part))
            let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
        endif
    endfor
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    call setline(1, 'You entered:    ' . a:cmdline)
    call setline(2, 'Expanded Form:  ' .expanded_cmdline)
    call setline(3,substitute(getline(2),'.','=','g'))
    execute '$read !'. expanded_cmdline
    setlocal nomodifiable
    1
endfunction

" Shorthands for entering insert/normal modes
inoremap <C-n> <Esc>
nnoremap <C-i> i

" Don't show extra help with NERDTree
let NERDTreeMinimalUI=1

" Insert Hadapt copyright quickly
inoremap <C-h>  <C-O>oCopyright 2014, Hadapt, Inc. All rights reserved.<C-O>o

" Quickly rebuild ctags
command -nargs=1 Ctags !ctags -R -f ctags.out --c++-kinds=+p --fields=+iaS --extra=+q $1
set tags+=ctags.out

" Updates the Cscope settings and resets the connection.
" NOTE: If you execute this using Vim's :silent keyword
"       you will need to use "redraw!" after as shells cause
"       blank screens in Vim (see http://objectmix.com/editors/149134-vim-execute-shell-command-silently.html)
command -nargs=0 CscopeRefresh execute '!cscope -Rqb' | cs reset

" Renamec plugin
nnoremap <Leader>r :call Renamec()<CR>

" Open and close folds from syntax folding
set foldmethod=syntax
set foldlevel=100000              " Set initial foldlevel so nothing folds
nnoremap <Esc><Left> :foldc<CR>
nnoremap <Esc><Right> :foldo<CR>
nnoremap <Esc><Up> :foldc!<CR>
nnoremap <Esc><Down> :foldo!<CR>

" Remap for toggling the location list
nnoremap <C-l> :lne<CR>
nnoremap <C-L> :lpr<CR>

" Remap for undo tree
nnoremap <C-u> :GundoToggle<CR>

" Remap for alternating header/body files
nnoremap <C-a> :A<CR>

" Check the current directory, not the .git dir in CTRL-p
" Also, for some reason CTRL-P goes full text search crazy when
" not in regex mode, so switch it to that.
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_regexp_search = 1

" MRU for files like in Intellij
nnoremap <C-e> :MRU<CR>

" Set up the debugger for GDB using Pyclewn and print shortcuts
" (which Pyclewn's internal aliases are too stupid to set up).
nnoremap <C-g> :Pyclewn<CR>
nnoremap <C-m> :Cmapkeys<CR>
nnoremap P :Cprint <c-r>=expand("<cword>")<cr><CR>
nnoremap X :Cprint *<c-r>=expand("<cword>")<cr><CR>

" Postgres in particular has 'pprint' for its query tree printing.
" However, this can crash a program if the wrong this is selected,
" so make the user manually hit enter after this shortcut to confirm
nnoremap T :Ccall pprint(<c-r>=expand("<cword>")<cr>)


" Use just <leader> instead of <leader><leader>, easymotion's
" default setting
let g:EasyMotion_leader_key = '<Leader>'

" Visual settings for tagbar
let g:tagbar_left=0
let g:tagbar_compact=1
noremap <Esc><C-i> :TagbarOpenAutoClose<CR>

" AIRLINE
  " Theme settings (requires 256 true-bit color and permanent status bar)
set t_Co=256
set laststatus=2
let g:airline_theme='thaddeus'
  " Unicode indicators
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = '▶'
let g:airline_left_alt_sep = '|'
let g:airline_right_sep = '◀'
let g:airline_right_alt_sep = '|'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.branch = '⎇ '
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = ''
  " airline vcs information
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#branch#empty_message = '[NO VERSION CONTROL]'
  " CTRL-p highlighting information
let g:airline#extensions#whitespace#checks = [ 'trailing' ]
  " Python virtualenv
let g:airline#extensions#virtualenv#enabled = 1
  " Enable top tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#fnamecollapse = 0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_min_count = 2
let g:airline#extensions#tabline#left_sep = '>>'
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = '<<'
let g:airline#extensions#tabline#right_alt_sep = ''
nnoremap <C-J> :tabprev<CR>
nnoremap <C-K> :tabnext<CR>

" Disable syntastic on python files so it doesn't interact with python-mode
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['python'] }

" Close Vim files if all that's left are NERDTrees and CScope buffers
function! AreUsefulWindowsLeft()
  for i in range(1, winnr("$"))
    if getbufvar(winbufnr(i), "NERDTreeType") != 'primary' && getbufvar(winbufnr(i), "IsCscopeBuffer") != 1
      return 1
    endif
  endfor
  " Reached the end of all windows, didn't find anything good
  return 0
endfunction

autocmd BufEnter * if (!AreUsefulWindowsLeft()) | ccl | q | endif
