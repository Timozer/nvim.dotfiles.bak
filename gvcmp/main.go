package main

import (
    "gvcmp/cmd"
    "gvcmp/common"

	"github.com/alecthomas/kong"
)

type CmdArgs struct {
    Run      cmd.Run      `cmd:""`
    Manifest cmd.Manifest `cmd:""`
}

func main() {
    common.InitLogger()

    cli := CmdArgs{}
    ctx := kong.Parse(&cli)
    ctx.FatalIfErrorf(ctx.Run())
}
