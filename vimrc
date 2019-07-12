set background=dark
set hlsearch
set ignorecase
set guifont=Hack\ Regular\ 13
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
set scrolloff=20
set tabstop=4 shiftwidth=4 expandtab
set hidden

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" Persistent undo
set undofile
set undodir=$HOME/.vim/undo
set undolevels=1000
set undoreload=10000

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 1
let g:airline_theme = 'violet'
let g:airline#extensions#obsession#enabled = 1
let g:airline#extensions#obsession#indicator_text = '[Tracking session]'
let g:CSApprox_loaded = 1
let g:EasyMotion_smartcase = 1

syntax on

let g:mapleader = ','

nnoremap <F2> :Explore<CR>
nnoremap <C-J> :bn<CR>
nnoremap <C-K> :bp<CR>
nnoremap <C-P> :FZF<CR>
nnoremap <BS> <C-^>
inoremap ;; <C-o>A;<ESC>
inoremap :; <C-o>A;exit;<ESC>
noremap H ^
noremap L g_
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>r :Rg<CR>
nnoremap <Leader>w :bd<CR>
nnoremap <Leader>e :edit $MYVIMRC<CR>
nnoremap <Leader>s :source $MYVIMRC<CR>
nnoremap <Leader>i :History<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gl :Commits<CR>
nnoremap <Leader>gbl :BCommits<CR>
nnoremap <Leader>gc :Gcommit<CR>
nmap s <Plug>(easymotion-overwin-f)
nmap S <Plug>(easymotion-overwin-f2)

" Vim plug
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'Raimondi/delimitMate'
Plug 'ryanoasis/vim-devicons'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/CSApprox'
Plug '/usr/sbin/fzf'
Plug 'junegunn/fzf.vim'
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'hecal3/vim-leader-guide'
Plug 'easymotion/vim-easymotion'

call plug#end()

call leaderGuide#register_prefix_descriptions(",", "g:lmap")
nnoremap <silent> <leader> :<c-u>LeaderGuide ','<CR>
vnoremap <silent> <leader> :<c-u>LeaderGuideVisual ','<CR>

" Leader guide menus
let g:lmap =  {}
let g:lmap.g = { 'name' : 'Git' }
let g:lmap.h = { 'name' : 'GitGutter' }

colorscheme challenger_deep

if has('termguicolors')
    set termguicolors
endif

if exists('&signcolumn')  " Vim 7.4.2201
    set signcolumn=yes
else
    let g:gitgutter_sign_column_always = 1
endif

" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

" When switching buffers, preserve window view.
if v:version >= 700
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
endif

autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | silent! checktime | GitGutterAll | endif
autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed externally." | echohl None
autocmd BufWritePost * GitGutterAll
