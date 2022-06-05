package service

import (
	"gcmp/types"

	"github.com/neovim/go-client/nvim"
	"github.com/rs/zerolog"
)

type Service struct {
	nvim   *nvim.Nvim
	config *types.Config
	logger *zerolog.Logger
	inited bool
}
