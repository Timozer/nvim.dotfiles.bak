package ui

import (
	"fmt"
	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"
	"nvmgo/lib/types"

	"github.com/neovim/go-client/nvim"
)

type CompletionMenu struct {
	nvim *nvim.Nvim
	win  *lnvim.Window
}

func NewCompletionMenu(v *nvim.Nvim) *CompletionMenu {
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

func (m *CompletionMenu) Open(lst types.CompletionList, pos *lnvim.WinPos) error {
	// logger := lib.NewLogger(filepath.Join(lib.GetProgramDir(), "menu.log"))

	lineFmt := fmt.Sprintf("%%%ds %%-%ds %%%ds [%%%ds]", lst.IconWidth, lst.WordWidth, lst.KindWidth, lst.SourceWidth)

	items := lst.Items

	width := 0
	lines := make([][]byte, 0)
	for i := range items {
		line := fmt.Sprintf(lineFmt, items[i].Icon, items[i].Word, items[i].Kind, items[i].Source)
		width = lib.Max(width, len(line))
		lines = append(lines, []byte(line))
	}
	b := m.nvim.NewBatch()
	b.SetBufferOption(m.win.Buffer.Number, "modifiable", true)
	b.SetBufferLines(m.win.Buffer.Number, 0, -1, false, lines)
	b.SetBufferOption(m.win.Buffer.Number, "modifiable", false)
	if err := b.Execute(); err != nil {
		return err
	}

	m.win.Config.Width = width
	m.win.Config.Height = len(lines)

	m.win.Config.Row = pos.Y
	m.win.Config.Col = pos.X
	return m.win.Open(false)
}

func (m *CompletionMenu) Visible() (bool, error) {
	return m.win.Valid()
}

func (m *CompletionMenu) Close() error {
	return m.win.Close()
}

func (m *CompletionMenu) SelectNextItem() error {
	visible, err := m.Visible()
	if err != nil {
		return err
	}
	if !visible {
		return nil
	}
	pos, err := m.nvim.WindowCursor(m.win.Id)
	if err != nil {
		return err
	}
	pos[0] += 1
	if pos[0] > m.win.Config.Height {
		pos[0] = 1
	}
	return m.nvim.SetWindowCursor(m.win.Id, pos)
}

func (m *CompletionMenu) SelectPrevItem() error {
	visible, err := m.Visible()
	if err != nil {
		return err
	}
	if !visible {
		return nil
	}
	pos, err := m.nvim.WindowCursor(m.win.Id)
	if err != nil {
		return err
	}
	pos[0] -= 1
	if pos[0] == 0 {
		pos[0] = m.win.Config.Height
	}
	return m.nvim.SetWindowCursor(m.win.Id, pos)
}
