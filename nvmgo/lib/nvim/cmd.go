package nvim

import (
	"fmt"
	"io/ioutil"
	"nvmgo/lib"

	"github.com/neovim/go-client/nvim/plugin"
)

type CmdContext struct {
	HandlerRegister func(*plugin.Plugin) error
}

type Manifest struct {
	Host string `short:"H" required:"" help:"host"`
	File string `short:"f" help:"manifest output file path"`
}

func (m *Manifest) Run(ctx *CmdContext) error {
	p := plugin.New(nil)

	var err error
	if err = ctx.HandlerRegister(p); err != nil {
		return err
	}

	manifest := fmt.Sprintf("if exists('g:%s_loaded')\n", m.Host)
	manifest += `
    finish
endif
`
	manifest += fmt.Sprintf("let g:%s_loaded = 1\n", m.Host)
	manifest += `
function! s:panic(ch, data, ...) abort
    echom a:data
endfunction

function! s:Start(host) abort
`
	manifest += fmt.Sprintf("    return jobstart(['%s', 'run'], {", lib.GetProgramPath())
	manifest += `
        \ 'rpc': v:true, 
        \ 'on_stderr': function('s:panic')
        \ })
endfunction

`
	manifest += fmt.Sprintf("call remote#host#Register('%s', 'x', function('s:Start'))\n", m.Host)
	manifest += string(p.Manifest(m.Host))

	if len(m.File) > 0 {
		err = ioutil.WriteFile(m.File, []byte(manifest), 0644)
	} else {
		fmt.Printf("%s\n", manifest)
	}
	return err
}
