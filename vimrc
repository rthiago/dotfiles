set background=dark
set hlsearch
set ignorecase
set guifont=Hack\ Regular\ 14
set mouse=a
set noswapfile
set number
set t_Co=256
set title
set updatetime=100
set vb
set clipboard=unnamedplus
set relativenumber
set showcmd

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 1
let g:airline_theme = 'powerlineish'
"let g:CSApprox_loaded = 1
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_map = '<c-p>'

syntax on

nnoremap <F2> :NERDTreeToggle<CR>
"nnoremap <S-Tab> :bp<CR>
"nnoremap <Tab> :bn<CR>

" Vim plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'kien/ctrlp.vim'
Plug 'morhetz/gruvbox'
Plug 'Raimondi/delimitMate'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/CSApprox'
Plug 'Yggdroot/indentLine'

call plug#end()

colorscheme gruvbox

if exists('&signcolumn')  " Vim 7.4.2201
    set signcolumn=yes
else
    let g:gitgutter_sign_column_always = 1
endif
