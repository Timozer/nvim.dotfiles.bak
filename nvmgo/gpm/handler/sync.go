package handler

import (
	"context"
	"fmt"
	"gpm/types"
	"io/ioutil"
	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"
	"nvmgo/lib/ui"
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

func OpenInfoBox(v *nvim.Nvim) (*ui.ListBox, error) {
	size, err := lnvim.GetVimSize(v)
	if err != nil {
		return nil, err
	}

	bsize := lnvim.WinSize{
		Width:  size.Width / 2,
		Height: size.Height / 2,
	}
	bpos := lnvim.WinPos{
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
			lnvim.NvimNotifyError(v, fmt.Sprintf("gpm sync fail, err: %s", err))
			return
		}

		err = lib.CreateDirIfNotExist(cfg.Plugin.InstallPath)
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("create plugin install dir fail, err: %s", err))
			return
		}

		err = lib.CreateDirIfNotExist(filepath.Dir(cfg.Plugin.CompilePath))
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("create plugin compile dir fail, err: %s", err))
			return
		}

		lbox, err := OpenInfoBox(v)
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("open info box fail, err: %s", err))
			return
		}

		for _, plugin := range cfg.Plugin.Plugins {
			err = lbox.AddItem(plugin)
			if err != nil {
				lnvim.NvimNotifyError(v, fmt.Sprintf("add item fail, err: %s", err))
				return
			}
		}
		ifooter := &InfoFooter{}
		err = lbox.AddItem(ifooter)
		if err != nil {
			lnvim.NvimNotifyError(v, fmt.Sprintf("add info footer item fail, err: %s", err))
			return
		}
		ifooter.Status = "installing plugins..."

		wg := sync.WaitGroup{}
		for _, p := range cfg.Plugin.Plugins {
			p.InstallPath = cfg.Plugin.InstallPath
			wg.Add(1)
			go func(plugin *types.Plugin) {
				defer func() {
					wg.Done()
				}()
				plugin.Sync()
			}(p)
		}

		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()
		go UpdateInfoBox(ctx, lbox)

		wg.Wait()
		ifooter.Status = "install plugins done. start compiling ..."

		MakeLoader(v, cfg.Plugin.Plugins, cfg.Plugin.CompilePath)

		ifooter.Status = "compile plugins done."
		lbox.Redraw()
	}
}

type InfoFooter struct {
	Status string
}

func (i *InfoFooter) GetLines() [][]byte {
	return [][]byte{[]byte(i.Status)}
}

func UpdateInfoBox(ctx context.Context, lbox *ui.ListBox) {
	tick := time.NewTicker(time.Millisecond * 100)
	for {
		select {
		case <-tick.C:
			lbox.Redraw()
		case <-ctx.Done():
			return
		}
	}
}

func MakeLuaLoadString(v *nvim.Nvim, plugin *types.Plugin) string {
	makeLoadStr := `
	function makeLoadStr(...)
		local args = { ... }
		local plugin = args[1]
		for _, item in ipairs(vim.g.gpm_config["plugin"]["plugins"]) do
			if item.path == plugin.path then
				if type(item.setup) == 'function' then
					return vim.inspect(string.dump(item.setup, true))
				else
					return "\"\""
				end
			end
		end
		return "\"\""
	end
	return makeLoadStr(...)
	`
	bytecode := ""
	err := v.ExecLua(makeLoadStr, &bytecode, plugin)
	if err != nil {
		lnvim.NvimNotifyError(v, err.Error())
	}
	return bytecode
}

func MakeLoader(v *nvim.Nvim, plugins []*types.Plugin, output string) {
	luastr := `
if vim.g.gpm_plugins_loaded and vim.g.gpm_plugins_loaded == 1 then
    return
end

if vim.api.nvim_call_function('has', {'nvim-0.7'}) ~= 1 then
    vim.fn.nvim_out_write("gpm plugins load requires at least nvim-0.7")
    return
end

vim.g.gpm_lugins_loaded = 1

local function loadStr(s)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('Error running loadStr ' .. s .. ' result ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

local no_errors, err_msg = pcall(function()
`
	rtps := []string{}
	events := make(map[string][]types.Event)
	for _, p := range plugins {
		if p.Disable {
			continue
		}
		rtps = append(rtps, p.InstallPath)

		luastr += fmt.Sprintf("\tvim.cmd [[ packadd %s ]]\n", p.Name)
		setupStr := fmt.Sprintf("\tloadStr(%s)\n", MakeLuaLoadString(v, p))
		luastr += setupStr

		events[p.Name] = p.Event
	}
	luastr += `
	vim.cmd [[ augroup gpm_aucmds ]]
	vim.cmd [[ au! ]]
`
	// for k, v := range events {
	// 	for i := range v {
	// 		pattern := v[i].Pattern
	// 		if len(pattern) == 0 {
	// 			pattern = "*"
	// 		}
	// 		luastr += fmt.Sprintf("\tvim.cmd [[ au %s %s ++once lua require(")
	// 	}
	// }
	luastr += `
	vim.cmd [[ augroup END ]]
end)

if not no_errors then
	vim.api.nvim_notify(err_msg, vim.log.levels.ERROR, {})
end
	`

	err := ioutil.WriteFile(output, []byte(luastr), 0644)
	if err != nil {
		lnvim.NvimNotifyError(v, err.Error())
	}
}
