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

// type CompleteInfo struct {
//     Mode       string         `msgpack:"mode,omitempty"`
//     PumVisible int            `msgpack:"pum_visible,omitempty"`
//     Selected   int64          `msgpack:"selected,omitempty"`
//     Items      []CompleteItem `msgpack:",array"`
// }

func (c *Complete) ProcessEvent(e *nvim.BufLinesEvent) error {
    logger := common.GetLogger()
    logger.Info().Msg("ProcessEvent Start")

    ftype := ""
    mode := nvim.Mode{}
    infos := make(map[string]interface{}, 0)

    b := c.nvim.NewBatch()
    b.BufferOption(e.Buffer, "filetype", &ftype)
    b.Mode(&mode)
    b.Call("complete_info", &infos, []string{"mode", "pum_visible", "items", "selected"})
    if err := b.Execute(); err != nil {
        return err
    }

    logger.Debug().Str("Buffer FileType", ftype).Interface("Mode", mode).Interface("Infos", infos).Msg("BaseInfo")

    if infos["pum_visible"] == 1 {
        return nil
    }

    if mode.Mode[0] == 'i' && (infos["mode"] == "" || infos["mode"] == "eval" ||
        infos["mode"] == "function" || infos["mode"] == "ctrl_x") {
        c.nvim.Call("complete", nil, 1, []string{"Jan", "Feb", "Mar", "Apr", "May"})
    }
    return nil
}
