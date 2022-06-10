package handler

import (
	"strconv"

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
	}
}
