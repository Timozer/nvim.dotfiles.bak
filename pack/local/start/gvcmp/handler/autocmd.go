package handler

import (
    "gvcmp/common"
	"github.com/neovim/go-client/nvim"
)

func BufEnter(v *nvim.Nvim) func() {
    return func() {
        logger := common.GetLogger()

        buf, _ := v.CurrentBuffer()

        buflisted := false
        buftype   := ""

        b := v.NewBatch()
        b.BufferOption(buf, "buflisted", &buflisted)
        b.BufferOption(buf, "buftype", &buftype)
        if err := b.Execute(); err != nil {
            logger.Error().Err(err).Int("Bufnr", int(buf)).Msg("BufferOption")
            return
        }

        logger.Debug().Bool("BufListed", buflisted).Str("BufType", buftype).Int("Bufnr", int(buf)).Msg("BufferOption")

        if !buflisted || buftype  == "terminal" {
            return
        }

        attached, err := v.AttachBuffer(buf, false, map[string]interface{}{})
        if err != nil {
            logger.Error().Err(err).Int("Bufnr", int(buf)).Msg("AttachBuffer")
            return
        }
        logger.Debug().Bool("Attached", attached).Int("Bufnr", int(buf)).Msg("AttachBuffer")
    }
}
