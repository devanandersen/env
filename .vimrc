set nocompatible              " be iMproved, required
filetype off                  " required


" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'junegunn/fzf', { 'do': './install --bin' }
Plugin 'junegunn/fzf.vim' 
Plugin 'preservim/nerdtree'

call vundle#end()            " required filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Sets up :Find with ripgrep
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)


" Fix .tsx highlighting issue
syntax on
autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescript
set t_Co=256
set number
set clipboard=unnamed
set clipboard=unnamedplus
set autoindent
set incsearch                        " search as characters are entered
set hlsearch                         " highlights search text
set autoread                         " autoreload the file in Vim if it has been changed outside of Vim
set ruler                            " always show current position
set incsearch                        " set incremental search (as you type)
set tabstop=2
set shiftwidth=2
set expandtab
set tw=120
set fo+=t
set relativenumber

" Set the title of the Terminal to the currently open file
function! SetTerminalTitle()
    let titleString = expand('%:t')
    if len(titleString) > 0
        let &titlestring = expand('%:t')
        " this is the format iTerm2 expects when setting the window title
        let args = "\033];".&titlestring."\007"
        let cmd = 'silent !echo -e "'.args.'"'
        execute cmd
        redraw!
    endif
endfunction

autocmd BufEnter * call SetTerminalTitle()

" Nerd Tree autostart
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" disable arrow keys
" neovim remote
" map <up> <nop>
" map <down> <nop>
" map <left> <nop>
" map <right> <nop>
" imap <up> <nop>
" imap <down> <nop>
" imap <left> <nop>
" imap <right> <nop>
" map nerd tree to left arrow
map <up> :Rg
" map <up> :vs
" map <down> :term
map <down> :Files
:tnoremap <Esc> <C-\><C-n>
" Enable scroll wheel
:set mouse=a

" ff: find files
nnoremap ff :Files <CR>
" ft: find tags
nnoremap ft :Tags <CR>
" fT: find tags in current buffer
nnoremap fT :BTags <CR>
" fb: find buffers
nnoremap fb :Buffers <CR>
" fc: find changed files from git status
nnoremap fc :Rg <CR>
" fl: find in current buffer's lines
nnoremap fl :BLines <CR>
