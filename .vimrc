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
set runtimepath+=/Users/ohyama/.vim/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.vim/dein')
  call dein#begin('~/.vim/dein')

  " Let dein manage dein
  " Required:
  call dein#add('~/.vim/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  call dein#add('itchyny/lightline.vim')
  call dein#add('osyo-manga/vim-anzu')
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('surround.vim')
  call dein#add('tyru/open-browser.vim')
  call dein#add('scrooloose/syntastic')

" markdown
"NeoBundle 'rcmdnk/vim-markdown'
"NeoBundle 'kannokanno/previm'

" HTML/CSS
"NeoBundle 'othree/html5.vim'
"NeoBundle 'hail2u/vim-css3-syntax'
"NeoBundle 'mattn/emmet-vim'
"NeoBundle 'groenewege/vim-less'
"" JavaScript/CoffeeScript
"NeoBundle 'pangloss/vim-javascript'
"NeoBundle 'kchmck/vim-coffee-script'
"" Ruby
"NeoBundle 'vim-ruby/vim-ruby'


  " You can specify revision/branch/tag.
  "call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

if &compatible
  set nocompatible
endif
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim


""" FileType Setting
"au BufRead,BufNewFile,BufReadPre *.coffee   set filetype=coffee
"autocmd FileType coffee     setlocal sw=2 sts=2 ts=2 et
"autocmd FileType ruby	    setlocal sw=2 sts=2 ts=2 et

""" Plugin Settings / indent guides
"let g:indent_guides_start_level=2
"let g:indent_guides_auto_colors=0
"let g:indent_guides_enable_on_vim_startup=0
"let g:indent_guides_color_change_percent=20
"let g:indent_guides_guide_size=1
"let g:indent_guides_space_guides=1

"hi IndentGuidesOdd  ctermbg=235
"hi IndentGuidesEven ctermbg=237
"au FileType coffee,ruby,javascript,python IndentGuidesEnable
"nmap <silent><Leader>ig <Plug>IndentGuidesToggle


""" Plugin Settings / vim-anzu
"nmap n <Plug>(anzu-n)
"nmap N <Plug>(anzu-N)
"nmap * <Plug>(anzu-star)
"nmap # <Plug>(anzu-sharp)
"augroup vim-anzu
"  autocmd!
"      autocmd CursorHold,CursorHoldI,WinLeave,TabLeave * call anzu#clear_search_status()
"augroup END


""" Plugin Settings / lightline with vim-anzu
"let g:lightline = {
"		\ 'active': {
"		\   'left': [ ['mode', 'paste'], ['readonly', 'filename', 'modified', 'anzu'] ]
"		\ },
"		\ 'component_function': {
"		\	'anzu': 'anzu#search_status'
"		\ }
"		\ }


""" Plugin Settings / open-browser.vim
"let g:netrw_nogx = 1 " disable netrw's gx mapping.
"nmap gx <Plug>(openbrowser-smart-search)
"vmap gx <Plug>(openbrowser-smart-search)


""" Plugin Settings / emmet-vim
"let g:user_emmet_leader_key = '<c-e>'
"let g:user_emmet_settings = {
"        \  'html' : {
"		\    'lang' : 'ja',
"		\	 'charset' : 'utf-8',
"        \  },
"        \}


""" Plugin Settings / vim-coffee-script
"nnoremap <silent> <C-C> :CoffeeCompile vert <CR><C-w>h

""" Plugin Settings / neocomplete
" Use neocomplete.
"let g:neocomplete#enable_at_startup = 1
" Use smartcase.
"let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
"let g:neocomplete#sources#syntax#min_keyword_length = 3
"let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
"let g:neocomplete#sources#dictionary#dictionaries = {
"    \ 'default' : '',
"    \ 'vimshell' : $HOME.'/.vimshell_hist',
"    \ 'scheme' : $HOME.'/.gosh_completions'
"        \ }

" Define keyword.
"if !exists('g:neocomplete#keyword_patterns')
"	let g:neocomplete#keyword_patterns = {}
"endif
"let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
"inoremap <expr><C-g>     neocomplete#undo_completion()
"inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
"noremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"function! s:my_cr_function()
"	return neocomplete#close_popup() . "\<CR>"
	" For no inserting <CR> key.
	"return pumvisible() ? neocomplete#close_popup() : "\<CR>"
"endfunction

" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
"inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><BS>	neocomplete#smart_close_popup()."\<C-h>"
"inoremap <expr><C-y> neocomplete#close_popup()
"inoremap <expr><C-e> neocomplete#cancel_popup()

" Enable omni completion.
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

