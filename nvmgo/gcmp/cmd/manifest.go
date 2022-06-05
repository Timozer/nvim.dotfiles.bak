package cmd

import (
	"fmt"
	"io/ioutil"
	"nvmgo/lib"

	"gcmp/handler"

	"github.com/neovim/go-client/nvim/plugin"
)

type Manifest struct {
	Host string `short:"H" required:"" help:"host"`
	File string `short:"f" help:"plugin/gcmp.vim path"`
}

func (m *Manifest) Run() error {
	logger := lib.NewLogger("logs/gcmp.log")

	p := plugin.New(nil)

	var err error
	if err = handler.Register(p); err != nil {
		logger.Error().Err(err).Msg("RegisterHandlers")
		return err
	}

	manifest := `
if exists('g:gvcmp_loaded')
    finish
endif
let g:gvcmp_loaded = 1

function! s:panic(ch, data, ...) abort
    echom a:data
endfunction

function! s:StartGVCmp(host) abort
`
	manifest += "    return jobstart(['/home/zhenyu/.config/nvim/gvcmp/gvcmp', 'run'], {"
	manifest += `
        \ 'rpc': v:true, 
        \ 'on_stderr': function('s:panic')
        \ })
endfunction

`
	manifest += fmt.Sprintf("call remote#host#Register('%s', 'x', function('s:StartGVCmp'))\n", m.Host)
	manifest += string(p.Manifest(m.Host))

	if len(m.File) > 0 {
		err = ioutil.WriteFile(m.File, []byte(manifest), 0644)
	} else {
		fmt.Printf("%s\n", manifest)
	}
	return err
}
