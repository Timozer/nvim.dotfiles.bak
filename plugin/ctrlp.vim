if !has('nvim-0.5.1')
  echoerr "ctrlp requires at least nvim-0.5.1."
  finish
end

if exists('g:ctrlp_loaded')
  finish
endif
let g:ctrlp_loaded = 1

" Telescope Commands with complete
" command! -nargs=* -range -complete=custom,s:telescope_complete Telescope    lua require('telescope.command').load_command(<line1>, <line2>, <count>, unpack({<f-args>}))
command! -nargs=* -range CtrlP lua require('core.ctrlp').load_command(<line1>, <line2>, <count>, unpack({<f-args>}))
