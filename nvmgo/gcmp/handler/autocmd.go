package handler

import (
	"nvmgo/lib"

	"github.com/neovim/go-client/nvim"
)

func BufEnter(v *nvim.Nvim) func() {
	return func() {
		logger := lib.NewLogger("logs/bufenter.log")

		buf, _ := v.CurrentBuffer()

		buflisted := false
		buftype := ""

		b := v.NewBatch()
		b.BufferOption(buf, "buflisted", &buflisted)
		b.BufferOption(buf, "buftype", &buftype)
		if err := b.Execute(); err != nil {
			logger.Error().Err(err).Int("Bufnr", int(buf)).Msg("BufferOption")
			return
		}

		logger.Debug().Bool("BufListed", buflisted).Str("BufType", buftype).Int("Bufnr", int(buf)).Msg("BufferOption")

		if !buflisted || buftype == "terminal" {
			return
		}

		attached, err := v.AttachBuffer(buf, true, map[string]interface{}{})
		if err != nil {
			logger.Error().Err(err).Int("Bufnr", int(buf)).Msg("AttachBuffer")
			return
		}
		logger.Debug().Bool("Attached", attached).Int("Bufnr", int(buf)).Msg("AttachBuffer")
	}
}

func VimEnter(v *nvim.Nvim) func() {
	return func() {
		logger := lib.NewLogger("logs/vimenter.log")
		logger.Debug().Msg("before set keymaps")
		opts := make(map[string]bool)
		opts["noremap"] = true
		opts["silent"] = true
		opts["expr"] = true
		err := v.SetKeyMap("i", "<cr>",
			`pumvisible() ? (complete_info(["selected"]).selected == -1 ? "<c-e><cr>" : "<c-y>") : "<cr>"`,
			opts,
		)
		logger.Debug().Msg("after set 1 keymap")
		if err != nil {
			logger.Fatal().Err(err).Msg("SetKeyMap")
			return
		}
		err = v.SetKeyMap("i", "<tab>", `pumvisible() ? '<C-n>' : '<tab>'`, opts)
		if err != nil {
			logger.Fatal().Err(err).Msg("SetKeyMap")
			return
		}
		err = v.SetKeyMap("i", "<s-tab>", `pumvisible() ? '<C-p>' : '<bs>'`, opts)
		if err != nil {
			logger.Fatal().Err(err).Msg("SetKeyMap")
			return
		}
		logger.Debug().Msg("after set keymaps")
	}
}
