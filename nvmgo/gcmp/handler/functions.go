package handler

import (
	"bufio"
	"path/filepath"
	"strconv"
	"strings"

	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

func upper(p *plugin.Plugin, in string) string {
	return strings.ToUpper(in)
}

type someArgs struct {
	Cwd  string `msgpack:",array"`
	Argc int
}

func returnArgs(p *plugin.Plugin, args *someArgs) ([]string, error) {
	return []string{args.Cwd, strconv.Itoa(args.Argc)}, nil
}

func getvv(p *plugin.Plugin, name string) ([]string, error) {
	var result []string
	p.Nvim.VVar(name, &result)
	return result, nil
}

func showfirst(p *plugin.Plugin) string {
	br := nvim.NewBufferReader(p.Nvim, 0)
	r := bufio.NewReader(br)
	line, _ := r.ReadString('\n')
	return line
}

func GcmpOnLspAttach(v *nvim.Nvim) func(arg interface{}) {
	return func(arg interface{}) {
		lnvim.NvimNotifyInfo(v, "LspAttached")
		logger := lib.NewLogger(filepath.Join(lib.GetProgramDir(), "handler/on_lsp_attach.log"))
		logger.Debug().Interface("Args", arg).Msg("lsp attached")

	}
}
