package ui

import (
	"gpm/cmn"
	"strings"

	"github.com/neovim/go-client/nvim"
)

type Box struct {
	Nvim   *nvim.Nvim
	Window *cmn.Window
}

func NewBox(v *nvim.Nvim, pos *cmn.WinPos, size *cmn.WinSize) *Box {
	b := Box{Nvim: v}
	buf := cmn.NewBuffer(v, "Box")
	err := buf.Create(false)
	if err != nil {
		panic(err)
	}
	b.Window = cmn.NewWindow(v)
	b.Window.Buffer = buf
	b.Window.Config = &nvim.WindowConfig{
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
	return &b
}

func (b *Box) Open(enter bool) error {
	return b.Window.Open(enter)
}

func (b *Box) SetTitle(title string) error {
	length := len(title)
	if length <= 0 {
		return nil
	}
	startCol := (b.Window.Config.Width - length) / 2
	title = strings.Repeat(" ", startCol) + title
	return b.Nvim.SetBufferLines(b.Window.Buffer.Number, 0, 1, true, [][]byte{[]byte(title)})
}
