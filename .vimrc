" INIT:"{{{

" Skip initialization for vim-tiny/small
if !1 | finish | endif

scriptencoding utf-8

" This is vim, not vi
set nocompatible
filetype off

" Vimrc augroup"{{{
augroup MyVimrc
  au!

  au! BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END
"}}}
command! -nargs=* Autocmd autocmd MyVimrc <args>
command! -nargs=* AutocmdFT autocmd MyVimrc Filetype <args>

" Autocmdft
AutocmdFT vim highlight def link myVimAutocmd vimAutoCmd
AutocmdFT vim match myVimAutocmd /\<\(Autocmd\|AutocmdFT\)\>/

" Mapleader"{{{
let mapleader = ','
let g:mapleader = ','
let g:maplocalleader = 'm'
"}}}
" Environment"{{{
" ------------
let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
  \ && (has('mac') || has('macunix') || has('gui_macvim') ||
  \   (!executable('xdg-open') &&
  \     system('uname') =~? '^darwin'))
let s:is_unix = has('linux') || has('unix')

let s:is_gui = has("gui_running")
let s:is_gui_macvim = has("gui_macvim")
let s:is_gui_linux = has("gui_gtk2")

let s:is_term_xterm = &term =~ "xterm*"
let s:is_term_dterm = &term =~ "dterm*"
let s:is_term_rxvt = &term =~ "rxvt*"
let s:is_term_screen = &term =~ "screen*"
let s:is_term_linux = &term =~ "linux"

" TMUX
if exists('$TMUX')
  set clipboard=
else
  set clipboard=unnamed                             "sync with OS clipboard
endif

let s:is_starting = has('vim_starting')
"}}}
" Encoding"{{{
" For Windows
if s:is_windows
    if has('multi_byte')
        set termencoding=cp850
        setglobal fileencoding=utf-8
        set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
    endif

else
" For Unix-like
    set termencoding=utf-8
    set fileencoding=utf-8
    set fileformat=unix
endif
"}}}
" Create directories"{{{
function! s:create_dir(path)
  if !isdirectory(a:path)
    " Note: Not avaible on all systems. To check: if has('*mkdir')
    call mkdir(a:path, 'p')
  endif
endfunction
"}}}
" Source files"{{{
function! SourceIfExist(path)
    if filereadable(a:path)
        execute 'source' a:path
    endif
endfunction
"}}}
" Variables"{{{
" ---------

" Vim config
" ----------
let $CACHE = expand('~/.cache')
let $CACHE_VIM = expand($CACHE.'/vim/.cache')
let s:neobundle_dir = expand('$CACHE/vim/neobundle')
call s:create_dir(s:neobundle_dir)

let s:vim_dir = fnameescape(expand('~/.vim'))
call s:create_dir(s:vim_dir)

" Private
" -------
let s:private_dir = s:vim_dir . '/.private'
call s:create_dir(s:private_dir)

" Backup, view, undo and swap directories
let s:backup_dir = $CACHE_VIM . '/backup'
let s:view_dir = $CACHE_VIM . '/view'
let s:undo_dir = $CACHE_VIM . '/undo'
let s:swap_dir = $CACHE_VIM . '/swap'
let s:tmp_dir = $CACHE_VIM . '/tmp'

call s:create_dir(s:backup_dir)
call s:create_dir(s:view_dir)
call s:create_dir(s:undo_dir)
call s:create_dir(s:swap_dir)
call s:create_dir(s:tmp_dir)

" My bundle
" ---------
let s:my_bundles_dir = s:vim_dir . '/bundle'
call s:create_dir(s:my_bundles_dir)

" Completion plugin
" -----------------
"let g:billinux_complete_plugin = [ 'neocomplete' ]
let g:billinux_complete_plugin = [ 'neocomplcache' ]
"let g:billinux_complete_plugin = [ 'youcompleteme' ]

" Statusline
" -----------
let g:billinux_use_airline = 1
"}}}
" Initial message"{{{
" ---------------
augroup InitialMessage
  au!

  autocmd VimEnter * echo "EnJoy vimming!"
augroup END
"}}}
"}}}

" BUNDLES:"{{{

" Setup Neobundle "{{{
if has('vim_starting')
  " Set runtimepath.
  if s:is_windows
    let &runtimepath = join([
          \ expand('~/.vim'),
          \ expand('$VIM/runtime'),
          \ expand('~/.vim/after')], ',')
  endif

  " Load neobundle.
  if isdirectory('neobundle.vim')
    set runtimepath^=neobundle.vim
  elseif finddir('neobundle.vim', '.;') != ''
    execute 'set runtimepath^=' . finddir('neobundle.vim', '.;')
  elseif &runtimepath !~ '/neobundle.vim'
    if ! isdirectory(expand(s:neobundle_dir))
      echon "Installing neobundle.vim..."
      silent call s:create_dir(s:neobundle_dir)
      execute printf('!git clone %s://github.com/Shougo/neobundle.vim.git',
                \ (exists('$http_proxy') ? 'https' : 'git'))
                \ s:neobundle_dir.'/neobundle.vim'
      echo "done."
      if v:shell_error
        echoerr "neobundle.vim installation has failed!"
        finish
      endif
    endif

    execute 'set rtp+='.s:neobundle_dir.'/neobundle.vim'
  endif
endif
"}}}

call neobundle#begin(expand(s:neobundle_dir))

function! s:cache_bundles() "{{{

  " NeoBundle Management
  " =================================================================
  NeoBundleFetch 'Shougo/neobundle.vim'

  " Always loaded"{{{
  " =================================================================
  NeoBundle 'Shougo/vimproc.vim', {
    \ 'build' : {
    \     'windows' : 'tools\\update-dll-mingw',
    \     'cygwin'  : 'make -f make_cygwin.mak',
    \     'mac'     : 'make -f make_mac.mak',
    \     'linux'   : 'make',
    \     'unix'    : 'gmake',
    \   }
    \ }

  " Colorschemes
  " ------------
  NeoBundle 'fatih/molokai'
  NeoBundle 'chriskempson/base16-vim'
  NeoBundle 'ajh17/Spacegray.vim.git'

  " Plugins
  " -------
  if exists('g:billinux_use_airline')
    NeoBundle 'bling/vim-airline'
  else
    NeoBundle 'itchyny/lightline.vim'
    "NeoBundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
  endif
  NeoBundle 'terryma/vim-multiple-cursors'
  NeoBundle 'Lokaltog/vim-easymotion'
  NeoBundle 'tpope/vim-endwise'
  NeoBundle 'tComment'
  NeoBundle 'airblade/vim-gitgutter'
  NeoBundle 'MattesGroeger/vim-bookmarks'
  NeoBundle 'christoomey/vim-tmux-navigator'
  NeoBundle 'regedarek/ZoomWin'  " TODO: Lazy has problems restoring splits
  NeoBundle "amdt/vim-niji"

  " Completion"{{{
  " -----------------------------------------------------------------

  if count(g:billinux_complete_plugin, 'neocomplete')

    NeoBundle 'Shougo/neocomplete', {
      \ 'depends': 'Shougo/context_filetype.vim',
      \ 'disabled': ! has('lua'),
      \ 'insert': 1
      \ }

    NeoBundle 'rhysd/inu-snippets'

  elseif count(g:billinux_complete_plugin, 'neocomplcache')

    NeoBundle 'Shougo/neocomplcache.vim'
    NeoBundle 'rhysd/inu-snippets'

  elseif count(g:billinux_complete_plugin, 'youcompleteme')

    NeoBundle 'Valloric/YouCompleteMe'
    NeoBundle 'SirVer/ultisnips'
    NeoBundle 'honza/vim-snippets'

  elseif count(g:billinux_complete_plugin, 'snipmate')

    NeoBundle 'garbas/vim-snipmate'
    NeoBundle 'honza/vim-snippets'

    " Source support_function.vim to support vim-snippets.
    call SourceIfExist(s:neobundle_dir.'/vim-snippets/snippets/support_functions.vim')

  endif

  if count(g:billinux_complete_plugin, 'neocomplete') || count(g:billinux_complete_plugin, 'neocomplcache')

    NeoBundleLazy 'Shougo/neosnippet.vim', {
      \ 'depends': 'Shougo/context_filetype.vim',
      \ 'insert': 1,
      \ 'filetypes': 'snippet',
      \ 'unite_sources': [
      \    'neosnippet', 'neosnippet/user', 'neosnippet/runtime'
      \ ]}

    NeoBundleLazy 'Shougo/neosnippet-snippets', {
      \ 'filetypes': 'snippet',
      \ }

  endif

  NeoBundleLazy 'Raimondi/delimitMate', { 'insert': 1 }

  NeoBundleLazy 'Shougo/echodoc.vim', { 'insert': 1 }
  NeoBundleLazy 'kana/vim-smartchr', { 'insert': 1 }

"}}}

  " My own bundles
  " -----------------------------------------------------------------

"}}}
  " Lazy loaded"{{{
  " =================================================================

  " Colorschemes"{{{
  " ------------
  NeoBundleLazy 'flazz/vim-colorschemes'
  NeoBundleLazy 'altercation/vim-colors-solarized'

  NeoBundleLazy 'guns/xterm-color-table.vim', { 'commands': 'XtermColorTable' }
"}}}
  " Plugins"{{{
  " -------
  NeoBundleLazy 'scrooloose/nerdtree', { 'commands': 'NERDTreeToggle'}
  NeoBundleLazy 'nathanaelkane/vim-indent-guides'
""  NeoBundleLazy 'ntpeters/vim-better-whitespace'

  NeoBundleLazy 'lilydjwg/colorizer', { 'filetypes': ['html', 'haml', 'xhtml', 'liquid', 'css', 'less', 'scss', 'sass'] }

  NeoBundleLazy 'mattn/emmet-vim', {
    \ 'autoload': {
    \     'function_prefix': 'emmet',
    \     'filetypes': ['html', 'haml', 'xhtml', 'liquid', 'css', 'less', 'scss', 'sass'],
    \     'mappings' : ['i', '<Plug>(EmmetExpandAbbr)']
    \   }
    \ }

  if executable('ctags')
    NeoBundleLazy 'majutsushi/tagbar'
  endif
"}}}

  " Language"{{{
  " -----------------------------------------------------------------
  NeoBundleLazy 'othree/html5.vim', { 'filetypes': 'html' }
  NeoBundleLazy 'mustache/vim-mustache-handlebars', { 'filetypes': [ 'html', 'mustache', 'hbs' ] }
  NeoBundleLazy 'groenewege/vim-less', { 'filetypes': 'less' }
  NeoBundleLazy 'hail2u/vim-css3-syntax', { 'filetypes' :['sass', 'scss', 'css'] }
  NeoBundleLazy 'wavded/vim-stylus', { 'filetypes' :['sass', 'scss', 'css'] }
  NeoBundleLazy 'tpope/vim-haml', { 'filetypes': ['haml', 'sass', 'scss'] }
  NeoBundleLazy 'digitaltoad/vim-jade', { 'filetypes': 'jade' }
  NeoBundleLazy 'evanmiller/nginx-vim-syntax', { 'filetypes': 'nginx' }
  NeoBundleLazy 'plasticboy/vim-markdown', { 'filetypes': 'mkd' }
  NeoBundleLazy 'chase/vim-ansible-yaml', { 'filetypes': 'yaml' }
  NeoBundleLazy 'chrisbra/csv.vim', { 'filetypes': 'csv' }
  NeoBundleLazy 'dbext.vim', { 'filetypes': 'sql' }
  NeoBundleLazy 'davidhalter/jedi-vim', { 'filetypes': 'python' }
  "NeoBundlelazy 'klen/python-mode' , { 'filetypes': 'python' }
  NeoBundleLazy 'tpope/vim-rails', { 'filetypes': 'runby' }
  NeoBundleLazy 'vim-jp/cpp-vim', { 'filetypes': ['c', 'cpp'] }
  NeoBundleLazy 'octol/vim-cpp-enhanced-highlight', { 'filetypes': ['c', 'cpp'] }
  NeoBundleLazy 'fatih/vim-go', { 'filetypes': 'go' }
  NeoBundleLazy 'Blackrush/vim-gocode', { 'filetypes': ['go', 'markdown'] }
  NeoBundleLazy 'derekwyatt/vim-scala', { 'filetypes': 'scala' }
  NeoBundleLazy 'Txtfmt-The-Vim-Highlighter', { 'filetypes': 'txt' }
  NeoBundleLazy 'PotatoesMaster/i3-vim-syntax', { 'filetypes': 'i3' }
  NeoBundleLazy 'ekalinin/Dockerfile.vim', { 'filetypes': 'dockerfile' }
  NeoBundleLazy 'xsbeats/vim-blade', { 'filetypes': 'blade' }
  NeoBundleLazy 'LaTeX-Box-Team/LaTeX-Box', { 'filetypes': [ 'text', 'latex' ] }
  NeoBundleLazy 'jamestomasino/vim-writingsyntax', { 'filetypes': 'writing' }
  NeoBundleLazy 'elzr/vim-json', { 'filetypes': 'json' }
  NeoBundleLazy 'kchmck/vim-coffee-script', { 'filetypes': [ 'coffee', 'haml' ] }

  " PHP
  " ---
  NeoBundleLazy 'StanAngeloff/php.vim', { 'filetypes': 'php' }
  NeoBundleLazy 'rayburgemeestre/phpfolding.vim', { 'filetypes': 'php' }
  NeoBundleLazy 'm2mdas/phpcomplete-extended', { 'insert': 1, 'filetypes': 'php' }
  NeoBundleLazy 'm2mdas/phpcomplete-extended-laravel', { 'insert': 1, 'filetypes': 'php' }
  NeoBundleLazy 'tobyS/pdv', { 'filetypes': 'php', 'depends': 'tobyS/vmustache' }
  NeoBundleLazy '2072/PHP-Indenting-for-VIm', { 'filetypes': 'php', 'directory': 'php-indent' }

  " Javascript
  " ----------
  NeoBundleLazy 'pangloss/vim-javascript', { 'filetypes': 'javascript' }
  NeoBundleLazy 'marijnh/tern_for_vim', {
    \   'build': { 'others': 'npm install' },
    \   'disabled': executable('npm') != 1,
    \   'autoload': { 'filetypes': 'javascript' }
    \ }

  NeoBundleLazy 'moll/vim-node', { 'filetypes': 'javascript' }

"}}}
  " Commands"{{{
  " -----------------------------------------------------------------

  NeoBundleLazy 'Shougo/vimshell', {
    \ 'autoload' : {
    \     'commands' : ['VimShell', 'VimShellSendString', 'VimShellCurrentDir', 'VimShellInteractive'],
    \     }
    \ }

  NeoBundleLazy 'Shougo/vimfiler.vim', {
    \ 'depends': [ 'Shougo/unite.vim', 'Shougo/tabpagebuffer.vim' ],
    \ 'mappings': '<Plug>',
    \ 'explorer': 1,
    \ 'commands': [
    \    { 'name': [ 'VimFiler', 'Edit', 'Write'],
    \      'complete': 'customlist,vimfiler#complete' },
    \    'Read', 'Source'
    \ ]}

  NeoBundleLazy 'Shougo/vinarise.vim', { 'commands': [ { 'name': 'Vinarise', 'complete': 'file' } ]}

  NeoBundleLazy 'tpope/vim-fugitive', {
    \ 'autoload': {
    \   'augroup': 'fugitive',
    \   'commands': [
    \     'Git', 'Gdiff', 'Gstatus', 'Gwrite', 'Gcd', 'Glcd',
    \     'Ggrep', 'Glog', 'Gcommit', 'Gblame', 'Gbrowse'
    \   ]
    \ }}

  NeoBundleLazy 'gregsexton/gitv', { 'depends': 'tpope/vim-fugitive', 'commands': [ 'Gitv' ] }


  NeoBundleLazy 'sjl/gundo.vim', {
    \ 'disabled': ! has('python'),
    \ 'vim_version': '7.3',
    \ 'autoload': { 'commands': [ 'GundoToggle' ] }
    \ }

  NeoBundleLazy 'gorkunov/smartpairs.vim', {
    \ 'autoload': {
    \  'commands': [ 'SmartPairs', 'SmartPairsI', 'SmartPairsA' ],
    \  'mappings': [[ 'n', 'viv' ], [ 'v', 'v' ]]
    \ }}

  NeoBundleLazy 'farseer90718/vim-colorpicker', { 'disabled': ! has('python'), 'commands': 'ColorPicker' }

  NeoBundleLazy 't9md/vim-smalls', { 'mappings': '<Plug>' }

  NeoBundleLazy 'kannokanno/previm', {
    \ 'filetypes': [ 'markdown', 'rst' ],
    \ 'commands': 'PrevimOpen',
    \ 'depends': 'tyru/open-browser.vim'
    \ }

  NeoBundleLazy 'tyru/open-browser.vim', { 'mappings': '<Plug>', 'functions' : 'openbrowser#open' }
"}}}
  " Interface"{{{
  " -----------------------------------------------------------------
  NeoBundleLazy 'matchit.zip', { 'mappings': [[ 'nxo', '%', 'g%' ]]}

  NeoBundleLazy 'xolox/vim-session', {
    \ 'depends': 'xolox/vim-misc',
    \ 'augroup': 'PluginSession',
    \ 'autoload': {
    \ 'commands': [
    \   { 'name': [ 'OpenSession', 'CloseSession' ],
    \     'complete': 'customlist,xolox#session#complete_names' },
    \   { 'name': [ 'SaveSession' ],
    \     'complete': 'customlist,xolox#session#complete_names_with_suggestions' }
    \ ],
    \ 'functions': [ 'xolox#session#complete_names',
    \                'xolox#session#complete_names_with_suggestions' ],
    \ 'unite_sources': [ 'session', 'session/new' ]
    \ }}

  NeoBundleLazy 'jszakmeister/vim-togglecursor', { 'insert': 1}

"}}}
  " Unite"{{{
  " -----------------------------------------------------------------
  NeoBundleLazy 'Shougo/unite.vim', {
    \ 'depends': 'Shougo/tabpagebuffer.vim',
    \ 'commands': [
    \   { 'name': 'Unite', 'complete': 'customlist,unite#complete_source' }
    \ ]}

  " Unite sources
  " -------------
  NeoBundleLazy 'Shougo/unite-build'
  NeoBundleLazy 'ujihisa/unite-colorscheme'

  NeoBundleLazy 'Shougo/neossh.vim', { 'filetypes': 'vimfiler', 'sources': 'ssh', }

  NeoBundleLazy 'Shougo/unite-outline', { 'unite_sources': 'outline' }

  NeoBundleLazy 'osyo-manga/unite-quickfix', { 'unite_sources': [ 'quickfix', 'location_list' ] }

  NeoBundleLazy 'tsukkee/unite-tag', { 'unite_sources': [ 'tag', 'tag/file', 'tag/include' ] }

  NeoBundleLazy 'joker1007/unite-pull-request', {
    \  'depends': 'mattn/webapi-vim',
    \  'unite_sources': [ 'pull_request', 'pull_request_file' ]
    \ }

  NeoBundleLazy 'rhysd/unite-stackoverflow.vim', { 'unite_sources': 'stackoverflow' }
"}}}
  " Operators"{{{
  " -----------------------------------------------------------------
  NeoBundleLazy 'kana/vim-operator-user', { 'functions': 'operator#user#define', }

  NeoBundleLazy 'rhysd/vim-operator-surround', { 'depends': 'vim-operator-user', 'mappings': '<Plug>' }
"}}}
  " Textobjs"{{{
  " -----------------------------------------------------------------
  NeoBundleLazy 'kana/vim-textobj-user'
  NeoBundleLazy 'osyo-manga/vim-textobj-multiblock', {
    \ 'depends': 'vim-textobj-user',
    \ 'autoload': {
    \   'mappings': [[ 'ox', '<Plug>' ]]
    \ }}
  NeoBundleLazy 'gcmt/wildfire.vim'

"}}}
"}}}

endfunction "}}}

" Neobundleloadcache"{{{
if neobundle#has_cache()
  NeoBundleLoadCache
else
  call s:cache_bundles()
  NeoBundleSaveCache
endif
"}}}

call neobundle#end()

filetype plugin indent on     " required!
syntax enable

" Plugin installation check
NeoBundleCheck"

" Required for clearing chache
AutocmdFT BufWritePost .vimrc,.gvimrc,*vimrc,*gvimrc NeoBundleClearCache

" NeoBundle search bundle name"{{{
function! s:browse_neobundle_home(bundle_name)
    if match(a:bundle_name, '/') == -1
        let url = 'http://www.google.gp/search?q='.a:bundle_name
    else
        let url = 'https://github.com/'.a:bundle_name
    endif
    execute 'OpenBrowser' url
endfunction
command! -nargs=1 BrowseNeoBundleHome call <SID>browse_neobundle_home(<q-args>)
"}}}
" Neobundle maps"{{{
nnoremap <silent><Leader>nbu :<C-u>NeoBundleUpdate<CR>
nnoremap <silent><Leader>nbc :<C-u>NeoBundleClean<CR>
nnoremap <silent><Leader>nbi :<C-u>NeoBundleInstall<CR>
nnoremap <silent><Leader>nbl :<C-u>Unite output<CR>NeoBundleList<CR>
nnoremap <silent><Leader>nbd :<C-u>NeoBundleDocs<CR>
nnoremap <silent><Leader>nbh :<C-u>execute 'BrowseNeoBundleHome' matchstr(getline('.'), '\%[Neo]Bundle\%[Lazy]\s\+[''"]\zs.\+\ze[''"]')<CR>
"}}}

"}}}

" SETTINGS:"{{{

" Formatting"{{{
set autoindent smartindent
" Cf SetIndent in 'COMMANDS' in order to change these values
set tabstop=2 shiftwidth=2 softtabstop=2
set shiftround
set expandtab
set textwidth=0
set smarttab
set fileformats=unix,dos,mac
set formatoptions-=r
set formatoptions-=o

" Formatting mappings"{{{
nmap <leader>fef :call Preserve("normal gg=G")<CR>
nmap <leader>f$ :call StripTrailingWhitespace()<CR>
vmap <leader>s :sort<cr>
"}}}
" Indent multiple lines with TAB"{{{
"vmap <Tab> >
"vmap <S-Tab> <
"}}}
" Keep visual selection after identing"{{{
vnoremap < <gv
vnoremap > >gv
"nnoremap > >>
"nnoremap < <<
"}}}
" Remove the Windows ^M - when the encodings gets messed up"{{{
noremap <Leader>mm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
"}}}
"}}}
" Search"{{{
set confirm
set ignorecase
set infercase
set smartcase
set hlsearch
set incsearch
set magic
set showmatch
set matchtime=2
set matchpairs+=<:>

" Sane regex"{{{
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
cnoremap s/ s/\v
"}}}
" To clear search highlighting rather than toggle it and off"{{{
"noremap <silent> <leader><space> :noh<CR>
noremap <silent> <leader><space> :set hlsearch! hlsearch?<cr>
"}}}
" ag using"{{{
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --column
else
  set grepprg=grep\ -rnH\ --exclude=tags\ --exclude-dir=.git\ --exclude-dir=node_modules
endif
"}}}
"}}}
" Shells"{{{
" VIM expects to be run from a POSIX shell."{{{
if $SHELL =~ '/fish$'
  set shell=sh
endif
"}}}
" Windows shell"{{{
if s:is_windows && !s:is_cygwin
  " ensure correct shell in gvim
  set shell=c:\windows\system32\cmd.exe
endif
"}}}
"}}}
" Display"{{{
set backspace=indent,eol,start
set hidden
set ttyfast
set showcmd
set scrolloff=5

" best vim-airline display
set noshowmode
set lazyredraw

set ruler
set rulerformat=%45(%12f%=\ %m%{'['.(&fenc!=''?&fenc:&enc).']'}\ %l-%v\ %p%%\ [%02B]%)
set laststatus=2
set statusline=%f:\ %{substitute(getcwd(),'.*/','','')}\ %m%=%{(&fenc!=''?&fenc:&enc).':'.strpart(&ff,0,1)}\ %l-%v\ %p%%\ %02B
set virtualedit& virtualedit+=block

"}}}
" Number"{{{
set number numberwidth=3
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set number
    set relativenumber
endif
endfunc
" Switch number/relativenumber
nnoremap <leader>; :call NumberToggle()<cr>
"}}}
" backup, undo, swap, view"{{{
set backup undofile undoreload=1000 noswapfile
set backupskip=/tmp/*,/private/tmp/*
set backupdir=$CACHE_VIM/backup//
set directory=$CACHE_VIM/swap//
set viminfo+=n$CACHE_VIM/viminfo   " +viminfo
set undodir=$CACHE_VIM/undo//      " +persistent_undo
set viewdir=$CACHE_VIM/view//
"set spellfile=$CACHE_VIM/spell/en.utf-8.add
"}}}
" List"{{{
set list
if (&termencoding ==# 'utf-8' || &encoding ==# 'utf-8') && version >= 700
  set listchars=tab:›\
  set listchars+=eol:$
  set listchars+=trail:⋅
  set listchars+=extends:›
  set listchars+=precedes:‹
  set listchars+=nbsp:+

"  set fillchars=stl:\
"  set fillchars+=stlnc:\
  set fillchars+=vert:\|
  set fillchars+=fold:\⋅
  set fillchars+=diff:-
else
  set listchars=tab:\ \
  set listchars+=eol:$
  set listchars+=trail:~
  set listchars+=extends:>
  set listchars+=precedes:<
  set listchars+=nbsp:+

"  set fillchars=stl:\
"  set fillchars+=stlnc:\
  set fillchars+=vert:\|
  set fillchars+=fold:\-
  set fillchars+=diff:-
endif
set showbreak=↪\

"Invisible character colors
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
"
" Switch list
nmap <leader>l :set list! list?<cr>
"}}}
" Treat break lines"{{{
set linebreak
" Breakindent"{{{
if exists('+breakindent')
  set wrap
  set breakindent
  set breakindentopt=shift:-4
  let &showbreak='↪ '
else
  set nowrap
endif
"}}}
" Navigate line by line through wrapped text (skip wrapped lines)."{{{
au BufReadPre * imap <UP> <ESC>gka
au BufReadPre * imap <DOWN> <ESC>gja
"}}}
" Navigate row by row through wrapped text."{{{
au BufReadPre * nmap k gk
au BufReadPre * nmap j gj
"}}}
" Treat long lines as break lines (useful when moving around in them)"{{{
nnoremap <silent> k :<C-U>execute 'normal!' (v:count>1 ? "m'".v:count.'k' : 'gk')<Enter>
nnoremap <silent> j :<C-U>execute 'normal!' (v:count>1 ? "m'".v:count.'j' : 'gj')<Enter>
"}}}
"}}}
" Errors"{{{
set noerrorbells
set novisualbell
set timeoutlen=500
set t_vb=
"}}}
" Wildmenu"{{{
if has('wildmenu')
  set nowildmenu
  set wildmode=list:longest,full
  set wildoptions=tagfile
  set wildignorecase
  set wildignore+=.hg,.git,.svn,*.pyc,*.spl,*.o,*.out,*~,#*#,%*
endif

"}}}
" Folding"{{{
function! NeatFoldText() "{{{
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=NeatFoldText()

"}}}

set foldenable
set foldmethod=marker
set foldlevelstart=0
set foldopen=block,hor,mark,percent,quickfix,tag,search

"}}}
" Windows"{{{
set splitbelow
set splitright

nnoremap + <C-W>+
nnoremap _ <C-W>-
nnoremap = <C-W>>
nnoremap - <C-W><

" Move between windows
if !exists('s:settings.switch_windows')
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
else
  map <C-J> <C-W>j<C-W>_
  map <C-k> <C-W>k<C-W>_
  map <C-h> <C-W>h<C-W>_
  map <C-l> <C-W>l<C-W>_
endif
"}}}
" Buffer and tab"{{{
" Buffer"{{{
" Quick buffer open"{{{
nnoremap gb :ls<cr>:e #
"}}}
" Close the current buffer"{{{
map <leader>bd :Bclose<cr>
"}}}
" Close all the buffers"{{{
map <leader>ba :1,1000 bd!<cr>
"}}}
" Switch CWD to the directory of the open buffer"{{{
map <leader>cd :cd %:p:h<cr>:pwd<cr>
"}}}
" Specify the behavior when switching between buffers "{{{
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry
"}}}
" Remember info about open buffers on close"{{{
set viminfo^=%
"}}}
"}}}
" Tabs"{{{
" Useful mappings for managing tabs"{{{
map <leader>tn :tabnew<CR>
"map <leader>tc :tabclose<CR>
map <leader>tf :tabclose<CR>
map <leader>to :tabonly<CR>
map <leader>tm :tabmove
"}}}
" Opens a new tab with the current buffer's path"{{{
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
"}}}
"}}}
" Delete current buffer"{{{
function! s:delete_current_buf()
    let bufnr = bufnr('%')
    bnext
    if bufnr == bufnr('%') | enew | endif
    silent! bdelete #
endfunction
nnoremap <C-w>d :<C-u>call <SID>delete_current_buf()<CR>
nnoremap <C-w>D :<C-u>bdelete<CR>
"}}}
""}}}
" Using the mouse on a terminal."{{{
if has('mouse')
  set mouse=a
  if has('mouse_sgr') || v:version > 703 ||
        \ v:version == 703 && has('patch632')
    set ttymouse=sgr
  else
    set ttymouse=xterm2
  endif

  " Paste.
  nnoremap <RightMouse> "+p
  xnoremap <RightMouse> "+p
  inoremap <RightMouse> <C-r><C-o>+
  cnoremap <RightMouse> <C-r>+
endif
"}}}
" Paste"{{{
" Toggle paste"{{{
map ;; :set invpaste<CR>:set paste?<CR>
map <Leader>, :set invpaste<CR>:set paste?<CR>
"}}}
" Reselect last paste"{{{
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
"}}}
"}}}
" Chmod"{{{
if executable('chmod')
    autocmd BufWritePost * call s:add_permission_x()

    function! s:add_permission_x()
        let file = expand('%:p')
        if getline(1) =~# '^#!' && !executable(file)
            silent! call vimproc#system('chmod a+x ' . shellescape(file))
        endif
    endfunction
endif
"}}}
" ToHtml"{{{
function! VimrcTOHtml() "{{{
  TOhtml
  try
      silent exe '%s/&quot;\(\s\+\)\*&gt; \(.\+\)</"\1<a href="#\2" style="color: #bdf">\2<\/a></g'
  catch
  endtry

  try
      silent exe '%s/&quot;\(\s\+\)=&gt; \(.\+\)</"\1<a name="\2" style="color: #fff">\2<\/a></g'
  catch
  endtry

  exe ":write!"
  exe ":bd"
endfunction "}}}
" To export syntax highlighted code in html format."{{{
map <F6> :runtime! syntax/2html.vim
"}}}
"}}}
" Cursor"{{{
"autocmd InsertEnter * set cul
"autocmd InsertLeave * set nocul
"hi Cursor ctermbg=black
"hi Normal ctermbg=darkgray"
"}}}


"}}}

" UI:"{{{
" Common settings
" ---------------
set background=dark
set t_Co=256

if &t_Co < 256
  try
    let base16colorspace=256  " Access colors present in 256 colorspace"
    colorscheme base16-monokai
  catch
    colorscheme default
  endtry
elseif strftime("%H") >=  5 && strftime("%H") <=  17
  colorscheme molokai
else
  colorscheme molokai
  "colorscheme spacegray
endif

" Environment
" -----------
if s:is_mac
  "set guifont=Source\ Code\ Pro\ for\ Powerline:15
  set guifont=Meslo\ LG\ S\ Regular\ for\ Powerline:h12
  "set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h12
  "set guifont=Menlo\ Regular\ for\ Powerline:h12

elseif s:is_unix
  set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h13
elseif s:is_windows
  set guifont=Bistream\ Vera\ Sans\ Mono\ for\ Powerline:h12
  autocmd GUIEnter * simalt ~x
endif

" Gui
" ---
if s:is_gui

  set guioptions-=m
  set guioptions-=l
  set guioptions-=r
  set guioptions-=R
  set guioptions-=L
  set guioptions-=T

  if exists('s:settings.enable_gui_fullscreen')
    " open maximized
    set lines=999 columns=9999
  else
    set lines=30 columns=120
  endif

  if s:is_gui_macvim
    set transparency=10
    set fuoptions+=maxvert,maxhorz

    " Swipe to move between bufers :D
    map <silent> <SwipeLeft> :bprev<CR>
    map <silent> <SwipeRight> :bnext<CR>

    " Cmd+Shift+N = new buffer
    map <silent> <D-N> :enew<CR>

    " Cmd+t = new tab
    nnoremap <silent> <D-t> :tabnew<CR>

    " Cmd+w = close tab (this should happen by default)
    nnoremap <silent> <D-w> :tabclose<CR>

    " Cmd+1...9 = go to that tab
    map <silent> <D-1> 1gt
    map <silent> <D-2> 2gt
    map <silent> <D-3> 3gt
    map <silent> <D-4> 4gt
    map <silent> <D-5> 5gt
    map <silent> <D-6> 6gt
    map <silent> <D-7> 7gt
    map <silent> <D-8> 8gt
    map <silent> <D-9> 9gt

    " OS X probably has ctags in a weird place
    let g:tagbar_ctags_bin='/usr/local/bin/ctags'

  elseif s:is_gui_linux

    " Alt+n = new buffer
    map <silent> <A-n> :enew<CR>

    " Alt+t = new tab
    nnoremap <silent> <A-t> :tabnew<CR>

    " Alt+w = close tab
    nnoremap <silent> <A-w> :tabclose<CR>

    " Alt+1...9 = go to that tab
    map <silent> <A-1> 1gt
    map <silent> <A-2> 2gt
    map <silent> <A-3> 3gt
    map <silent> <A-4> 4gt
    map <silent> <A-5> 5gt
    map <silent> <A-6> 6gt
    map <silent> <A-7> 7gt
    map <silent> <A-8> 8gt
    map <silent> <A-9> 9gt
  endif

else

" Terminal
" --------
  " Gnome
  " You have to modify font in Edit, Preferences and choose a powerline font
  if $COLORTERM == 'gnome-terminal'
    set t_Co=256 "why you no tell me correct colors?!?!
  endif

  " Dterm
  if s:is_term_dterm
    set tsl=0
  endif

  " Urxvt
  if s:is_term_rxvt
    let &t_SI = "\033]12;red\007"
    let &t_EI = "\033]12;green\007"
  endif

  " Screen
  if s:is_term_screen
    let &t_SI = "\033P\033]12;red\007\033\\"
    let &t_EI = "\033P\033]12;green\007\033\\"
  endif

  " iTerm
  if $TERM_PROGRAM == 'iTerm.app'
    " different cursors for insert vs normal mode
    if exists('$TMUX')
      set t_Co=256


      set ttymouse=sgr
      " execute 'silent !echo -e "\033kvim\033\\"'

      execute "set <xUp>=\e[1;*A"
      execute "set <xDown>=\e[1;*B"
      execute "set <xRight>=\e[1;*C"
      execute "set <xLeft>=\e[1;*D"

      execute "set <xHome>=\e[1;*H"
      execute "set <xEnd>=\e[1;*F"

      execute "set <Insert>=\e[2;*~"
      execute "set <Delete>=\e[3;*~"
      execute "set <PageUp>=\e[5;*~"
      execute "set <PageDown>=\e[6;*~"

      execute "set <xF1>=\e[1;*P"
      execute "set <xF2>=\e[1;*Q"
      execute "set <xF3>=\e[1;*R"
      execute "set <xF4>=\e[1;*S"

      execute "set <F5>=\e[15;*~"
      execute "set <F6>=\e[17;*~"
      execute "set <F7>=\e[18;*~"
      execute "set <F8>=\e[19;*~"
      execute "set <F9>=\e[20;*~"
      execute "set <F10>=\e[21;*~"
      execute "set <F11>=\e[23;*~"
      execute "set <F12>=\e[24;*~"

      execute "set t_kP=^[[5;*~"
      execute "set t_kN=^[[6;*~"

      let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
      let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    else
      let &t_SI = "\<Esc>]50;CursorShape=1\x7"
      let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    endif
  endif
endif
"}}}

" AUTOCOMMANDS:"{{{

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  Autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " http://d.hatena.ne.jp/thinca/20090530/1243615055
  Autocmd CursorMoved,CursorMovedI,WinLeave * setlocal nocursorline
  Autocmd CursorHold,CursorHoldI,WinEnter * setlocal cursorline

  " Delete trailing whitespace
  " http://makandracards.com/makandra/11541-how-to-not-leave-trailing-whitespace-using-your-editor-or-git
  Autocmd BufWritePre * :%s/\s\+$//e

  " *.md filetype
  Autocmd BufRead,BufNew,BufNewFile *.md,*.markdown,*.mkd setlocal ft=markdown
  " http://mattn.kaoriya.net/software/vim/20140523124903.htm
  let g:markdown_fenced_languages = [
        \  'coffee',
        \  'css',
        \  'erb=eruby',
        \  'javascript',
        \  'js=javascript',
        \  'json=javascript',
        \  'ruby',
        \  'sass',
        \  'xml',
        \  'vim',
        \]

  " Enable spellchecking for Markdown
  Autocmd FileType markdown setlocal spell

  " Automatically wrap at 80 characters for Markdown
  Autocmd BufRead,BufNewFile *.md setlocal textwidth=80

  " tmux
  Autocmd BufRead,BufNew,BufNewFile *tmux.conf setlocal ft=tmux

  " git config file
  Autocmd BufRead,BufNew,BufNewFile gitconfig setlocal ft=gitconfig

  " Gnuplot
  Autocmd BufRead,BufNew,BufNewFile *.plt,*.plot,*.gnuplot setlocal ft=gnuplot

  " Ruby
  Autocmd BufRead,BufNew,BufNewFile Guardfile setlocal ft=ruby

  " Gitconfig
  Autocmd BufRead,BufNew,BufNewFile gitconfig.* setlocal ft=gitconfig

  " JSON
  Autocmd BufRead,BufNew,BufNewFile *.json,*.jsonp setlocal ft=json

  " jade
  Autocmd BufRead,BufNew,BufNewFile *.jade setlocal ft=jade

  " Go
  Autocmd BufRead,BufNew,BufNewFile *.go setlocal ft=go

  " vimspec
  Autocmd BufRead,BufNew,BufNewFile *.vimspec setlocal ft=vim.vimspec

  "------  PHP Filetype Settings  ------
  " ,p = Runs PHP lint checker on current file
  map <Leader>p :! php -l %<CR>

  " ,P = Runs PHP and executes the current file
  map <Leader>P :! php -q %<CR>

  AutocmdFT php set omnifunc=phpcomplete#CompletePHP
  "

  AutocmdFT  php
      \ nnoremap <silent><buffer> <Leader>k :call pdv#DocumentCurrentLine()<CR>
  "
  Autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif


  Autocmd BufWritePost
      \ * if &l:filetype ==# '' || exists('b:ftdetect')
      \ |   unlet! b:ftdetect
      \ |   filetype detect
      \ | endif

  " git commit message
  AutocmdFT gitcommit setlocal nofoldenable spell
  AutocmdFT diff setlocal nofoldenable

  " Display errors at the bottom of the screen,
  Autocmd BufWritePost *.py call Pep8()

  " Automatically wrap at 72 characters and spell check git commit messages
  Autocmd FileType gitcommit setlocal textwidth=72
  Autocmd FileType gitcommit setlocal spell

  " Allow stylesheets to autocomplete hyphenated words
  Autocmd FileType css,scss,sass setlocal iskeyword+=-


augroup END
"}}}

" MAPPINGS"{{{
" Edit and source .vimrc"{{{
nmap <silent> <leader>ev :vsplit $MYVIMRC<CR>
nmap <silent> <leader>sv :source $MYVIMRC<CR>
"}}}
" Arrow keys"{{{
" Keep hands on the keyboard"{{{
inoremap jj <ESC>
inoremap kk <ESC>
inoremap jk <ESC>
inoremap kj <ESC>
"}}}
" Remap arrow keys"{{{
nnoremap <down> :bprev<CR>
nnoremap <up> :bnext<CR>
nnoremap <left> :tabnext<CR>
nnoremap <right> :tabprev<CR>
"}}}
""}}}
" Save and exit"{{{
" Fast saving"{{{
nnoremap <Leader>w :w<CR>
vnoremap <Leader>w <Esc>:w<CR>
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>
vnoremap <C-s> <Esc>:w<CR>

nnoremap <Leader>x :x<CR>
vnoremap <Leader>x <Esc>:x<C>
"}}}
" Fast exit"{{{
"nnoremap q :q!<cr>
nnoremap <leader>q :qa!<cr>
"}}}
"}}}
" Normal mode pressing * or # searches for the current selection"{{{
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz
"}}}
" Visual mode pressing * or # searches for the current selection"{{{
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>
"}}}
" Make Y consistent with C and D. See :help Y."{{{
nnoremap Y y$
"}}}
  " command-line window {{{
    nnoremap q: q:i
    nnoremap q/ q/i
    nnoremap q? q?i
  " }}}
" Vim dispatch"{{{
if neobundle#is_sourced('vim-dispatch')
  nnoremap <leader>tag :Dispatch ctags -R<cr>
endif
"}}}
" Move around windows "{{{
nnoremap <C-w>* <C-w>s*
nnoremap <C-w># <C-w>s#
nnoremap <silent><C-w>h :<C-u>call <SID>jump_window_wrapper('h', 'l')<CR>
nnoremap <silent><C-w>j :<C-u>call <SID>jump_window_wrapper('j', 'k')<CR>
nnoremap <silent><C-w>k :<C-u>call <SID>jump_window_wrapper('k', 'j')<CR>
nnoremap <silent><C-w>l :<C-u>call <SID>jump_window_wrapper('l', 'h')<CR>
"}}}
function! s:jump_window_wrapper(cmd, fallback) "{{{
  let old = winnr()
  execute 'normal!' "\<C-w>" . a:cmd

  if old == winnr()
    execute 'normal!' "999\<C-w>" . a:fallback
  endif
endfunction "}}}
" Visual selection of various text objects"{{{
nnoremap VV V
nnoremap Vit vitVkoj
nnoremap Vat vatV
nnoremap Vab vabV
nnoremap VaB vaBV
"}}}
"}}}

" PLUGINS:"{{{

" Always loaded"{{{
" =================================================================

" Colorschemes"{{{
" -----------------------------------------------------------------

" Molokai"{{{
let g:molokai_original = 1
let g:rehash256 = 1
"}}}
" Base16-vim"{{{

"}}}
"}}}
" Plugins"{{{
" -----------------------------------------------------------------

if exists('g:billinux_use_airline')
" Vim-Airline"{{{
  if ! s:is_gui
    let g:airline_theme = 'wombat'
  endif
  let g:airline_theme = 'badwolf'

  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif

  " unicode symbols
  if !exists('g:airline_powerline_fonts')
    let g:airline_powerline_fonts=1
  else
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.paste = 'ρ'
    let g:airline_left_sep          =  '⮀'
    let g:airline_left_alt_sep      =  '⮁'
    let g:airline_right_sep         =  '⮂'
    let g:airline_right_alt_sep     =  '⮃'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '⭡'
    let g:airline_symbols.branch     =  '⭠'
  endif

  " Display open buffers in tabline
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#branch#enabled = 1
  let g:airline#extensions#syntastic#enabled = 1
  let g:airline#extensions#tagbar#enabled = 1
  let g:airline#extensions#csv#enabled = 1
  let g:airline#extensions#hunks#enabled = 1
  let g:airline#extensions#whitespace#enabled = 1
  let g:airline#extensions#whitespace#symbol = '!'

  " Enable powerline fonts
  let g:airline_powerline_fonts=1
"}}}
else
" Lightline.vim"{{{
  let g:lightline = {
    \ 'colorscheme': 'wombat',
    \ 'mode_map': { 'c': 'NORMAL' },
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
    \ },
    \ 'component_function': {
    \   'modified': 'MyModified',
    \   'readonly': 'MyReadonly',
    \   'fugitive': 'MyFugitive',
    \   'filename': 'MyFilename',
    \   'fileformat': 'MyFileformat',
    \   'filetype': 'MyFiletype',
    \   'fileencoding': 'MyFileencoding',
    \   'mode': 'MyMode',
    \ },
    \ 'separator': { 'left': '⮀', 'right': '⮂' },
    \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
    \ }

  function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
  endfunction

  function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '⭤' : ''
  endfunction

  function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
      \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
      \  &ft == 'unite' ? unite#get_status_string() :
      \  &ft == 'vimshell' ? vimshell#get_status_string() :
      \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
      \ ('' != MyModified() ? ' ' . MyModified() : '')
  endfunction

  function! MyFugitive()
    if &ft !~? 'vimfiler\|gundo' && exists("*fugitive#head")
      let _ = fugitive#head()
      return strlen(_) ? '⭠ '._ : ''
    endif
    return ''
  endfunction

  function! MyFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
  endfunction

  function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
  endfunction

  function! MyFileencoding()
    return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
  endfunction

  function! MyMode()
    return winwidth(0) > 60 ? lightline#mode() : ''
  endfunction

"}}}
endif
" Vim-multiple-cursors"{{{
let g:multi_cursor_use_next_key = '<C-d>'
let g:multi_cursor_exit_from_visual_mode = 0
let g:multi_cursor_exit_from_insert_mode = 0
"}}}
" Vim-easymotion"{{{

"}}}
" Vim-endwise"{{{

"}}}
" tComment"{{{

"}}}
" Vim-gitgutter"{{{

"}}}
" Vim-bookmarks"{{{
let g:bookmark_auto_save_dir  = $CACHE_VIM.'/bookmarks'
"}}}
" Vim-tmux-navigator"{{{

"}}}
" ZoomWin"{{{

"}}}
" Vim-niji"{{{
"}}}

"}}}
" Neocomplete_Neocomplcache_Youcomplteme_Neosnippet:"{{{

" Neocomplete, Neocomplcache, Youcomplteme"{{{

" Neocomplete {{{
" ----------------------------------------------
if count(g:billinux_complete_plugin, 'neocomplete')

  "AutoComplPop
  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#enable_fuzzy_completion = 1
  let g:neocomplete#enable_auto_delimiter = 1
  let g:neocomplete#min_keyword_length = 3
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  let g:neocomplete#auto_completion_start_length = 2
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns['default'] = '\h\w*'
  " ctags
  if executable('/usr/local/bin/ctags')
    let g:neocomplete#ctags_command = '/usr/local/bin/ctags'
  elseif executable('/usr/bin/ctags')
    let g:neocomplete#ctags_command = '/usr/bin/gctags'
  endif
  " Ruby
  let g:neocomplete#sources#file_include#exts
    \ = get(g:, 'neocomplete#sources#file_include#exts', {})
  let g:neocomplete#sources#file_include#exts.ruby = ['', 'rb']
  " Max list
  let g:neocomplete#max_list = 300
  " Dictionnaries
  let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : expand('~/.vimshell/command-history'),
    \ }
  " Delimiter
  if !exists('g:neocomplete#delimiter_patterns')
    let g:neocomplete#delimiter_patterns = {}
  endif
  let g:neocomplete#delimiter_patterns.vim = ['#']
  let g:neocomplete#delimiter_patterns.cpp = ['::']
  " Source include paths
  if !exists('g:neocomplete#sources#include#paths')
    let g:neocomplete#sources#include#paths = {}
  endif
  let g:neocomplete#sources#include#paths.cpp  = '.,/usr/local/include,/usr/local/opt/gcc49/lib/gcc/x86_64-apple-darwin13.1.0/4.9.0/include/c++,/usr/include'
  let g:neocomplete#sources#include#paths.c    = '.,/usr/include'
  let g:neocomplete#sources#include#paths.perl = '.,/System/Library/Perl,/Users/rhayasd/Programs'
  let g:neocomplete#sources#include#paths.ruby = expand('~/.rbenv/versions/2.0.0-p195/lib/ruby/2.0.0')
  " Include patterns
  let g:neocomplete#sources#include#patterns = { 'c' : '^\s*#\s*include', 'cpp' : '^\s*#\s*include', 'ruby' : '^\s*require', 'perl' : '^\s*use', }
  " Include regex
  let g:neocomplete#filename#include#exprs = {
    \ 'ruby' : "substitute(substitute(v:fname,'::','/','g'),'$','.rb','')"
    \ }
  " Omnicomplete
  AutocmdFT python setlocal omnifunc=pythoncomplete#Complete
  AutocmdFT html   setlocal omnifunc=htmlcomplete#CompleteTags
  AutocmdFT css    setlocal omnifunc=csscomplete#CompleteCss
  AutocmdFT xml    setlocal omnifunc=xmlcomplete#CompleteTags
  AutocmdFT php    setlocal omnifunc=phpcomplete#CompletePHP
  AutocmdFT c      setlocal omnifunc=ccomplete#Complete
  " Neocomplete source
  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif
  let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.c   = '\%(\.\|->\)\h\w*'
  let g:neocomplete#sources#omni#input_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
  let g:neocomplete#sources#omni#input_patterns.javascript = '\%(\h\w*\|[^. \t]\.\w*\)'
  " Neocomplete
  let g:neocomplete#sources#vim#complete_functions = {
    \ 'Unite' : 'unite#complete_source',
    \ 'VimShellExecute' : 'vimshell#vimshell_execute_complete',
    \ 'VimShellInteractive' : 'vimshell#vimshell_execute_complete',
    \ 'VimShellTerminal' : 'vimshell#vimshell_execute_complete',
    \ 'VimShell' : 'vimshell#complete',
    \ 'VimFiler' : 'vimfiler#complete',
    \}
  let g:neocomplete#force_overwrite_completefunc = 1
  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif
  let g:neocomplete#force_omni_input_patterns.python = '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
  " Neosnippet
  call neocomplete#custom#source('neosnippet', 'min_pattern_length', 1)
  " Neocomplete javascript
  let g:neocomplete#sources#omni#functions = get(g:, 'neocomplete#sources#omni#functions', {})
  if s:enable_tern_for_vim
      let g:neocomplete#sources#omni#functions.javascript = 'tern#Complete'
      let g:neocomplete#sources#omni#functions.coffee = 'tern#Complete'
      AutocmdFT javascript setlocal omnifunc=tern#Complete
  else
      let g:neocomplete#sources#omni#functions.javascript = 'jscomplete#CompleteJS'
      AutocmdFT javascript setlocal omnifunc=jscomplete#CompleteJS
  endif

  "Neocomplete mappings
  inoremap <expr><C-g> neocomplete#undo_completion()
  inoremap <expr><C-s> neocomplete#complete_common_string()
  " <Tab>: completion
  inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  "<C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y> neocomplete#cancel_popup()
  " HACK: This hack needs because of using both vim-smartinput and neocomplete
  " when <CR> is typed.
  "    A user types <CR> ->
  "    smart_close_popup() is called when pumvisible() ->
  "    <Plug>(physical_key_return) hooked by vim-smartinput is used
  imap <expr><CR> (pumvisible() ? neocomplete#smart_close_popup() : "")."\<Plug>(physical_key_return)"
  "
  Autocmd CmdwinEnter * inoremap <silent><buffer><Tab> <C-n>
  Autocmd CmdwinEnter * inoremap <expr><buffer><CR> (pumvisible() ? neocomplete#smart_close_popup() : "")."\<CR>"
  Autocmd CmdwinEnter * inoremap <silent><buffer><expr><C-h> col('.') == 1 ?
                                      \ "\<ESC>:quit\<CR>" : neocomplete#cancel_popup()."\<C-h>"
  Autocmd CmdwinEnter * inoremap <silent><buffer><expr><BS> col('.') == 1 ?
                                      \ "\<ESC>:quit\<CR>" : neocomplete#cancel_popup()."\<BS>"
  " }}}
  " Neocomplcache {{{
  " ----------------------------------------------
elseif count(g:billinux_complete_plugin, 'neocomplcache')

  " AutoComplPop
  let g:acp_enableAtStartup = 0
  let g:neocomplcache_enable_at_startup = 1
  let g:neocomplcache_enable_smart_case = 1
  let g:neocomplcache_enable_underbar_completion = 1
  let g:neocomplcache_min_syntax_length = 3
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
  " Max list
  let g:neocomplcache_max_list = 300
  let g:neocomplcache_max_keyword_width = 20
  " Dictionnaries
  let g:neocomplcache_dictionary_filetype_lists = {
              \ 'default' : '',
              \ 'vimshell' : expand('~/.vimshell/command-history'),
              \ }
  " Delimiter
  if !exists('g:neocomplcache_delimiter_patterns')
    let g:neocomplcache_delimiter_patterns = {}
  endif
  let g:neocomplcache_delimiter_patterns.vim = ['#']
  let g:neocomplcache_delimiter_patterns.cpp = ['::']
  " Include paths
  if !exists('g:neocomplcache_include_paths')
    let g:neocomplcache_include_paths = {}
  endif
  let g:neocomplcache_include_paths.cpp  = '.,/usr/local/include,/usr/local/opt/gcc49/lib/gcc/x86_64-apple-darwin13.1.0/4.9.0/include/c++,/usr/include'
  let g:neocomplcache_include_paths.c    = '.,/usr/include'
  let g:neocomplcache_include_paths.perl = '.,/System/Library/Perl,/Users/rhayasd/Programs'
  let g:neocomplcache_include_paths.ruby = expand('~/.rbenv/versions/2.0.0-p195/lib/ruby/2.0.0')
  " Include patterns
  let g:neocomplcache_include_patterns = { 'cpp' : '^\s*#\s*include', 'ruby' : '^\s*require', 'perl' : '^\s*use', }
  " Include regex
  let g:neocomplcache_include_exprs = {
    \ 'ruby' : "substitute(substitute(v:fname,'::','/','g'),'$','.rb','')"
    \ }
  " Enable omni completion.
  AutocmdFT python     setlocal omnifunc=pythoncomplete#Complete
  AutocmdFT javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  AutocmdFT html       setlocal omnifunc=htmlcomplete#CompleteTags
  AutocmdFT css        setlocal omnifunc=csscomplete#CompleteCss
  AutocmdFT xml        setlocal omnifunc=xmlcomplete#CompleteTags
  AutocmdFT php        setlocal omnifunc=phpcomplete#CompletePHP
  AutocmdFT c          setlocal omnifunc=ccomplete#Complete
  " Enable heavy omni completion.
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif
  " let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.c   = '\%(\.\|->\)\h\w*'
  let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
  " neocomplcache
  let g:neocomplcache_vim_completefuncs = {
    \ 'Unite' : 'unite#complete_source',
    \ 'VimShellExecute' : 'vimshell#vimshell_execute_complete',
    \ 'VimShellInteractive' : 'vimshell#vimshell_execute_complete',
    \ 'VimShellTerminal' : 'vimshell#vimshell_execute_complete',
    \ 'VimShell' : 'vimshell#complete',
    \ 'VimFiler' : 'vimfiler#complete',
    \}
  " ctags
  if executable('/usr/local/bin/ctags')
    let g:neocomplcache_ctags_program = '/usr/local/bin/ctags'
  elseif executable('/usr/bin/ctags')
    let g:neocomplcache_ctags_program = '/usr/bin/ctags'
  endif

  " neocomplcache
  inoremap <expr><C-g> neocomplcache#undo_completion()
  inoremap <expr><C-s> neocomplcache#complete_common_string()
  " <CR>: close popup and save indent.
  " <Tab>: completion
  inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
  "<C-h>, <BS>: close popup and delete backword char.
              " inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
              " inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y> neocomplcache#close_popup()
  " HACK: This hack needs because of using both vim-smartinput and neocomplcache
  " when <CR> is typed.
  "    A user types <CR> ->
  "    smart_close_popup() is called when pumvisible() ->
  "    <Plug>(physical_key_return) hooked by vim-smartinput is used
  imap <expr><CR> (pumvisible() ? neocomplcache#smart_close_popup() : "")."\<Plug>(physical_key_return)"
  " Tab
  Autocmd CmdwinEnter * inoremap <silent><buffer><Tab> <C-n>
  Autocmd CmdwinEnter * inoremap <expr><buffer><CR> (pumvisible() ? neocomplcache#smart_close_popup() : "")."\<CR>"
  Autocmd CmdwinEnter * inoremap <silent><buffer><expr><C-h> col('.') == 1 ?
                                      \ "\<ESC>:quit\<CR>" : neocomplcache#cancel_popup()."\<C-h>"
  Autocmd CmdwinEnter * inoremap <silent><buffer><expr><BS> col('.') == 1 ?
                                      \ "\<ESC>:quit\<CR>" : neocomplcache#cancel_popup()."\<BS>"
  " }}}
  " YouCompleteMe"{{{
  " ----------------------------------------------
  "  Compilation
  "  $>cd $HOME/.cache/neobundle/YouCompleteMe/
  "  git submodule update --init --recursive
  "  $>./install.sh --clang-completer
elseif count(g:billinux_complete_plugin, 'youcompleteme')

  let g:acp_enableAtStartup = 0

  " enable completion from tags
  let g:ycm_collect_identifiers_from_tags_files = 1

  " remap Ultisnips for compatibility for YCM
  let g:UltiSnipsExpandTrigger = '<C-j>'
  let g:UltiSnipsJumpForwardTrigger = '<C-j>'
  let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

  " Haskell post write lint and check with ghcmod
  " $ `cabal install ghcmod` if missing and ensure
  " ~/.cabal/bin is in your $PATH.
  if !executable("ghcmod")
    autocmd BufWritePost *.hs GhcModCheckAndLintAsync
  endif

  " For snippet_complete marker.
  if !exists("g:spf13_no_conceal")
    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif
  endif

  " Disable the neosnippet preview candidate window
  " When enabled, there can be too much visual noise
  " especially when splits are used.
  set completeopt-=preview
"}}}
  " OmniCompletion"{{{
  " ----------------------------------------------
elseif !exists('g:billinux_no_omni_complete')
  " Enable omni-completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

endif
"}}}
"}}}
" Neosnippet "{{{
" ----------------------------------------------
if count(g:billinux_complete_plugin, 'neocomplete') ||
      \ count(g:billinux_complete_plugin, 'neocomplcache')

" Use honza's snippets.
  let g:neosnippet#snippets_directory=s:neobundle_dir.'/vim-snippets/snippets'

  " Enable neosnippet snipmate compatibility mode
  let g:neosnippet#enable_snipmate_compatibility = 1

  imap <expr><C-l> neosnippet#expandable() \|\| neosnippet#jumpable() ?
              \ "\<Plug>(neosnippet_jump_or_expand)" :
              \ "\<C-s>"
  smap <expr><C-l> neosnippet#expandable() \|\| neosnippet#jumpable() ?
              \ "\<Plug>(neosnippet_jump_or_expand)" :
              \ "\<C-s>"
  "
  imap <expr><C-S-l> neosnippet#expandable() \|\| neosnippet#jumpable() ?
              \ "\<Plug>(neosnippet_expand_or_jump)" :
              \ "\<C-s>"
  smap <expr><C-S-l> neosnippet#expandable() \|\| neosnippet#jumpable() ?
              \ "\<Plug>(neosnippet_expand_or_jump)" :
              \ "\<C-s>"
  " C++ & Python
  let g:neosnippet#disable_runtime_snippets = {'cpp' : 1, 'python' : 1, 'd' : 1}

endif

"}}}

"}}}
" My own bundles"{{{
" -----------------------------------------------------------------

"}}}

"}}}

" Lazy loaded"{{{
" =================================================================

" Colorschemes"{{{
" -----------------------------------------------------------------

" Vim-colors-solarized"{{{
if exists('g:colors_name') && g:colors_name == 'solarized'
  " Text is unreadable with background transparency.
  if has('gui_macvim')
    set transparency=0
  endif

  " Highlighted text is unreadable in Terminal.app because it
  " does not support setting of the cursor foreground color.
  if !has('gui_running') && $TERM_PROGRAM == 'Apple_Terminal'
    if &background == 'dark'
     hi Visual term=reverse cterm=reverse ctermfg=10 ctermbg=7
    endif
  endif
endif
"}}}
" Vim-colorschemes"{{{

"}}}

" Xterm-color-table"{{{

"}}}

"}}}
" Plugins"{{{
" -----------------------------------------------------------------

" Nerdtree"{{{

"}}}
" Vim-indent-guides"{{{
" Auto calculate guide colors.
let g:indent_guides_auto_colors = 1

" Use skinny guides.
let g:indent_guides_guide_size = 1

" Indent from level 2.
let g:indent_guides_start_level = 2
"}}}
" Vim-better-whitespace"{{{

"}}}
" Emmet-vim "{{{
let g:user_emmet_mode = 'ivn'
let g:user_emmet_leader_key = '<C-Y>'
let g:use_emmet_complete_tag = 1
let g:user_emmet_settings = { 'lang' : 'fr' }

"}}}
" Tagbar"{{{
nnoremap <silent> <leader>l :TagbarToggle<CR>
"}}}

" Language"{{{
" --------

" Html5"{{{

"}}}
" Vim-mustache-handlebars"{{{

"}}}
" Vim-less"{{{

"}}}
" Vim-css3-syntax"{{{

"}}}
" Vim-stylus"{{{

"}}}
" Vim-haml"{{{

"}}}
" Vim-jade"{{{

"}}}
" Vim-markdown"{{{

"}}}
" Vim-ansible-yaml"{{{

"}}}
" Csv.vim"{{{

"}}}
" Dbext.vim"{{{
" https://mutelight.org/dbext-the-last-sql-client-youll-ever-need
" MySQL
"let g:dbext_default_profile_mysql_local = 'type=MYSQL:user=root:passwd=whatever:dbname=mysql'

" SQLite
"let g:dbext_default_profile_sqlite_for_rails = 'type=SQLITE:dbname=/path/to/my/sqlite.db'

" Microsoft SQL Server
"let g:dbext_default_profile_microsoft_production = 'type=SQLSRV:user=sa:passwd=whatever:host=localhost'

"}}}
" Jedi-vim"{{{

"}}}
" Vim-rails"{{{

"}}}
" Cpp-vim"{{{

"}}}
" Vim-cpp-enhanced-highlight"{{{

"}}}
" Vim-go"{{{
au BufNewFile,BufRead *.go set ft=go
au FileType go nnoremap <buffer><leader>r :GoRun<CR>
au FileType go nnoremap <buffer><C-c>d :GoDef<CR>
"let g:go_disable_autoinstall = 1
"}}}
" Vim-gocode"{{{

"}}}
" Vim-scala"{{{

"}}}
" Txtfmt-The-Vim-Highlighter"{{{

"}}}
" i3-vim-syntax"{{{

"}}}
" Dockerfile.vim"{{{

"}}}
" Vim-blade"{{{

"}}}
" Latex-Box"{{{

"}}}
" Vim-writingsyntax"{{{

"}}}
" Vim-json"{{{

"}}}
" Vim-coffee-script"{{{

" To recompile on write
autocmd BufWritePost *.coffee silent make!
" Folding is disabled by default but can be quickly toggled per-file by hitting zi. To enable folding by default, remove nofoldenable
autocmd BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable

"}}}


" PHP"{{{
" ---

" Php.vim"{{{

"}}}
" Phpfolding.vim"{{{
let g:DisableAutoPHPFolding = 1  " Do not fold automatically
"}}}
" Phpcomplete-extended"{{{

"}}}
" Phpcomplete-extended-laravel"{{{

"}}}
" Pdv"{{{
let g:pdv_template_dir = s:neobundle_dir.'/snippets/phpdoc'
"}}}
" PHP-Indenting-for-vim"{{{

"}}}

"}}}

" Javascript"{{{
" ----------

" Vim-javascript"{{{

"}}}
" Tern_for_vim"{{{

"}}}
" Vim-node"{{{
" customize settings for files inside a Node projects
autocmd User Node if &filetype == "javascript" | setlocal expandtab | endif

" <C-w>f to open the file under the cursor in a new vertical split
autocmd User Node
  \ if &filetype == "javascript" |
  \   nmap <buffer> <C-w>f <Plug>NodeVSplitGotoFile |
  \   nmap <buffer> <C-w><C-f> <Plug>NodeVSplitGotoFile |
  \ endif

"}}}


"}}}

"}}}
" Commands"{{{
" --------

" Vimshell"{{{

"}}}
" Vimfiler"{{{

"}}}
" Vinarise.vim"{{{
let g:vinarise_enable_auto_detect = 1
"}}}
" Vim-fugitive"{{{

"}}}
" Gitv"{{{
let g:Gitv_DoNotMapCtrlKey = 1  " Do not map ctrl keys
nnoremap <silent> <leader>gl :Gitv --all<CR>
"}}}
" Gundo.vim"{{{

"}}}
" Smartpairs.vim"{{{

"}}}
" Vim-colorpicker"{{{

"}}}
" Vim-smalls"{{{

"}}}
" Previm"{{{
let g:previm_enable_realtime = 0
"}}}
" Open-browser.vim"{{{
let g:openbrowser_no_default_menus = 1
"}}}

"}}}
" Interface"{{{
" ---------

" Matchit.zip"{{{

"}}}
" Vim-session"{{{
let g:session_directory = $CACHE_VIM.'/session'
let g:session_default_overwrite = 1
let g:session_autosave = 'no'
let g:session_autoload = 'no'
let g:session_persist_colors = 0
let g:session_menu = 0

"}}}

"}}}


" Unite"{{{
" -----

" Unite.vim"{{{

"}}}

" Unite sources
" Unite-build"{{{

"}}}
" Unite-colorscheme"{{{

"}}}
" Neossh.vim"{{{

"}}}
" Unite-outline"{{{

"}}}
" Unite-quickfix"{{{

"}}}
" Unite-tag"{{{

"}}}
" Unite-pull-request"{{{

"}}}
" Unite-stackoverflow.vim"{{{

"}}}

"}}}
" Operators"{{{
" ---------

" Vim-operator-user"{{{

"}}}
" Vim-operator-surround"{{{

"}}}

"}}}
" Textobjs"{{{
" --------

" Vim-textobj-user"{{{

"}}}
" Vim-textobj-multiblock"{{{

"}}}
" Wildfire"{{{

"}}}

"}}}

"}}}

"}}}

"}}}

" LOCAL:"{{{

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

NeoBundleClearCache

"}}}


" Vim: set ft=vim sw=2 ts=2 sts=2 ff=unix fenc=utf-8:
