package cmd

import (
    "os"
    "log"

    "gvcmp/common"
    "gvcmp/handler"
	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)


type Run struct {
}

func (r *Run) Run() error {
    logger := common.GetLogger()

	stdout := os.Stdout
	os.Stdout = os.Stderr
	log.SetFlags(0)

	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
        logger.Fatal().Err(err).Msg("NewNvim")
        return err
	}
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

