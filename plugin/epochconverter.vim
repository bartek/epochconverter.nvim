if exists('g:epochConverter_loaded') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

hi TypeAnnot guifg=#7c6f64

command! EnableEpochConverter lua require'epochconverter'.enable()
command! DisableEpochConverter lua require'epochconverter'.disable()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:epochConverter_loaded = 1
