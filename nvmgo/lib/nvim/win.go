package nvim

import (
	"fmt"

	"github.com/neovim/go-client/nvim"
)

type WinPos struct {
	X float64
	Y float64
}

type WinSize struct {
	Width  int
	Height int
}

func GetVimSize(v *nvim.Nvim) (*WinSize, error) {
	size := &WinSize{}
	b := v.NewBatch()
	b.Option("lines", &size.Height)
	b.Option("columns", &size.Width)
	err := b.Execute()
	return size, err
}

type Window struct {
	Nvim    *nvim.Nvim
	Id      nvim.Window
	Options map[string]interface{}
	Buffer  *Buffer

	Config *nvim.WindowConfig
}

func NewWindow(v *nvim.Nvim) *Window {
	return &Window{
		Nvim:    v,
		Options: make(map[string]interface{}),
	}
}

func (w *Window) Open(enter bool) error {
	valid, err := w.Valid()
	if err != nil {
		return err
	}
	if valid {
		return nil
	}

	if valid, err := w.Buffer.Valid(); err != nil || !valid {
		return fmt.Errorf("buf invalid [%v] or there is an error: %s", !valid, err)
	}

	b := w.Nvim.NewBatch()
	b.OpenWindow(w.Buffer.Number, enter, w.Config, &w.Id)
	for k := range w.Options {
		b.SetWindowOption(w.Id, k, w.Options[k])
	}
	return b.Execute()
}

func (w *Window) SetOptions(opts map[string]interface{}) error {
	for k := range opts {
		w.Options[k] = opts[k]
	}

	valid, err := w.Valid()
	if err != nil {
		return err
	}
	if !valid {
		return nil
	}

	b := w.Nvim.NewBatch()
	for k := range opts {
		b.SetWindowOption(w.Id, k, w.Options[k])
	}
	return b.Execute()
}

func (w *Window) Valid() (bool, error) {
	if w.Id < 1 {
		return false, nil
	}
	return w.Nvim.IsWindowValid(w.Id)
}

func (w *Window) UpdateConfig() error {
	valid, err := w.Valid()
	if err != nil {
		return err
	}
	if !valid {
		return nil
	}

	return w.Nvim.SetWindowConfig(w.Id, w.Config)
}

func (w *Window) Close() {
	valid, _ := w.Valid()
	if !valid {
		return
	}
	w.Nvim.HideWindow(w.Id)
}

// -- local config = {
// --     relative = 'editor' | 'win' | 'cursor' | '',
// --     win = winid,
// --     anchor = 'NW' | 'NE' | 'SW' | 'SE',
// --     width = 0,
// --     height = 0,
// --     row = 0,
// --     col = 0,
// --     focusable = true,
// --     zindex = 100,
// --     border = 'rounded',
// --     noautocmd = false,
// -- }

// function M:GetOption(key)
//     if vim.fn.exists('+'..key) == 0 then
//         return nil
//     end
//     if not self:Visible() then
//         return self.options[key]
//     else
//         return vim.api.nvim_win_get_option(self.winid, key)
//     end
// end
