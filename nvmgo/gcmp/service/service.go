package service

import (
	"github.com/neovim/go-client/nvim"
	"github.com/rs/zerolog"
)

type Service struct {
	nvim   *nvim.Nvim
	logger *zerolog.Logger
	inited bool
}
