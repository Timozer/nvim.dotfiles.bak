package main

import (
	"context"
	"fmt"
	"gcmp/service"
	"log"
	"os"
	"path/filepath"

	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

type Run struct {
}

func (r *Run) Run(cmdCtx *lnvim.CmdContext) error {
	defer func() {
		if p := recover(); p != nil {
			logger := lib.NewLogger(filepath.Join(lib.GetProgramDir(), "run.log"))
			logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()

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

	lspService := service.GetLspIns()
	lspService.Init(v)
	go lspService.Serve(ctx)

	cmpService.AddSource(bufService)
	cmpService.AddSource(lspService)

	if err := cmdCtx.HandlerRegister(plugin.New(v)); err != nil {
		return err
	}
	if err := v.Serve(); err != nil {
		return err
	}
	return nil
}
