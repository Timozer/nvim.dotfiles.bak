package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"

	"gcmp/service"
	"gcmp/types"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

func GetConfig(v *nvim.Nvim) (*types.Config, error) {
	cfg := &types.Config{}
	err := v.Var("gcmp_config", cfg)
	return cfg, err
}

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

	cfg, err := GetConfig(v)
	if err != nil {
		lnvim.NvimNotifyError(v, fmt.Sprintf("get gcmp config fail, err: %s", err))
		return err
	}

	logger := lib.NewLogger("gcmp.log", &cfg.Log)
	lnvim.NvimNotifyInfo(v, fmt.Sprintf("gcmp log file: %s", filepath.Join(cfg.Log.Dir, "gcmp.log")))

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	cmpService := service.GetCompleteIns()
	cmpService.Init(v, cfg)
	go cmpService.Serve(ctx)

	bufService := service.GetBufferIns()
	bufService.Init(v, cfg)
	go bufService.Serve(ctx)

	if err := cmdCtx.HandlerRegister(plugin.New(v)); err != nil {
		logger.Fatal().Err(err).Msg("RegisterHandlers")
		return err
	}
	if err := v.Serve(); err != nil {
		logger.Fatal().Err(err).Msg("NvimServe")
		return err
	}
	return nil
}
