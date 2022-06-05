if exists('g:gcmp_loaded')

    finish
endif
let g:gcmp_loaded = 1

function! s:panic(ch, data, ...) abort
    echom a:data
endfunction

function! s:Start(host) abort
    return jobstart(['/home/zhenyu/.config/nvim/nvmgo/gcmp/gcmp', 'run'], {
        \ 'rpc': v:true, 
        \ 'on_stderr': function('s:panic')
        \ })
endfunction

call remote#host#Register('gcmp', 'x', function('s:Start'))
call remote#host#RegisterPlugin('gcmp', '0', [
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
