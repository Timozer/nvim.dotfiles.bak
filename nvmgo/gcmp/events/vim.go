package events

import (
	"gcmp/service"
	"gcmp/types"

	"github.com/neovim/go-client/nvim"
)

func ModeChanged(v *nvim.Nvim) func() {
	return func() {
		service.GetCompleteIns().SendEvent(&types.Event{
			Type: "ModeChanged",
			Data: nil,
		})
	}
}
