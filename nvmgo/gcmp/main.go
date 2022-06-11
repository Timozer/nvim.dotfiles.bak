package main

import (
	"fmt"
	"gcmp/handler"
	"os"
	"path/filepath"

	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"

	"github.com/alecthomas/kong"
)

type CmdArgs struct {
	Run      Run            `cmd:""`
	Manifest lnvim.Manifest `cmd:""`
}

func main() {
	defer func() {
		if p := recover(); p != nil {
			logger := lib.NewLogger(filepath.Join(lib.GetProgramDir(), "run.log"))
			logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()
	cli := CmdArgs{}
	ctx := kong.Parse(&cli)
	ctx.FatalIfErrorf(ctx.Run(&lnvim.CmdContext{HandlerRegister: handler.Register}))
}
