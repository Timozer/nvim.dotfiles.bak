package service

import (
    "context"
    "fmt"
    "sync"

    "gvcmp/common"
	"github.com/neovim/go-client/nvim"
)

type Complete struct {
    Service

    nvim *nvim.Nvim

    eventChan chan *nvim.BufLinesEvent

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

    logger := common.GetLogger()
    logger.Info().Msg("CompleteService Start")
    defer logger.Info().Msg("CompleteService End")

    for {
        select {
        case <- ctx.Done():
            logger.Info().Msg("CompleteService Done")
            return
        case e := <- c.eventChan:
            logger.Debug().Interface("Event", e).Msg("Receive BufLinesEvent")
            err := c.ProcessEvent(e)
            if err != nil {
                logger.Error().Err(err).Msg("ProcessEvent")
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
}

type CompleteContext struct {
    Bufnr nvim.Buffer
    BufName string
    FileType string
    FileFormat string
    TabStop int
    ExpandTab bool
    Cursor [2]int
    CommentString string
    LineCount int
}

func (c *Complete) ProcessEvent(e *nvim.BufLinesEvent) error {
    logger := common.GetLogger()
    logger.Info().Msg("ProcessEvent Start")

    mode := nvim.Mode{}
    ctx := CompleteContext{
        Bufnr: e.Buffer,
    }
    infos := make(map[string]interface{}, 0)

    b := c.nvim.NewBatch()
    b.Mode(&mode)
    b.BufferName(e.Buffer, &ctx.BufName)
    b.BufferLineCount(e.Buffer, &ctx.LineCount)
    b.BufferOption(e.Buffer, "filetype", &ctx.FileType)
    b.BufferOption(e.Buffer, "fileformat", &ctx.FileFormat)
    b.BufferOption(e.Buffer, "tabstop", &ctx.TabStop)
    b.BufferOption(e.Buffer, "expandtab", &ctx.ExpandTab)
    b.BufferOption(e.Buffer, "commentstring", &ctx.CommentString)
    b.Call("complete_info", &infos, []string{"mode", "pum_visible", "items", "selected"})
    b.WindowCursor(nvim.Window(0), &ctx.Cursor)
    if err := b.Execute(); err != nil {
        return err
    }

    logger.Debug().Interface("Mode", mode).Interface("Context", ctx).
        Interface("Infos", infos).Msg("BaseInfo")

    lines, err := c.nvim.BufferLines(e.Buffer, ctx.Cursor[0] - 1, ctx.Cursor[0], true)
    if err != nil {
        logger.Error().Err(err).Msg("BufferLines")
        return err
    }
    line := string(lines[0])
    line_before := line[:ctx.Cursor[1]]
    line_after := line[ctx.Cursor[1]:]

    if pum_visible, _ := infos["pum_visible"].(int64); pum_visible == 1 {
        return nil
    }

    if mode.Mode[0] == 'i' && (infos["mode"] == "" || infos["mode"] == "eval" ||
        infos["mode"] == "function" || infos["mode"] == "ctrl_x") {
        c.nvim.Call("complete", nil, ctx.Cursor[1], []string{"Jan", "Feb", "Mar", "Apr", "May"})
    }
    return nil
}
