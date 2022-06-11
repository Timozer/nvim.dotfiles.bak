package events

import (
	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
)

func VimEnter(v *nvim.Nvim) func() {
	return func() {
		opts := make(map[string]bool)
		opts["noremap"] = true
		opts["silent"] = true
		opts["expr"] = true
		err := v.SetKeyMap("i", "<cr>",
			`CmpMenuVisible() ? (CmpMenuSelectConfirm() ? "":"") : '<cr>'`,
			// `pumvisible() ? (complete_info(["selected"]).selected == -1 ? "<c-e><cr>" : "<c-y>") : "<cr>"`,
			opts,
		)
		if err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}
		err = v.SetKeyMap("i", "<tab>", `CmpMenuVisible() ? (CmpMenuNextItem() ? "":"") : '<tab>'`, opts)
		if err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}
		err = v.SetKeyMap("i", "<s-tab>", `CmpMenuVisible() ? (CmpMenuPrevItem() ? "":"") : '<bs>'`, opts)
		if err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}
	}
}
