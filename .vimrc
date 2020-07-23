set nocompatible
set backspace=2

""" Search Setting
set ignorecase
set smartcase
set wrapscan

""" Display Settings
set number
set title
set showmatch
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smartindent 
set cursorline
set laststatus=2

""" Color Settings
syntax on
"let g:hybrid_use_iTerm_colors = 1
colorscheme hybrid


""" Pulugin Setting
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/ohyama/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/ohyama/.cache/dein')
  call dein#begin('/Users/ohyama/.cache/dein')

  " Let dein manage dein
  " Required:
  call dein#add('/Users/ohyama/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here like this:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')

  call dein#add('itchyny/lightline.vim')
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('vim-scripts/surround.vim')
  call dein#add('tyru/open-browser.vim')

	call dein#add('editorconfig/editorconfig-vim')
	call dein#add('scrooloose/syntastic')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

if &compatible
  set nocompatible
endif
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim


""" Plugin Settings / vim-anzu
nmap n <Plug>(anzu-n)
nmap N <Plug>(anzu-N)
nmap * <Plug>(anzu-star)
nmap # <Plug>(anzu-sharp)
augroup vim-anzu
  autocmd!
		autocmd CursorHold,CursorHoldI,WinLeave,TabLeave * call anzu#clear_search_status()
augroup END


""" Plugin Settings / lightline with vim-anzu
let g:lightline = {
		\ 'active': {
		\   'left': [ ['mode', 'paste'], ['readonly', 'filename', 'modified', 'anzu'] ]
		\ },
		\ 'component_function': {
		\	'anzu': 'anzu#search_status'
		\ }
		\ }


""" Plugin Settings / open-browser.vim
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)


""" Plugin Settings / emmet-vim
let g:user_emmet_leader_key = '<c-e>'
let g:user_emmet_settings = {
    \  'html' : {
		\    'lang' : 'ja',
		\	 'charset' : 'utf-8',
    \  },
    \}


