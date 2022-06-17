vim.cmd [[
try
  syntax enable
  set background=dark
  let ayucolor="dark"
  colorscheme ayu
  " let g:neosolorized_termtrans=1
  " runtime ../../colors/NeoSolarized.vim
  " colorscheme NeoSolarized
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
