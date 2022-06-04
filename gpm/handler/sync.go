package handler

import (
	"fmt"
	"gpm/cmn"
	"gpm/ui"

	"github.com/neovim/go-client/nvim"
)

func GetConfig(v *nvim.Nvim) (*cmn.Config, error) {
	cfg := &cmn.Config{}
	err := v.Var("gpm_config", cfg)
	return cfg, err
}

var (
	luaFunc = `
	function Test()
		vim.api.nvim_notify(vim.inspect(vim.g.gpm_config), vim.log.levels.INFO, {})
	end
	Test()
`
)

func OpenInfoBox(v *nvim.Nvim) (*ui.Box, error) {
	size, err := cmn.GetVimSize(v)
	if err != nil {
		return nil, err
	}

	bsize := cmn.WinSize{
		Width:  size.Width / 2,
		Height: size.Height / 2,
	}
	bpos := cmn.WinPos{
		X: float64(size.Width) / 4,
		Y: float64(size.Height) / 4,
	}

	box := ui.NewBox(v, &bpos, &bsize)
	err = box.Open(true)
	return box, err
}

func Sync(v *nvim.Nvim) func() {
	return func() {
		_, err := GetConfig(v)
		if err != nil {
			v.Notify(fmt.Sprintf("gpm sync fail, err: %s", err), nvim.LogErrorLevel, map[string]interface{}{})
			return
		}
		// v.Notify(fmt.Sprintf("gpm config: %v", cfg), nvim.LogInfoLevel, map[string]interface{}{})
		// err = v.ExecLua(luaFunc, nil)
		// if err != nil {
		// 	v.Notify(fmt.Sprintf("gpm exec lua fail, err: %s", err), nvim.LogErrorLevel, map[string]interface{}{})
		// 	return
		// }
		iBox, err := OpenInfoBox(v)
		if err != nil {
			v.Notify(fmt.Sprintf("open info box fail, err: %s", err), nvim.LogErrorLevel, make(map[string]interface{}))
		}
		err = iBox.SetTitle("同步插件")
		if err != nil {
			v.Notify(fmt.Sprintf("set title fail, err: %s", err), nvim.LogErrorLevel, make(map[string]interface{}))
		}
	}
}
