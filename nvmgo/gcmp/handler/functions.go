package handler

import (
	"fmt"
	"gcmp/service"
	"strconv"

	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

type someArgs struct {
	Cwd  string `msgpack:",array"`
	Argc int
}

func returnArgs(p *plugin.Plugin, args *someArgs) ([]string, error) {
	return []string{args.Cwd, strconv.Itoa(args.Argc)}, nil
}

func GcmpOnLspAttach(v *nvim.Nvim) func(arg interface{}) {
	return func(arg interface{}) {
	}
}

func CmpMenuVisible(v *nvim.Nvim) func() (bool, error) {
	return func() (bool, error) {
		menu := service.GetCompleteIns().Menu
		if menu == nil {
			return false, nil
		}
		visible, err := menu.Visible()
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("check completion menu visible fail, err: %s", err))
			return false, err
		}
		return visible, nil
	}
}

func CmpMenuNextItem(v *nvim.Nvim) func() {
	return func() {
		menu := service.GetCompleteIns().Menu
		if menu == nil {
			return
		}
		err := menu.SelectNextItem()
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("select completion next item fail, err: %s", err))
		}
	}
}

func CmpMenuPrevItem(v *nvim.Nvim) func() {
	return func() {
		menu := service.GetCompleteIns().Menu
		if menu == nil {
			return
		}
		err := menu.SelectPrevItem()
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("select completion prev item fail, err: %s", err))
		}
	}
}
