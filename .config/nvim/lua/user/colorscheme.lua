vim.cmd [[
try
  " let ayocolor="dark"
  colorscheme neosolarized
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
