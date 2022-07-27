vim.cmd [[
try
  syntax enable
  set background=dark
  " let ayucolor="mirage"
  " colorscheme dracula
  let g:neosolarized_termtrans=1
  runtime $HOME/.config/nvim/colors/NeoSolarized.vim
  colorscheme NeoSolarized
  highlight Visual cterm=NONE ctermbg=236 ctermfg=NONE guibg=Grey40
  highlight LineNr cterm=none ctermfg=240 guifg=2b506e guibg=#000000
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
