package ui

import (
	lnvim "nvmgo/lib/nvim"

	"github.com/neovim/go-client/nvim"
)

type ListBox struct {
	nvim *nvim.Nvim
	win  *lnvim.Window

	items    []ListItem
	nextLNum int
}

func NewListBox(v *nvim.Nvim, pos *lnvim.WinPos, size *lnvim.WinSize) *ListBox {
	l := ListBox{nvim: v}
	buf := lnvim.NewBuffer(v, "Box")
	buf.SetOptions(map[string]interface{}{
		"swapfile":   false,
		"buftype":    "nofile",
		"filetype":   "listbox",
		"bufhidden":  "hide",
		"buflisted":  false,
		"modifiable": false,
	})
	err := buf.Create(false)
	if err != nil {
		panic(err)
	}
	l.win = lnvim.NewWindow(v)
	l.win.Buffer = buf
	l.win.Config = &nvim.WindowConfig{
		Relative:  "editor",
		Width:     size.Width,
		Height:    size.Height,
		Row:       pos.Y,
		Col:       pos.X,
		Focusable: true,
		ZIndex:    50,
		Style:     "minimal",
		Border:    nvim.BorderStyleRounded,
	}
	l.win.SetOptions(map[string]interface{}{
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
		"cursorlineopt":  "line",
		"colorcolumn":    "0",
		"wrap":           false,
	})
	return &l

}

func (l *ListBox) Open(enter bool) error {
	err := l.win.Open(enter)
	if err != nil {
		return err
	}
	return l.Redraw()
}

type ListItem interface {
	GetLines() [][]byte
}

func (l *ListBox) Count() int {
	return len(l.items)
}

func (l *ListBox) AddItem(item ListItem) error {
	l.items = append(l.items, item)
	valid, err := l.win.Valid()
	if err != nil {
		return err
	}
	if !valid {
		return nil
	}
	lines := item.GetLines()

	b := l.nvim.NewBatch()
	b.SetBufferOption(l.win.Buffer.Number, "modifiable", true)
	b.SetBufferLines(l.win.Buffer.Number, l.nextLNum, l.nextLNum, true, lines)
	l.nextLNum += len(lines)
	b.SetBufferOption(l.win.Buffer.Number, "modifiable", false)
	return b.Execute()
}

func (l *ListBox) InsertItem(idx int, item ListItem) error {
	if idx < 0 {
		idx = 0
	}
	if idx > l.Count()-1 {
		idx = l.Count()
	}
	l.items = append(l.items[:idx+1], l.items[idx:]...)
	l.items[idx] = item
	return l.Redraw()
}

func (l *ListBox) DeleteItem(idx int) error {
	l.items = append(l.items[:idx], l.items[idx+1:]...)
	return l.Redraw()
}

func (l *ListBox) Reset() error {
	l.items = []ListItem{}
	return l.Redraw()
}

func (l *ListBox) Redraw() error {
	valid, err := l.win.Valid()
	if err != nil {
		return err
	}
	if !valid {
		return nil
	}

	b := l.nvim.NewBatch()

	b.SetBufferOption(l.win.Buffer.Number, "modifiable", true)

	// clear first
	b.SetBufferLines(l.win.Buffer.Number, 0, -1, false, [][]byte{})

	l.nextLNum = 0
	for i := range l.items {
		lines := l.items[i].GetLines()
		b.SetBufferLines(l.win.Buffer.Number, l.nextLNum, l.nextLNum, true, lines)
		l.nextLNum += len(lines)
	}

	b.SetBufferOption(l.win.Buffer.Number, "modifiable", false)

	return b.Execute()
}
