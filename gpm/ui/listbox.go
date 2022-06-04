package ui

import (
	"gpm/cmn"

	"github.com/neovim/go-client/nvim"
)

type ListBox struct {
	nvim *nvim.Nvim
	win  *cmn.Window

	items    []ListItem
	nextLNum int
}

func NewListBox(v *nvim.Nvim, pos *cmn.WinPos, size *cmn.WinSize) *ListBox {
	l := ListBox{nvim: v}
	buf := cmn.NewBuffer(v, "Box")
	err := buf.Create(false)
	if err != nil {
		panic(err)
	}
	l.win = cmn.NewWindow(v)
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
	err = l.nvim.SetBufferLines(l.win.Buffer.Number, l.nextLNum, l.nextLNum, true, lines)
	if err != nil {
		return err
	}
	l.nextLNum += len(lines)
	return nil
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

	// clear first
	b.SetBufferLines(l.win.Buffer.Number, 0, -1, false, [][]byte{})

	l.nextLNum = 0
	for i := range l.items {
		lines := l.items[i].GetLines()
		b.SetBufferLines(l.win.Buffer.Number, l.nextLNum, l.nextLNum, true, lines)
		l.nextLNum += len(lines)
	}

	return b.Execute()
}
