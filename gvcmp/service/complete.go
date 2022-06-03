package service

import (
	"context"
	"fmt"
	"os"
	"sort"
	"sync"

	"gvcmp/common"

	"github.com/neovim/go-client/nvim"
	"github.com/rs/zerolog"
)

type Complete struct {
	Service

	nvim *nvim.Nvim

	eventChan chan *nvim.BufLinesEvent

	logger *zerolog.Logger
	inited bool
}

var (
	gCompleteIns  *Complete
	gCompleteOnce sync.Once
)

func GetCompleteIns() *Complete {
	gCompleteOnce.Do(func() {
		gCompleteIns = &Complete{inited: false}
	})
	return gCompleteIns
}

func (c *Complete) Init(v *nvim.Nvim) error {
	c.nvim = v
	c.eventChan = make(chan *nvim.BufLinesEvent, 1000)
	c.logger = common.NewLogger("logs/service/complete.log")
	c.inited = true
	return nil
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

type CompleteItem struct {
	Word     string      `msgpack:"word"`
	Abbr     string      `msgpack:"abbr"`
	Menu     string      `msgpack:"menu"`
	Info     string      `msgpack:"info"`
	Kind     string      `msgpack:"kind"`
	Icase    int         `msgpack:"icase"`
	Equal    bool        `msgpack:"equal"`
	Dup      bool        `msgpack:"dup"`
	Empty    bool        `msgpack:"empty"`
	UserData interface{} `msgpack:"user_data"`

	Distance int `msgpack:"-"`
}

type CompleteItems []CompleteItem

func (c CompleteItems) Len() int {
	return len(c)
}

func (c CompleteItems) Less(i, j int) bool {
	return c[i].Distance < c[j].Distance
}

func (c CompleteItems) Swap(i, j int) {
	c[i], c[j] = c[j], c[i]
}

type CompleteContext struct {
	Bufnr         nvim.Buffer
	BufName       string
	FileType      string
	FileFormat    string
	TabStop       int
	ExpandTab     bool
	Cursor        [2]int
	CommentString string
	LineCount     int
	Mode          nvim.Mode
	CompleteInfos map[string]interface{}
}

func ReverseBytes(src []byte) []byte {
	length := len(src)
	ret := make([]byte, len(src))
	for i := 0; i < length; i++ {
		ret[i] = src[length-1-i]
	}
	return ret
}

func (c *Complete) GetCompleteContext(buf nvim.Buffer) (*CompleteContext, error) {
	ctx := CompleteContext{
		Bufnr:         buf,
		CompleteInfos: make(map[string]interface{}),
	}

	b := c.nvim.NewBatch()
	b.Mode(&ctx.Mode)
	b.BufferName(buf, &ctx.BufName)
	b.BufferLineCount(buf, &ctx.LineCount)
	b.BufferOption(buf, "filetype", &ctx.FileType)
	b.BufferOption(buf, "fileformat", &ctx.FileFormat)
	b.BufferOption(buf, "tabstop", &ctx.TabStop)
	b.BufferOption(buf, "expandtab", &ctx.ExpandTab)
	b.BufferOption(buf, "commentstring", &ctx.CommentString)
	b.Call("complete_info", &ctx.CompleteInfos, []string{"mode", "pum_visible", "items", "selected"})
	b.WindowCursor(nvim.Window(0), &ctx.Cursor)
	err := b.Execute()

	return &ctx, err
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

	ctx, err := c.GetCompleteContext(e.Buffer)
	if err != nil {
		return err
	}
	c.logger.Debug().Interface("Context", ctx).Msg("ProcessEvent")

	if pum_visible, _ := ctx.CompleteInfos["pum_visible"].(int64); pum_visible == 1 {
		return nil
	}
	if ctx.Mode.Mode[0] != 'i' {
		return nil
	}

	lines, err := c.nvim.BufferLines(e.Buffer, ctx.Cursor[0]-1, ctx.Cursor[0], true)
	if err != nil {
		c.logger.Error().Err(err).Msg("BufferLines")
		return err
	}
	line := string(lines[0])
	line_before := line[:ctx.Cursor[1]]
	// line_after := line[ctx.Cursor[1]:]

	before := make([]byte, 0)
	for i := len(line_before) - 1; i >= 0; i-- {
		if common.IsSpace(line_before[i]) {
			break
		}
		before = append(before, line_before[i])
	}
	before = ReverseBytes(before)
	startCol := len(line_before) - len(before)

	// after := make([]byte, 0)
	// for i := 0; i < len(line_after); i++ {
	// 	if common.IsSpace(line_after[i]) {
	// 		break
	// 	}
	// 	after = append(after, line_after[i])
	// }
	// endCol := len(line_before) + len(after)

	if len(before) < 2 {
		return nil
	}

	c.logger.Debug().Interface("CompleteMode", ctx.CompleteInfos["mode"]).Msg("ProcessEvents")

	words := GetBufferIns().FuzzyFind(e.Buffer, string(before))
	if words == nil || (words.Len() == 1 && words[0].Word == string(before)) {
		return nil
	}
	sort.Sort(words)
	c.logger.Debug().Interface("Bufnr", e.Buffer).Interface("Words", words).Msg("BeforeCompleteCall")
	c.nvim.Call("complete", nil, startCol+1, words)
	c.logger.Debug().Msg("AfterCompleteCall")
	return nil
}

var (
	CompleteModes = []string{"", "eval", "function", "ctrl_x"}
)
