set nocompatible
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
  set fileencodings=utf-8,latin1
endif

" vundle ---------------------------------------------------
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'othree/eregex.vim'
Plugin 'dag/vim-fish'
Plugin 'scrooloose/nerdtree'
Plugin 'saltstack/salt-vim'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-fugitive'
Plugin 'gisraptor/vim-lilypond-integrator'
Plugin 'dracula/vim'
Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'PProvost/vim-ps1'

call vundle#end()
filetype plugin indent on
" ----------------------------------------------------------

" gvim -----------------------------------------------------
if &t_Co > 2 || has("gui_running")
  syntax on
  silent! colorscheme dracula
  set hlsearch
endif
if has("gui_running")
  set lines=42
  set columns=112
  set guioptions-=l
  set guioptions-=r
  set guioptions-=L
  set guioptions-=R
  set guioptions-=T
  set guioptions-=m
endif
if &term=="xterm"
  set t_Co=8
  set t_Sb=^[4%dm
  set t_Sf=^[3%dm
endif
if has("autocmd")
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal g'\"" |
  \ endif
  autocmd GuiEnter * set vb t_vb=
endif
" ----------------------------------------------------------

" tab complete ---------------------------------------------
function! InsertTabWrapper(direction)
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  elseif "backward" == a:direction
    return "\<c-p>"
  else
    return "\<c-n>"
  endif
endfunction

inoremap <silent> <TAB>   <C-R>=InsertTabWrapper ("backward")<CR>
inoremap <silent> <S-TAB> <C-R>=InsertTabWrapper ("forward")<CR>
" ----------------------------------------------------------

" maps -----------------------------------------------------
map <F4> :set spell!<CR>
map <F6> :NERDTreeToggle<CR>
map <F7> :TagbarToggle<CR>
map <F9> :nohl<CR>
imap <F9> <C-O><F9>
map ,b :Gblame<CR>
" windows
map <A-h> :wincmd h<CR>
map <A-j> :wincmd j<CR>
map <A-k> :wincmd k<CR>
map <A-l> :wincmd l<CR>
" tabs
map ,t <ESC>:tabnew<CR>
map ,T <ESC>:tabnew<CR><F6><F7><C-w>w<C-p>
map ,c <ESC>:tabclose<CR>
nnoremap <A-S-F1> 1gt
nnoremap <S-h> gT
nnoremap <S-l> gt
" lines
inoremap <C-h> <C-o>h
inoremap <C-j> <C-o>j
inoremap <C-k> <C-o>k
inoremap <C-l> <C-o>l
"  vimrc editing
map ,v <ESC>:tabnew<CR>:e ~/.vimrc<CR>
map <silent> ,V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
" ----------------------------------------------------------

" settings -------------------------------------------------
function! GetCanonicalWorkingDirectory()
    return fnamemodify(getcwd(), ':p:~')
endfunction

set t_vb=
set visualbell
set t_vb=

set autoindent
set backspace=2
set cmdheight=2
set comments="s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-,;,!"
set copyindent
set expandtab
set foldmethod=indent
set foldignore=
set guifont=Monospace\ 10
set hlsearch
set history=1024
set incsearch
set infercase
set linebreak
set mouse=a
set mousehide
set wrap
set pastetoggle=<F8>
set ruler
set scrolloff=5
set shiftround
set shiftwidth=4
set showcmd
set showmatch
set sidescroll=1
set sidescrolloff=10
set smartcase
set smartindent
set smarttab
set spelllang=en_us
set softtabstop=8

" https://unix.stackexchange.com/a/243667
set statusline=
set statusline+=%{fugitive#statusline()}
set statusline+=\ %f\ %h%w%m%r
"set statusline+=\ %#warningmsg#%{SyntasticStatuslineFlag()}%*
set statusline+=%=%(%l,%c%V\ \ %=\ \ %P%)

set tabstop=8
set titlestring=%{GetCanonicalWorkingDirectory()}
set viminfo='20,\"1024
" ----------------------------------------------------------

" local config ---------------------------------------------
try
  silent! source ~/.vim/vimrc.local
catch
endtry
" ----------------------------------------------------------
