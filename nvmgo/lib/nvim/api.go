package nvim

import (
	"github.com/neovim/go-client/nvim"
)

func GetMode(v *nvim.Nvim) (string, error) {
	ctrlV := ""
	ctrlS := ""
	mode := nvim.Mode{}
	cmdtype := ""

	b := v.NewBatch()
	b.ReplaceTermcodes("<C-v>", true, true, true, &ctrlV)
	b.ReplaceTermcodes("<C-s>", true, true, true, &ctrlS)
	b.Mode(&mode)
	b.Call("getcmdtype", &cmdtype)
	if err := b.Execute(); err != nil {
		return "", err
	}

	m := string(mode.Mode[0])
	switch m {
	case "i":
		return "i", nil
	case "v", "V", ctrlV:
		return "x", nil
	case "s", "S", ctrlS:
		return "s", nil
	case "c":
		if cmdtype != "=" {
			return "c", nil
		}
	}
	return "", nil
}

func GetCursor(v *nvim.Nvim) (*WinPos, error) {
	mode, err := GetMode(v)
	if err != nil {
		return nil, err
	}
	if mode == "c" {
		lines := 0
		cmdheight := 0
		cmdpos := 0
		b := v.NewBatch()
		b.Option("lines", &lines)
		b.Option("cmdheight", &cmdheight)
		b.Call("getcmdpos", &cmdpos)
		if err := b.Execute(); err != nil {
			return nil, err
		}
		return &WinPos{X: float64(cmdpos) - 1, Y: float64(lines-cmdheight) + 1}, nil
	}
	pos, err := v.WindowCursor(0)
	if err != nil {
		return nil, err
	}
	return &WinPos{X: float64(pos[1]), Y: float64(pos[0])}, nil
}

func GetScreenCursor(v *nvim.Nvim) (*WinPos, error) {
	pos, err := GetCursor(v)
	if err != nil {
		return nil, err
	}
	if mode, _ := GetMode(v); mode == "c" {
		return &WinPos{Y: pos.Y, X: pos.X + 1}, nil
	}
	screenPos := map[string]int{}
	if err := v.Call("screenpos", &screenPos, 0, int(pos.Y), int(pos.X+1)); err != nil {
		return nil, err
	}
	return &WinPos{Y: float64(screenPos["row"]), X: float64(screenPos["col"] - 1)}, nil
}
