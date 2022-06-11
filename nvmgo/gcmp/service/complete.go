package service

import (
	"context"
	"fmt"
	"gcmp/types"
	"gcmp/ui"
	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"
	ltyp "nvmgo/lib/types"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/neovim/go-client/nvim"
)

type CompleteSource interface {
	Complete(*types.NvimCompletionContext)
}

type Complete struct {
	Service

	eventChan     chan *types.Event
	eventHandlers map[string]func(interface{}) error

	sources []CompleteSource

	Menu   *ui.CompletionMenu
	CmpCtx *types.NvimCompletionContext
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
	c.logger = lib.NewLogger(filepath.Join(lib.GetProgramDir(), "service/complete.log"))
	c.eventChan = make(chan *types.Event, 1000)

	c.eventHandlers = make(map[string]func(interface{}) error)
	c.eventHandlers["BufLinesEvent"] = c.BufLinesEvent
	c.eventHandlers["ModeChanged"] = c.ModeChanged
	c.eventHandlers["SelectConfirm"] = c.SelectConfirm

	c.inited = true
	return nil
}

func (c *Complete) AddSource(src CompleteSource) {
	c.sources = append(c.sources, src)
}

func (c *Complete) SendEvent(e *types.Event) error {
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
			c.ProcessEvent(e)
		default:
		}
	}
}

func (c *Complete) ProcessEvent(e *types.Event) {
	h, ok := c.eventHandlers[e.Type]
	if !ok {
		c.logger.Warn().Str("EventType", e.Type).Msg("Unsupported Event")
		return
	}
	err := h(e.Data)
	if err != nil {
		c.logger.Error().Err(err).Msg("ProcessEvent")
	}
}

func (c *Complete) ModeChanged(data interface{}) error {
	if c.Menu != nil {
		return c.Menu.Close()
	}
	return nil
}

func (c *Complete) SelectConfirm(data interface{}) error {
	defer func() {
		if p := recover(); p != nil {
			c.logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()
	idx, err := c.Menu.GetSelectedIndex()
	if err != nil {
		return err
	}
	c.Menu.Close()
	c.logger.Debug().Interface("Index", idx).Interface("Ctx", c.CmpCtx).Msg("SelectConfirm")
	item := c.CmpCtx.CompletionList.Items[idx]
	err = c.nvim.SetBufferText(0, c.CmpCtx.Cursor[0]-1, c.CmpCtx.StartCol, c.CmpCtx.Cursor[0]-1, c.CmpCtx.Cursor[1], [][]byte{[]byte(item.Word)})
	pos := c.CmpCtx.Cursor
	pos[1] = c.CmpCtx.StartCol + len(item.Word)
	err = c.nvim.SetWindowCursor(0, pos)
	c.logger.Debug().Msg("AfterSelectConfirm")
	return err
}

func (c *Complete) BufLinesEvent(data interface{}) error {
	defer func() {
		if p := recover(); p != nil {
			c.logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()
	var err error

	e, _ := data.(*nvim.BufLinesEvent)

	if e.LastLine == -1 {
		return nil
	}

	if c.Menu != nil {
		visible, err := c.Menu.Visible()
		if err != nil {
			return err
		}
		if visible {
			return nil
		}
	} else {
		c.Menu = ui.NewCompletionMenu(c.nvim)
	}

	c.CmpCtx, err = types.NewCompleteContext(c.nvim, e.Buffer)
	if err != nil {
		return err
	}
	defer c.CmpCtx.CancelFunc()

	if c.CmpCtx.Mode.Mode[0] != 'i' || len(c.CmpCtx.LineBefore) < 2 {
		return nil
	}

	c.CmpCtx.ResultChan = make(chan *ltyp.CompletionList, len(c.sources))
	for i := range c.sources {
		go c.sources[i].Complete(c.CmpCtx)
	}

	results := make([]*ltyp.CompletionList, 0)
	timeout := time.NewTicker(time.Millisecond * 100)
	func() {
		for {
			select {
			case itemList := <-c.CmpCtx.ResultChan:
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

	words := ltyp.CompletionList{}
	for i := range results {
		if results[i] == nil || results[i].Len() == 0 {
			continue
		}
		words.Merge(results[i])
	}
	if words.Len() == 1 && words.Items[0].Word == string(c.CmpCtx.LineBefore) {
		return nil
	}
	c.CmpCtx.CompletionList = &words
	// sort.Sort(words)
	// c.logger.Debug().Interface("Bufnr", e.Buffer).Interface("Words", words).Msg("BeforeCompleteCall")
	// c.nvim.Call("complete", nil, ctx.StartCol+1, words)
	// c.logger.Debug().Msg("AfterCompleteCall")
	pos, err := lnvim.GetScreenCursor(c.nvim)
	if err != nil {
		c.logger.Error().Err(err).Msg("GetScreenCursor")
		return nil
	}
	err = c.Menu.Open(&words, &lnvim.WinPos{X: pos.X - float64(c.CmpCtx.Cursor[1]-c.CmpCtx.StartCol), Y: pos.Y})
	if err != nil {
		c.logger.Error().Err(err).Msg("OpenMenuError")
	}
	return nil
}
