package service

import (
	"github.com/neovim/go-client/nvim"
)

type Paths struct {
}

func (p *Paths) FuzzyFind(buf nvim.Buffer, prefix string) CompleteItems {
	return nil
}
