package service

import (
	"context"
	"fmt"
	"gcmp/types"
	"nvmgo/lib"
	"os"
	"path/filepath"
	"sort"
	"sync"
	"time"

	"github.com/neovim/go-client/nvim"
)

type CompleteSource interface {
	Complete(*types.NvimCompletionContext)
}

type Complete struct {
	Service

	eventChan chan *nvim.BufLinesEvent

	sources []CompleteSource
}

var (
	gCompleteIns  *Complete
	gCompleteOnce sync.Once
)

func GetCompleteIns() *Complete {
	gCompleteOnce.Do(func() {
		gCompleteIns = &Complete{}
		gCompleteIns.inited = false
	})
	return gCompleteIns
}

func (c *Complete) Init(v *nvim.Nvim) error {
	c.nvim = v
	c.eventChan = make(chan *nvim.BufLinesEvent, 1000)
	c.logger = lib.NewLogger(filepath.Join(lib.GetProgramDir(), "service/complete.log"))
	c.inited = true
	return nil
}

func (c *Complete) AddSource(src CompleteSource) {
	c.sources = append(c.sources, src)
}

func (c *Complete) SendEvent(e *nvim.BufLinesEvent) error {
	c.eventChan <- e
	return nil
}

func (c *Complete) Serve(ctx context.Context) {
	if !c.inited {
		panic(fmt.Errorf("complete service is not init before call Serve func"))
	}

	c.logger.Info().Msg("CompleteService Start")
	defer c.logger.Info().Msg("CompleteService End")

	for {
		select {
		case <-ctx.Done():
			c.logger.Info().Msg("CompleteService Done")
			return
		case e := <-c.eventChan:
			c.logger.Debug().Interface("Event", e).Msg("Receive BufLinesEvent")
			err := c.ProcessEvent(e)
			if err != nil {
				c.logger.Error().Err(err).Msg("ProcessEvent")
			}
		default:
		}
	}
}

func (c *Complete) ProcessEvent(e *nvim.BufLinesEvent) error {
	defer func() {
		if p := recover(); p != nil {
			c.logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()

	if e.LastLine == -1 {
		return nil
	}

	ctx, err := types.NewCompleteContext(c.nvim, e.Buffer)
	if err != nil {
		return err
	}
	c.logger.Debug().Interface("Context", ctx).Msg("ProcessEvent")
	defer ctx.CancelFunc()

	if pum_visible, _ := ctx.CompleteInfos["pum_visible"].(int64); pum_visible == 1 {
		return nil
	}
	if ctx.Mode.Mode[0] != 'i' || len(ctx.LineBefore) < 2 {
		return nil
	}

	c.logger.Debug().Interface("CompleteMode", ctx.CompleteInfos["mode"]).Msg("ProcessEvents")

	ctx.ResultChan = make(chan *types.NvimCompletionList, len(c.sources))
	for i := range c.sources {
		go c.sources[i].Complete(ctx)
	}

	results := make([]*types.NvimCompletionList, 0)
	timeout := time.NewTicker(time.Millisecond * 100)
	func() {
		for {
			select {
			case itemList := <-ctx.ResultChan:
				c.logger.Debug().Interface("ItemList", itemList).Msg("ReceiveItemList")
				results = append(results, itemList)
				if len(results) == len(c.sources) {
					return
				}
			case <-timeout.C:
				c.logger.Debug().Msg("WaitCompletionList Timeout")
				return
			}
		}
	}()

	words := make(types.NvimCompletionList, 0)
	for i := range results {
		if results[i] == nil || results[i].Len() == 0 {
			continue
		}
		words = append(words, *results[i]...)
	}
	if words == nil || (words.Len() == 1 && words[0].Word == string(ctx.LineBefore)) {
		return nil
	}
	sort.Sort(words)
	c.logger.Debug().Interface("Bufnr", e.Buffer).Interface("Words", words).Msg("BeforeCompleteCall")
	c.nvim.Call("complete", nil, ctx.StartCol+1, words)
	c.logger.Debug().Msg("AfterCompleteCall")
	return nil
}

var (
	CompleteModes = []string{"", "eval", "function", "ctrl_x"}
)
