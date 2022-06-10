package service

import (
	"gcmp/types"

	"github.com/neovim/go-client/nvim"
)

type Paths struct {
}

func (p *Paths) FuzzyFind(buf nvim.Buffer, prefix string) types.NvimCompletionList {
	return nil
}
