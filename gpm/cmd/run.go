package cmd

import (
	"log"
	"os"

	"gpm/handler"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

type Run struct {
}

func (r *Run) Run() error {
	stdout := os.Stdout
	os.Stdout = os.Stderr
	log.SetFlags(0)

	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		return err
	}

	if err := handler.Register(plugin.New(v)); err != nil {
		return err
	}
	if err := v.Serve(); err != nil {
		return err
	}
	return nil
}
