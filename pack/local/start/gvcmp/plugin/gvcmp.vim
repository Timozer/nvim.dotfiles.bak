
if exists('g:gvcmp_loaded')
    finish
endif
let g:gvcmp_loaded = 1

function! s:panic(ch, data, ...) abort
    echom a:data
endfunction

function! s:StartGVCmp(host) abort
    return jobstart(['/home/zhenyu/.config/nvim/pack/local/start/gvcmp/gvcmp', 'run'], {
        \ 'rpc': v:true, 
        \ 'on_stderr': function('s:panic')
        \ })
endfunction

call remote#host#Register('gvcmp', 'x', function('s:StartGVCmp'))
call remote#host#RegisterPlugin('gvcmp', '0', [
\ {'type': 'autocmd', 'name': 'BufAdd', 'sync': 0, 'opts': {'eval': '{''Cwd'': getcwd()}', 'group': 'ExmplNvGoClientGrp', 'pattern': '*'}},
\ {'type': 'autocmd', 'name': 'BufEnter', 'sync': 0, 'opts': {'group': 'GVCmp', 'pattern': '*'}},
\ {'type': 'autocmd', 'name': 'InsertEnter', 'sync': 0, 'opts': {'group': 'GVCmp', 'pattern': '*'}},
\ {'type': 'autocmd', 'name': 'VimEnter', 'sync': 0, 'opts': {'group': 'GVCmp', 'pattern': '*'}},
\ {'type': 'command', 'name': 'CompleteThis', 'sync': 0, 'opts': {'complete': 'customlist,CompleteThisC', 'nargs': '?'}},
\ {'type': 'command', 'name': 'ExCmd', 'sync': 0, 'opts': {'bang': '', 'eval': '[getcwd(),bufname()]', 'nargs': '?'}},
\ {'type': 'function', 'name': 'CompleteThisC', 'sync': 1, 'opts': {}},
\ {'type': 'function', 'name': 'GetVV', 'sync': 1, 'opts': {}},
\ {'type': 'function', 'name': 'ShowFirst', 'sync': 1, 'opts': {}},
\ {'type': 'function', 'name': 'ShowThings', 'sync': 1, 'opts': {'eval': '[getcwd(),argc()]'}},
\ {'type': 'function', 'name': 'Upper', 'sync': 1, 'opts': {}},
\ {'type': 'function', 'name': 'UpperCwd', 'sync': 1, 'opts': {'eval': 'getcwd()'}},
\ ])
