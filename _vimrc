" Vim with all enhancements
source $VIMRUNTIME/vimrc_example.vim

" Remap a few keys for Windows behavior
source $VIMRUNTIME/mswin.vim

" Mouse behavior (the Windows way)
behave mswin

" Use the internal diff if available.
" Otherwise use the special 'diffexpr' for Windows.
if &diffopt !~# 'internal'
  set diffexpr=MyDiff()
endif
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg1 = substitute(arg1, '!', '\!', 'g')
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg2 = substitute(arg2, '!', '\!', 'g')
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let arg3 = substitute(arg3, '!', '\!', 'g')
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      if empty(&shellxquote)
        let l:shxq_sav = ''
        set shellxquote&
      endif
      let cmd = '"' . $VIMRUNTIME . '\diff"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  let cmd = substitute(cmd, '!', '\!', 'g')
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  if exists('l:shxq_sav')
    let &shellxquote=l:shxq_sav
  endif
endfunction

"------------------------------------------------------------------------------
"  < 判断操作系统是否是 Windows 还是 Linux >
"------------------------------------------------------------------------------
if(has("win32") || has("win64") || has("win95") || has("win16"))
    let g:iswindows = 1
else
    let g:iswindows = 0
endif


"------------------------------------------------------------------------------
"  < 判断是终端还是 Gvim >
"------------------------------------------------------------------------------
if has("gui_running")
    let g:isGUI = 1
else
    let g:isGUI = 0
endif


"------------------------------------------------------------------------------
"  < 编码字符集配置 >
"------------------------------------------------------------------------------
"注：使用utf-8格式后，软件与程序源码、文件路径不能有中文，否则报错
set encoding=utf-8                                    "gvim内部编码
set fileencoding=utf-8                                "当前文件编码
set fileencodings=utf-8,GBK,gbk,gb18030,gb2312,cp936,ucs-bom,latin-1,latin1 "支持打开文件的编码
if (g:iswindows && g:isGUI)
    "解决菜单乱码
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim

    "解决consle输出乱码
    language messages zh_CN.utf-8
endif

"------------------------------------------------------------------------------
"  < 编写文件时的配置及快捷键新映射 >
"------------------------------------------------------------------------------
"------------------------------------------------------------------------------
"配置

set nocompatible                                      "关闭 Vi 兼容模式
filetype on                                           "启用文件类型侦测
filetype plugin on                                    "针对不同的文件类型加载对应的插件
filetype plugin indent on                             "启用缩进
set smartindent                                       "启用智能对齐方式
set expandtab                                         "将tab键转换为空格
set tabstop=4                                         "设置tab键的宽度
set shiftwidth=4                                      "换行时自动缩进4个空格
"set backspace=2                                       "设置退格键可用
set smarttab                                          "指定按一次backspace就删除4个空格

"折行
set foldenable                                        "启用折叠
set foldmethod=indent                                 "indent 折叠方式
"set foldmethod=marker                                "marker 折叠方式
au FileType text,markdown,html,xml set wrap
" 折行时，以单词为界，以免切断单词
set linebreak
" 折行后的后续行，使用与第一行相同的缩进
set breakindent

"用空格键来开关折叠
"nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

"当文件在外部被修改，自动更新该文件
set autoread

" 切换缓存时不用保存 即允许隐藏被修改过的buffer
set hidden

"搜索模式里忽略大小写
set ignorecase
"如果搜索模式包含大写字符，不使用 'ignorecase' 选项，只有在输入搜索模式并且打开 'ignorecase' 选项时才会使用
set smartcase
"在输入要搜索的文字时，取消实时匹配
"set noincsearch


"每行超过80个的字符用下划线标示
" au BufWinEnter * let w:m2=matchadd('Underlined', '\%>' . 120 . 'v.\+', -1)
"高亮字符，让其不受100列限制
":highlight Mygroup ctermbg=red ctermfg=white guibg=red guifg=white
":match Mygroup '\%101v.*'
"针对C/C++/Python/Vim 做 80列限制
au FileType c,cpp,python,vim set textwidth=80
"一般如果设定了宽度限制，最好能画一条竖线以警示。
"设置 colorcolumn 即可。甚至可以设置为多列，比如 "81,101"。
set colorcolumn=81

"500秒没敲键盘就退出插入模式
"au CursorHoldI * stopinsert
set ut=200

"高亮行尾空格
" See [http://vim.wikia.com/wiki/Highlight_unwanted_spaces]
" - highlight trailing whitespace in red
" - have this highlighting not appear whilst you are typing in insert mode
" - have the highlighting of whitespace apply when you open new buffers
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches() " for performance

" 这个函数通过替换命令删除行尾空格 等同于 <leader>cs 命令
func! DeleteTrailingWS()
    exec "normal mz"
    %s/\s\+$//ge
    exec "normal `z"
endfunc

" 保存时自动删除行尾空格
au BufWrite * :call DeleteTrailingWS()

"------------------------------------------------------------------------------
"快捷键映射

let mapleader = "," "设置leader

"常规模式下输入 cs 清除行尾空格以及只有空格的行
nmap <leader>cs :%s/\s\+$//g<cr>:noh<cr>
"也可以写成下边的方式
" map <leader>cs :call DeleteTrailingWS()<CR>

"常规模式下输入 cm 清除行尾 ^M 符号
nmap <leader>cm :%s/\r$//g<cr>:noh<cr>

" Ctrl + K/J/H/L 插入模式下光标向上/下/左/右移动
imap <c-k> <Up>
imap <c-j> <Down>
imap <c-h> <Left>
imap <c-l> <Right>

"切换窗口的键盘映射
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" jj  保存文件并留在插入模式 [插入模式]
" jk  返回Normal模式 [插入模式]
imap kk <ESC>l
"imap jj <ESC>:w<CR>li
imap <leader>a <ESC>l

"快速保存
nmap <leader>w :w!<CR>
nmap <leader>q :q<CR>

"map <C-t> :tabnew<CR> 也就是跟标签有关的
map <leader>te :tabedit<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove

"粘贴并删除紧挨着后边的单词,  该粘贴必须放在要删除单词的前边
nmap <leader>p  Pldebyw

"粘贴并删除紧挨着后边的单词,  该粘贴必须放在要删除单词的前边
map <leader>y  "+y


" 打开配置文件
nmap <leader>ev :tabe $VIM/_vimrc<CR>
" 重新加载配置文件
nmap <leader>sv :so $VIM/_vimrc<CR>

" 文件扩展名定义文件类型
"if (has("autocmd"))
    autocmd BufRead,BufNewFile *.ec  set filetype=c
    autocmd BufRead,BufNewFile *.sqc set filetype=c
"endif

"多tab之间的切换， 快捷键是alt+1-9数字
:nn <M-1> 1gt
:nn <M-2> 2gt
:nn <M-3> 3gt
:nn <M-4> 4gt
:nn <M-5> 5gt
:nn <M-6> 6gt
:nn <M-7> 7gt
:nn <M-8> 8gt
:nn <M-9> 9gt
:nn <M-0> :tablast<CR>


"在终端terminal下，跳出输入模式
:tnoremap <silent><esc> <C-\><C-N>

"------------------------------------------------------------------------------
"  < 界面/显示配置 >
"------------------------------------------------------------------------------
set number                                            "显示行号
set relativenumber                                    "相对行号
" 相对行号: 行号变成相对，可以用 nj/nk 进行跳转
set relativenumber number
au FocusLost * :set norelativenumber number
au FocusGained * :set relativenumber
" 插入模式下用绝对行号, 普通模式下用相对
autocmd InsertEnter * :set norelativenumber number
autocmd InsertLeave * :set relativenumber
" 插入模式下用绝对行号, 普通模式下用相对
autocmd InsertEnter * :set norelativenumber number
autocmd InsertLeave * :set relativenumber

set laststatus=2                                      "开启状态栏信息
set cmdheight=2                                       "设置命令行的高度为2，默认为1
set cursorline                                        "突出显示当前行
"set guifont=DejaVu_Sans_Mono:h10                     "设置字体:字号（字体名称空格用下划线代替）
set guifont=Monaco:h10                                "    字体 && 字号
set nowrap                                            "设置不自动换行
set shortmess=atI                                     "去掉欢迎界面
"au GUIEnter * simalt ~x                              "窗口启动时自动最大化
winpos 100 20                                         "指定窗口出现的位置，坐标原点在屏幕左上角
set lines=45 columns=120                              "指定窗口大小，lines为高度，columns为宽度

"设置代码配色方案
if g:isGUI
    syntax enable
    set   background=dark   "light/dark
    colorscheme  desert "Gvim配色方案   对眼睛好的主题:solarized/freya/desert/
                        "以前用过的:Tomorrow-Night-Eighties zellner/corporation/candy
else
    colorscheme darkburn                              "终端配色方案
endif

""个性化状栏（增加了文件编码的显示，去掉注释即可）
"set statusline=%F%m%r%h%w\ %=%{\"\".(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\").\"\"}\ \|\ %l,%v\ \|\ %p%%

"网上download下来 的带有路径--->  显示当前正在编辑的文件名所在的绝对路径以及必要的冗余信息
"highlight StatusLine cterm=bold ctermfg=yellow ctermbg=blue
" 获取当前路径，将$HOME转化为~
" function! CurDir()
    " let curdir = substitute(getcwd(), $HOME, "~", "g")
    " return curdir
" endfunction
" set statusline=[%n]\ %f%m%r%h\ \|\ \ pwd:\ %{CurDir()}\ \ \|%=\|\ %l,%c\ %p%%\ \|\ ascii=%b,hex=%b%{((&fenc==\"\")?\"\":\"\ \|\ \".&fenc)}\ \|\ %{$USER}\ @\ %{hostname()}\

" 设置状态栏主题风格
"let g:Powerline_colorscheme='solarized256'

"显示/隐藏菜单栏、工具栏、滚动条，可用 Ctrl + F11 切换
if g:isGUI
    "隐藏菜单栏m, 工具栏T，滚动条r， 左边的滚动条L 具体可以 :help guioptions
    set guioptions-=m
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L

    "显示
    "set guioptions+=m
    "set guioptions+=T
    "set guioptions+=r
    "set guioptions+=L
endif
"使光标呈十字亮
set cursorline
set cursorcolumn
"禁止光标闪烁
set gcr=a:block-blinkon0


"------------------------------------------------------------------------------
"  < 其它配置 >
"------------------------------------------------------------------------------
set writebackup                             "保存文件前建立备份，保存成功后删除该备份
set nobackup                                "设置无备份文件
set noswapfile                              "设置无临时文件
set noundofile                              "设置无undofile和备份文件
set vb t_vb=                                "关闭提示音

"tags配置参考 Vim8下C/C++开发环境搭建[http://www.skywind.me/blog/archives/2084]
set tags=./.tags;,.tags

" 不同平台，设置不同的行尾符，即 EOL
" 注意：在 Mac 平台，也是 unix 优先；自 OS X 始，行尾符与 Unix 一致
"      都是 `\n` 而不是 `\r`
"if has("win32")
""    set fileformats=dos,unix,mac
"else
""    set fileformats=unix,mac,dos
"endif



"==============================================================================
"=============================我是分割线=======================================
"整理可以参考文档：
"   自己以前的配置文件
"   超级强大的vim配置(vimplus) -- 简书 [https://www.jianshu.com/p/75cde8a80fd7]
"   如何优雅的使用 Vim（一）：基本配置 - 止于至善 - SegmentFault 思否 -- [https://segmentfault.com/a/1190000014552112]
"   如何优雅的使用 Vim（二）：插件介绍 - 止于至善 - SegmentFault 思否 -- [https://segmentfault.com/a/1190000014560645]
"
"=============================我是分割线=======================================
"==============================================================================


"==============================================================================
"  < 插件管理 >
"  采用vim-plug, "* 开头的是采用的
"  vim-plug的安装参考:
"       windows下vim/gvim怎么安装使用vim-plug_百度经验 [https://jingyan.baidu.com/article/7082dc1cddd0a3e40a89bdf2.html]
"  Plug options
"       Option	Description
"       branch/tag/commit	Branch/tag/commit of the repository to use
"       rtp	Subdirectory that contains Vim plugin
"       dir	Custom directory for the plugin
"       as	Use different name for the plugin
"       do	Post-update hook (string or funcref)
"       on	On-demand loading: Commands or <Plug>-mappings
"       for	On-demand loading: File types
"       frozen	Do not update unless explicitly specified
"==============================================================================


" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('$VIM/vimfiles/plugged')

"快速对齐
" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
"Plug 'junegunn/vim-easy-align'

" 资源管理器 采用nerdtree
Plug 'scrooloose/nerdtree'

" 配色方案
Plug 'morhetz/gruvbox'

" 状态栏
Plug 'vim-airline/vim-airline'

" 缩进线
Plug 'Yggdroot/indentLine'

" 代码对齐
Plug 'godlygeek/tabular'

" 代码注释
Plug 'scrooloose/nerdcommenter'

" tags标签索引管理
Plug 'ludovicchabant/vim-gutentags'

" 修改比较插件
"Plug 'mhinz/vim-signify'

" 文本处理
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'

" 模糊查询
Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }

" 代码检查 异步
Plug 'w0rp/ale'

" 代码补全 采用deoplete.nvim
" 针对vim8来说：
" roxma/nvim-yarp需要以下前置条件
"   has('python3')
"   For Vim 8:
"   roxma/vim-hug-neovim-rpc
"   g:python3_host_prog pointed to your python3 executable, or echo exepath('python3') is not empty.
"   pynvim (pip3 install pynvim)

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" 函数参数提示
Plug 'Shougo/echodoc.vim'


" 定义了一系列方括号开头的快捷键
Plug 'tpope/vim-unimpaired'

" 语法高亮
"针对c/c++的
Plug 'octol/vim-cpp-enhanced-highlight'
"针对python
Plug 'hdima/python-syntax'

" 自动增加、替换配对符的插件
Plug 'tpope/vim-surround'

" 自动补全括号引号等
Plug 'Raimondi/delimitMate'

" 彩虹括号
"Plug 'luochen1990/rainbow'

"* vim中文文档
Plug 'yianwillis/vimcdoc'

"* 代码格式化
Plug 'Chiel92/vim-autoformat'

"* 函数列表 先用tagbar
Plug 'majutsushi/tagbar'


" Initialize plugin system
call plug#end()


"------------------------------------------------
"* 文件资源管理器 采用nerdtree

" vim启动时默认启动nerdtree
autocmd vimenter * NERDTree
" 快捷键打开nerdtree
map <F3> :NERDTreeToggle<CR>
" 当打开 NERDTree 窗口时，自动显示 Bookmarks
let NERDTreeShowBookmarks=1

"------------------------------------------------
"* 配色方案
"Plug 'ayu-theme/ayu-vim'
"Plug 'drewtempelmeyer/palenight.vim' " 基于 Onedark，效果差不多
"Plug 'joshdick/onedark.vim' " Atom Onedark 的复刻
"* Plug 'morhetz/gruvbox'


"------------------------------------------------
"* 状态栏  采用 powerline 的轻量版airline
"* Plug 'vim-airline/vim-airline'

" 允许 airline 在顶部显示 Buffer 列表
let g:airline#extensions#tabline#enabled=1

" 显示 buffer 编号，方便切换
let g:airline#extensions#tabline#buffer_nr_show=1

" buffer_idx_mode允许实用<leade>1-9选择对应的tab，<leade>-|+为前后tab
" 改属性值为1 <leade>1-9
" 改属性值为2 <leade>1-99
let g:airline#extensions#tabline#buffer_idx_mode = 1

" formatter
"let g:airline#extensions#tabline#formatter = 'default'

" 主题，因为 gruvbox 对 airline 的支持不错，暂时就不需要了。
" Plug 'vim-airline/vim-airline-themes'


"------------------------------------------------
"* 缩进标线
"* Plug 'Yggdroot/indentLine'
let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 0
let g:indentLine_char = '|'

"------------------------------------------------
"* 代码对齐 目前使用tabular
"* Plug 'godlygeek/tabular'


"------------------------------------------------
"* 代码注释 目前使用NERD Commenter
"  NERD Commenter插件常用快捷键在Normal或者Visual 模式下： <leader>为,
"     ,ca在可选的注释方式之间切换，比如C/C++ 的块注释/* */和行注释//
"     ,cc注释当前行
"     ,c<space> 切换注释/非注释状态
"     ,cs 以”性感”的方式注释
"     ,cA 在当前行尾添加注释符，并进入Insert模式
"     ,cu 取消注释
"     ,c$ 从光标开始到行尾注释  ，这个要说说因为c$也是从光标到行尾的快捷键，这个按过逗号（，）要快一点按c$
"     2,cc 光标以下count行添加注释
"     2,cu 光标以下count行取消注释
"     2,cm:光标以下count行添加块注释(2,cm)
"     Normal模式下，几乎所有命令前面都可以指定行数
"     Visual模式下执行命令，会对选中的特定区块进行注释/反注释

"Plug 'scrooloose/nerdcommenter'

"BEGIN 以下为Nerd Commenter的配置 2019-4-5
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

"END   以下为Nerd Commenter的配置


"------------------------------------------------
"* tags标签管理
"* Plug 'ludovicchabant/vim-gutentags'
"变量 gutentags_project_root 是vim-gutentags提供的用于搜索工程目录的标志，gutentags插件启动后，会从文件当前路径递归往上查找 gutentags_project_root 中 \
"   指定的文件或目录名，直到第一次找到对应目标文件或目录名停止。若没有找到 gutentags_project_root 变量指定的文件或目录名，则gutentags不会生成tag文件。
"变量 gutentags_ctags_tagfile 和 gutentags_cache_dir 分别用于告诉ctags要使用的tag文件目录和tag文件名后缀，tag文件名的生成规则默认是根据生成tag文件的 \
"   工程绝对路径按 - 分割而成。
"变量 gutentags_ctags_extra_args 用于配置ctags生成tag标签的参数，具体参数含义可参考文章ctags参数介绍

" gutentags搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归 "
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']

" 所生成的数据文件的名称 "
let g:gutentags_ctags_tagfile = '.tags'

" 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录 "
let s:vim_tags = expand('~/.cache/tags_vimold')
let g:gutentags_cache_dir = s:vim_tags
" 检测 ~/.cache/tags 不存在就新建 "
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" 配置 ctags 的参数 "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
let g:gutentags_ctags_extra_args += ['--langmap=c:+.ec+.sqc+.eh']

"------------------------------------------------
"* cscope标签管理
"用Cscope自己的话说 - "你可以把它当做是超过频的ctags"
function Do_CsTag()
    if(executable("cscope") && has("cscope") )
        if(has('win32'))
            silent! execute "!dir /b /s *.c,*.cpp,*.h,*.java,*.cs,*.sqc,*.eh, *.ec > cscope.files"
        else
            silent! execute "!find . -name "*.h" -o -name "*.c" -o -name "*.cpp" -o -name "*.m" -o -name "*.mm" -o -name "*.java" -o -name "*.py" > cscope.files"
        endif
        silent! execute "!cscope -Rbq"
        if filereadable("cscope.out")
            execute "cs add cscope.out"
        endif
    endif
endf
function Up_CsTag()
    if(executable("cscope") && has("cscope") )
        if(has('win32'))
            execute "cs kill cscope.out"
            silent! execute "!dir /b /s *.c,*.cpp,*.h,*.java,*.cs,*.sqc,*.eh, *.ec > cscope.files"
            " execute !del cscope.out
        else
            silent! execute "!find . -name "*.h" -o -name "*.c" -o -name "*.cpp" -o -name "*.m" -o -name "*.mm" -o -name "*.java" -o -name "*.py" > cscope.files"
        endif
        silent! execute "!cscope -Rbq -i cscope.files"
        " silent! execute !cs reset
        if filereadable("cscope.out")
            execute "cs add cscope.out"
        endif
    endif
endf
map <F12> :call Up_CsTag()<CR>

if has("cscope")
    "设定可以使用 quickfix 窗口来查看 cscope 结果
    set cscopequickfix=s-,c-,d-,i-,t-,e-,a-
    "使支持用 Ctrl+]  和 Ctrl+t 快捷键在代码间跳转
    set cscopetag
    "如果你想反向搜索顺序设置为1
    set csto=0
    "在当前目录中添加任何数据库
    if filereadable("cscope.out")
        cs add cscope.out
    "否则添加数据库环境中所指出的
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set cscopeverbose
    "快捷键设置
    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>
endif


"------------------------------------------------
"* 修改比较插件  显示文档的修改、新增、删除等的标识， 类比svn等vcs的差异性文档
"* Plug 'mhinz/vim-signify'
" 插件支持Supports git, mercurial, darcs, bazaar, subversion, cvs, rcs, fossil, accurev, perforce, tfs.


"------------------------------------------------
"* 文本对象处理类组件
"组件列表如下：
"     'kana/vim-textobj-user'
"     'kana/vim-textobj-indent'
"     'kana/vim-textobj-syntax'
"     'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
"     'sgur/vim-textobj-parameter'
"它新定义的文本对象主要有：
"     i, 和 a, ：参数对象，写代码一半在修改，现在可以用 di, / ci, 一次性删除/改写当前参数
"     ii 和 ai ：缩进对象，同一个缩进层次的代码，可以用 vii 选中，dii / cii 删除或改写
"     if 和 af ：函数对象，可以用 vif / dif / cif 来选中/删除/改写函数的内容

"------------------------------------------------
"* 用来管理函数列表及文件搜索, 安装方式按照官方的建议来做的
"* Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
" Vim 的 grep 插件`Leaderf rg`：grep 和模糊匹配的完美结合 [https://ruby-china.org/topics/38001]

"let g:Lf_ShortcutF = '<c-p>' "用默认值<leader>f 用来搜索文件
"let g:Lf_ShortcutB = '<m-n>' "用默认值<leader>b 用来搜索缓存
noremap <m-n> :LeaderfMru<cr>
noremap <m-f> :LeaderfFunction!<cr>
noremap <m-t> :LeaderfTag<cr>
noremap <m-r> :LeaderfRgInteractive<cr>
noremap <m-l> :LeaderfRgRecall<cr>
"打开最近使用的文件
noremap <leader>r :LeaderfMru<cr>

let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}
"设置搜索时排除的文件夹和文件类型
let g:Lf_WildIgnore = {
        \ 'dir': ['.svn','.git','.hg'],
        \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so', 'cscope.out', 'cscope.file']
        \}
"设置搜索MUR文件时排除的文件夹和文件类型
let g:Lf_MruWildIgnore = {
        \ 'dir': ['.svn','.git','.hg'],
        \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so', 'cscope.out', 'cscope.file']
        \}
"记录最后一次的搜索结果，默认是0
let g:Lf_RememberLastSearch = 1

"针对leaderf的ripgrep的快捷键
" search word under cursor, the pattern is treated as regex, and enter normal mode directly
noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>
" search word under cursor, the pattern is treated as regex,
" append the result to previous search results.
noremap <C-G> :<C-U><C-R>=printf("Leaderf! rg --append -e %s ", expand("<cword>"))<CR>
" search word under cursor literally only in current buffer
noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg -F --current-buffer -e %s ", expand("<cword>"))<CR>
" search visually selected text literally, don't quit LeaderF after accepting an entry
xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>
" recall last search. If the result window is closed, reopen it.
noremap go :<C-U>Leaderf! rg --stayOpen --recall<CR>

"------------------------------------------------
"* 代码检测  采用ale 因其是异步调用
"* Plug 'w0rp/ale'



"------------------------------------------------
"* 语义补全 采用Shougo/deoplete, 安装方式按照官方的建议来的
" 该插件需要python3支持， 其他需求参考官方要求
" if has('nvim')
"   Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"   Plug 'Shougo/deoplete.nvim'
"   Plug 'roxma/nvim-yarp'
"   Plug 'roxma/vim-hug-neovim-rpc'
" endif
let g:deoplete#enable_at_startup = 1

"roxma/vim-yarp需要的前置条件配置
"g:python3_host_prog pointed to your python3 executable, or echo exepath('python3') is not empty.
"pynvim (pip3 install pynvim)
let g:python3_host_prog = 'D:\Program Files\Python\Python37\python.exe'


"------------------------------------------------
"* 函数参数提示
"* Plug 'Shougo/echodoc.vim'
"The command line is used to display echodoc text. This means that you will either need to set noshowmode or set cmdheight=2.
"Otherwise, the -- INSERT -- mode text will overwrite echodoc's text.
"默认快捷键 <c-y>
set noshowmode


"------------------------------------------------
" 快捷键定义插件 unimpaired 插件帮你定义了一系列方括号开头的快捷键
"* Plug 'tpope/vim-unimpaired'


"------------------------------------------------
"* 语法高亮
"针对c/c++的
"* Plug 'octol/vim-cpp-enhanced-highlight'
"针对python
"* Plug 'hdima/python-syntax'
let python_highlight_all = 1

"cpp-enhanced-highlight
"高亮类，成员函数，标准库和模板
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
"文件较大时使用下面的设置高亮模板速度较快，但会有一些小错误
let g:cpp_experimental_template_highlight = 1


"------------------------------------------------
"* vim-surround 自动增加、替换配对符的插件
"  简介参考文章: https://blog.csdn.net/liao20081228/article/details/80347684
"* Plug 'tpope/vim-surround'

"------------------------------------------------
"* Raimondi/delimitMate 自动补全括号引号等
"* Plug 'Raimondi/delimitMate'

"------------------------------------------------
"  彩虹括号  辅助类 给不同层次的括号添加不同的颜色  据说和Cmake有冲突 没有用过Cmake
"  g:rainbow_conf采用的是彩虹括号官方给的设置，各参数说明如下
"      'guifgs': GUI界面的括号颜色(将按顺序循环使用)
"      'ctermfgs': 终端下的括号颜色(同上,插件将根据环境进行选择)
"      'operators': 描述你希望哪些运算符跟着与它同级的括号一起高亮(注意：留意需要转义的特殊字符，更多样例见这里, 你也可以读vim帮助 :syn-pattern)
"      'parentheses': 描述哪些模式将被当作括号处理,每一组括号由两个vim正则表达式描述
"      'separately': 针对文件类型(由&ft决定)作不同的配置,未被单独设置的文件类型使用*下的配置,值为0表示仅对该类型禁用插件,值为"default"表示使用针对该类型的默认兼容配置 (注意, 默认兼容配置可能随着该插件版本的更新而改变, 如果你不希望它改变, 那么你应该将它拷贝一份放到你的vimrc文件里).
"* Plug 'luochen1990/rainbow'
" let g:rainbow_conf = {
" \	'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
" \	'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
" \	'operators': '_,_',
" \	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
" \	'separately': {
" \		'*': {},
" \		'tex': {
" \			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
" \		},
" \		'lisp': {
" \			'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
" \		},
" \		'vim': {
" \			'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
" \		},
" \		'html': {
" \			'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
" \		},
" \		'css': 0,
" \	}
" \}



"------------------------------------------------
"* vim中文文档
"* Plug 'yianwillis/vimcdoc'


"------------------------------------------------
"* 代码格式化
"Plug 'Chiel92/vim-autoformat'


"------------------------------------------------
"* 函数列表 先用tagbar
"Plug 'majutsushi/tagbar'
"tagbar
"F9触发，设置宽度为30
let g:tagbar_width = 30
nmap tl :TagbarToggle<CR>
"开启自动预览(随着光标在标签上的移动，顶部会出现一个实时的预览窗口) -- 使用时卡
"let g:tagbar_autopreview = 1
"关闭排序,即按标签本身在文件中的位置排序
let g:tagbar_sort = 0

