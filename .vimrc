set nocompatible

""" Search Setting
set ignorecase
set smartcase
set wrapscan

""" Display Settings
set number
set title
set showmatch
set tabstop=4
set smartindent 
set cursorline

""" Color Settings
syntax on
"let g:hybrid_use_iTerm_colors = 1
colorscheme hybrid

""" Pulugin Setting
if has('vim_starting')
	set nocompatible               " Be iMproved

	" Required:
	set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#rc(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

