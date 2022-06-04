package main

import (
	"gpm/cmd"

	"github.com/alecthomas/kong"
)

type CmdArgs struct {
	Run      cmd.Run      `cmd:""`
	Manifest cmd.Manifest `cmd:""`
}

func main() {
	cli := CmdArgs{}
	ctx := kong.Parse(&cli)
	ctx.FatalIfErrorf(ctx.Run())
}
