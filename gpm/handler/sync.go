package handler

import (
	"context"
	"fmt"
	"gpm/cmn"
	"gpm/types"
	"gpm/ui"
	"path/filepath"
	"sync"
	"time"

	"github.com/neovim/go-client/nvim"
)

func GetConfig(v *nvim.Nvim) (*types.Config, error) {
	cfg := &types.Config{}
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

func OpenInfoBox(v *nvim.Nvim) (*ui.ListBox, error) {
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

	box := ui.NewListBox(v, &bpos, &bsize)
	err = box.Open(true)
	return box, err
}

func Sync(v *nvim.Nvim) func() {
	return func() {
		cfg, err := GetConfig(v)
		if err != nil {
			cmn.NvimNotifyError(v, fmt.Sprintf("gpm sync fail, err: %s", err))
			return
		}

		err = cmn.CheckAndCreateDir(cfg.Plugin.InstallPath)
		if err != nil {
			cmn.NvimNotifyError(v, fmt.Sprintf("create plugin install dir fail, err: %s", err))
			return
		}

		err = cmn.CheckAndCreateDir(filepath.Dir(cfg.Plugin.CompilePath))
		if err != nil {
			cmn.NvimNotifyError(v, fmt.Sprintf("create plugin compile dir fail, err: %s", err))
			return
		}

		lbox, err := OpenInfoBox(v)
		if err != nil {
			cmn.NvimNotifyError(v, fmt.Sprintf("open info box fail, err: %s", err))
			return
		}

		for _, plugin := range cfg.Plugin.Plugins {
			err = lbox.AddItem(plugin)
			if err != nil {
				cmn.NvimNotifyError(v, fmt.Sprintf("add item fail fail, err: %s", err))
				return
			}
		}

		wg := sync.WaitGroup{}
		for _, p := range cfg.Plugin.Plugins {
			wg.Add(1)
			go func(plugin *types.Plugin) {
				defer func() {
					wg.Done()
				}()
				plugin.Sync(cfg.Plugin.InstallPath)
			}(p)
		}

		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()
		go UpdateInfoBox(ctx, lbox)

		wg.Wait()
	}
}

func UpdateInfoBox(ctx context.Context, lbox *ui.ListBox) {
	tick := time.NewTicker(time.Millisecond * 300)
	for {
		select {
		case <-tick.C:
			lbox.Redraw()
		case <-ctx.Done():
			return
		}
	}
}
