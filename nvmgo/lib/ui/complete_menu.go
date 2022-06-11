package ui

import (
	"fmt"
	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"
	"nvmgo/lib/types"
	"path/filepath"

	"github.com/neovim/go-client/nvim"
)

type CompletionMenu struct {
	nvim *nvim.Nvim
	win  *lnvim.Window
}

func NewCompletionMenu(v *nvim.Nvim, pos *lnvim.WinPos) *CompletionMenu {
	m := CompletionMenu{nvim: v}

	b := lnvim.NewBuffer(v, "Menu")
	b.SetOptions(map[string]interface{}{
		"swapfile":   false,
		"buftype":    "nofile",
		"filetype":   "menu",
		"bufhidden":  "hide",
		"buflisted":  false,
		"modifiable": false,
		"tabstop":    1,
	})
	err := b.Create(false)
	if err != nil {
		panic(err)
	}

	m.win = lnvim.NewWindow(v)
	m.win.Buffer = b
	m.win.Config = &nvim.WindowConfig{
		Relative:  "editor",
		Width:     1,
		Height:    1,
		Row:       pos.Y,
		Col:       pos.X,
		Focusable: false,
		ZIndex:    100,
		Style:     "minimal",
		Border:    nvim.BorderStyleRounded,
	}
	m.win.SetOptions(map[string]interface{}{
		"relativenumber": false,
		"number":         false,
		"list":           false,
		"foldenable":     false,
		"winfixwidth":    true,
		"winfixheight":   true,
		"spell":          false,
		"signcolumn":     "no",
		"foldmethod":     "manual",
		"foldcolumn":     "0",
		"cursorcolumn":   false,
		"cursorline":     true,
		"cursorlineopt":  "line",
		"colorcolumn":    "0",
		"wrap":           false,
		"winblend":       0,
		"conceallevel":   2,
		"concealcursor":  "n",
	})
	return &m
}

func (m *CompletionMenu) Open(lst types.CompletionList) error {
	logger := lib.NewLogger(filepath.Join(lib.GetProgramDir(), "menu.log"))

	lineFmt := fmt.Sprintf("%%%ds %%-%ds %%%ds [%%%ds]", lst.IconWidth, lst.WordWidth, lst.KindWidth, lst.SourceWidth)

	items := lst.Items

	width := 0
	lines := make([][]byte, 0)
	for i := range items {
		line := fmt.Sprintf(lineFmt, items[i].Icon, items[i].Word, items[i].Kind, items[i].Source)
		width = lib.Max(width, len(line))
		lines = append(lines, []byte(line))
	}
	m.win.Config.Width = width

	logger.Debug().Interface("WinId", m.win.Id).Msg("BeforeOpen")
	err := m.win.Open(false)
	if err != nil {
		return err
	}
	logger.Debug().Interface("WinId", m.win.Id).Msg("AfterOpen")

	b := m.nvim.NewBatch()
	b.SetBufferOption(m.win.Buffer.Number, "modifiable", true)
	b.SetBufferLines(m.win.Buffer.Number, 0, 1, true, lines)
	b.SetBufferOption(m.win.Buffer.Number, "modifiable", false)
	return b.Execute()
	// return nil
}
