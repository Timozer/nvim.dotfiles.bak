package main

import (
	"context"
	"gcmp/service"
	"log"
	"os"

	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

type Run struct {
}

func (r *Run) Run(cmdCtx *lnvim.CmdContext) error {
	stdout := os.Stdout
	os.Stdout = os.Stderr
	log.SetFlags(0)

	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		return err
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	cmpService := service.GetCompleteIns()
	cmpService.Init(v)
	go cmpService.Serve(ctx)

	bufService := service.GetBufferIns()
	bufService.Init(v)
	go bufService.Serve(ctx)

	if err := cmdCtx.HandlerRegister(plugin.New(v)); err != nil {
		return err
	}
	if err := v.Serve(); err != nil {
		return err
	}
	return nil
}
