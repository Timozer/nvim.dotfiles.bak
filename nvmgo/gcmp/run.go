package main

import (
	"context"
	"log"
	"nvmgo/lib"
	"os"

	"gcmp/handler"
	"gcmp/service"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

type Run struct {
}

func (r *Run) Run() error {
	logger := lib.NewLogger("logs/gcmp.log")

	stdout := os.Stdout
	os.Stdout = os.Stderr
	log.SetFlags(0)

	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		logger.Fatal().Err(err).Msg("NewNvim")
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

	if err := handler.Register(plugin.New(v)); err != nil {
		logger.Fatal().Err(err).Msg("RegisterHandlers")
		return err
	}
	if err := v.Serve(); err != nil {
		logger.Fatal().Err(err).Msg("NvimServe")
		return err
	}
	return nil
}
