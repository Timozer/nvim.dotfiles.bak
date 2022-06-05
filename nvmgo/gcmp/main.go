package main

import (
	"gcmp/handler"

	lnvim "nvmgo/lib/nvim"

	"github.com/alecthomas/kong"
)

type CmdArgs struct {
	Run      Run            `cmd:""`
	Manifest lnvim.Manifest `cmd:""`
}

func main() {
	cli := CmdArgs{}
	ctx := kong.Parse(&cli)
	ctx.FatalIfErrorf(ctx.Run(&lnvim.CmdContext{HandlerRegister: handler.Register}))
}
