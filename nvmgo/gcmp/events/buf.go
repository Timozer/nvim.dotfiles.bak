package events

import (
	"fmt"
	"gcmp/service"
	"gcmp/types"
	lnvim "nvmgo/lib/nvim"
	"strconv"

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

		attached, err := v.AttachBuffer(buf, false, map[string]interface{}{})
		if err != nil || !attached {
			lnvim.NvimNotifyError(v, fmt.Sprintf("buffer not attached or err: %s", attached, err.Error()))
			return
		}
		service.GetBufferIns().SendEvent(&types.Event{
			Type: "BufEnter",
			Data: buf,
		})
	}
}

func BufWritePost(v *nvim.Nvim) func(string) {
	return func(b string) {
		lnvim.NvimNotifyDebug(v, fmt.Sprintf("buf file is: %v", b))
		bufnr, err := strconv.Atoi(b)
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("parse bufnr fail, err: %s", err))
			return
		}
		service.GetBufferIns().SendEvent(&types.Event{
			Type: "BufWritePost",
			Data: nvim.Buffer(bufnr),
		})
	}
}

func BufWipeout(v *nvim.Nvim) func(string) {
	return func(b string) {
		lnvim.NvimNotifyDebug(v, fmt.Sprintf("buf file is: %v", b))
		bufnr, err := strconv.Atoi(b)
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("parse bufnr fail, err: %s", err))
			return
		}
		service.GetBufferIns().SendEvent(&types.Event{
			Type: "BufWipeout",
			Data: nvim.Buffer(bufnr),
		})
	}
}
