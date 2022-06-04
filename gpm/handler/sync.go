package handler

import (
	"context"
	"fmt"
	"gpm/cmn"
	"gpm/types"
	"gpm/ui"
	"io/ioutil"
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
				cmn.NvimNotifyError(v, fmt.Sprintf("add item fail, err: %s", err))
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

		MakeLoader(v, cfg.Plugin.Plugins, cfg.Plugin.CompilePath)

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

func MakeLuaLoadString(v *nvim.Nvim, plugin *types.Plugin) string {
	makeLoadStr := `
	function makeLoadStr(...)
		local args = { ... }
		local plugin = args[1]
		for _, item in ipairs(vim.g.gpm_config["plugin"]["plugins"]) do
			if item.name == plugin.name then
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
		cmn.NvimNotifyError(v, err.Error())
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
		cmn.NvimNotifyInfo(v, setupStr)
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
		cmn.NvimNotifyError(v, err.Error())
	}
}
