package service

import (
	"context"
	"fmt"
	"gcmp/types"
	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"
	"path/filepath"
	"sync"

	"github.com/neovim/go-client/nvim"
)

type Lsp struct {
	Service

	requests sync.Map
}

var (
	gLspIns  *Lsp
	gLspOnce sync.Once
)

func GetLspIns() *Lsp {
	gLspOnce.Do(func() {
		gLspIns = &Lsp{}
	})
	return gLspIns
}

func (l *Lsp) Init(v *nvim.Nvim) error {
	l.nvim = v
	l.logger = lib.NewLogger(filepath.Join(lib.GetProgramDir(), "service/lsp.log"))
	l.inited = true
	return nil
}

func (l *Lsp) Serve(ctx context.Context) {
	if !l.inited {
		panic(fmt.Errorf("lsp service is not init before call Serve func"))
	}

	l.logger.Info().Msg("LspService Start")
	defer l.logger.Info().Msg("LspService End")

	for {
		select {
		case <-ctx.Done():
			l.logger.Info().Msg("LspService Done")
			return
		default:
		}
	}
}

func (l *Lsp) CompletionResp(args []*types.NvimLspCompletionResp) {
	resp := args[0]
	if resp.Err != nil {
		l.logger.Error().Interface("Err", resp.Err).Msg("CompletionResp")
		return
	}
	val, ok := l.requests.Load(resp.ReqId)
	if !ok {
		l.logger.Warn().Str("ReqId", resp.ReqId).Msg("CompletionResp NotFound")
		return
	}
	ctx := val.(*types.NvimCompletionContext)
	cmpLst := make(types.NvimCompletionList, 0)
	for i := range resp.Result.Items {
		l.logger.Debug().Interface("CompletionItem", resp.Result.Items[i]).Msg("Item")
		cmpLst = append(cmpLst, types.NvimCompletionItem{
			Word: resp.Result.Items[i].Label,
			Menu: "LSP",
		})
	}
	ctx.ResultChan <- &cmpLst
}

func (l *Lsp) Complete(ctx *types.NvimCompletionContext) {
	l.requests.Store(ctx.ReqId, ctx)

	luaFunc := `
    return (function(...)
        local args = { ... }
		local req_id = args[1]
		local params = vim.lsp.util.make_position_params()
		local callback = function(err, result, ctx, _)
			vim.fn["LspCompletionResp"]({ req_id = req_id, err = err, result = result, })
		end
        local result, cancel = vim.lsp.buf_request(0, "textDocument/completion", params, callback)
        return result
    end)(...)
    `
	var result interface{}
	err := l.nvim.ExecLua(luaFunc, &result, ctx.ReqId)
	if err != nil {
		lnvim.NvimNotifyError(l.nvim, err.Error())
		l.logger.Error().Err(err).Msg("LspComplete")
		ctx.ResultChan <- nil
		return
	}

	for {
		select {
		case <-ctx.Context.Done():
			// 如果 ctx is done, 直接返回，否则 cancel
			l.logger.Info().Msg("Complete Context Done")
			return
		}
	}
}
