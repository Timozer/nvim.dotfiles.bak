package handler

import (
	"path/filepath"
	"strconv"

	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

type someArgs struct {
	Cwd  string `msgpack:",array"`
	Argc int
}

func returnArgs(p *plugin.Plugin, args *someArgs) ([]string, error) {
	return []string{args.Cwd, strconv.Itoa(args.Argc)}, nil
}

func GcmpOnLspAttach(v *nvim.Nvim) func(arg interface{}) {
	return func(arg interface{}) {
		lnvim.NvimNotifyInfo(v, "LspAttached")
		logger := lib.NewLogger(filepath.Join(lib.GetProgramDir(), "handler/on_lsp_attach.log"))
		logger.Debug().Interface("Args", arg).Msg("lsp attached")

	}
}
