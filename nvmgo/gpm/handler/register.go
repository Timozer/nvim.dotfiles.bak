package handler

import (
	"github.com/neovim/go-client/nvim/plugin"
)

func Register(p *plugin.Plugin) error {
	// Command Completion
	p.HandleCommand(&plugin.CommandOptions{Name: "GpmStatus", NArgs: "0"}, Status(p.Nvim))
	p.HandleCommand(&plugin.CommandOptions{Name: "GpmSync", NArgs: "0"}, Sync(p.Nvim))

	return nil
}
