package handler

import (
	"fmt"
	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
)

func BufEnter(v *nvim.Nvim) func() {
	return func() {
		buf, _ := v.CurrentBuffer()

		buflisted := false
		buftype := ""

		b := v.NewBatch()
		b.BufferOption(buf, "buflisted", &buflisted)
		b.BufferOption(buf, "buftype", &buftype)
		if err := b.Execute(); err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}

		if !buflisted || buftype == "terminal" {
			return
		}

		attached, err := v.AttachBuffer(buf, true, map[string]interface{}{})
		if err != nil || !attached {
			lnvim.NvimNotifyError(v, fmt.Sprintf("buffer not attached or err: %s", attached, err.Error()))
			return
		}
	}
}

func VimEnter(v *nvim.Nvim) func() {
	return func() {
		opts := make(map[string]bool)
		opts["noremap"] = true
		opts["silent"] = true
		opts["expr"] = true
		err := v.SetKeyMap("i", "<cr>",
			`pumvisible() ? (complete_info(["selected"]).selected == -1 ? "<c-e><cr>" : "<c-y>") : "<cr>"`,
			opts,
		)
		if err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}
		err = v.SetKeyMap("i", "<tab>", `pumvisible() ? '<C-n>' : '<tab>'`, opts)
		if err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}
		err = v.SetKeyMap("i", "<s-tab>", `pumvisible() ? '<C-p>' : '<bs>'`, opts)
		if err != nil {
			lnvim.NvimNotifyError(v, err.Error())
			return
		}
	}
}
