
if exists('g:gpm_loaded')
    finish
endif
let g:gpm_loaded = 1

function! s:panic(ch, data, ...) abort
    echom a:data
endfunction

function! s:Start(host) abort
    return jobstart(['/home/zhenyu/.config/nvim/gpm/gpm', 'run'], {
        \ 'rpc': v:true, 
        \ 'on_stderr': function('s:panic')
        \ })
endfunction

call remote#host#Register('gpm', 'x', function('s:Start'))
call remote#host#RegisterPlugin('gpm', '0', [
\ {'type': 'command', 'name': 'GpmStatus', 'sync': 0, 'opts': {'nargs': '0'}},
\ {'type': 'command', 'name': 'GpmSync', 'sync': 0, 'opts': {'nargs': '0'}},
\ ])
