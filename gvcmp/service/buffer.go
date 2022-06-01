package service

import (
"fmt"
    "context"
    "sort"
    "os"
    "strings"
        "sync"
    "gvcmp/common"
	"github.com/neovim/go-client/nvim"
        "github.com/yanyiwu/gojieba"
)

type Event struct {
    Type string
    Data interface{}
}

type Buffer struct {
    Service

    nvim *nvim.Nvim

    words map[nvim.Buffer][]string
    eventChan chan *Event
    eventHandlers map[string]func(interface{}) error

    inited bool
}

var (
    gBufferIns  *Buffer
    gBufferOnce sync.Once
)

func GetBufferIns() *Buffer {
    gBufferOnce.Do(func() {
        gBufferIns = &Buffer{inited: false}
    })
    return gBufferIns
}

func (b *Buffer) Init(v *nvim.Nvim) error {
    b.nvim = v
    b.words = make(map[nvim.Buffer][]string)
    b.eventChan = make(chan *Event, 1000)
    b.eventHandlers = make(map[string]func(interface{}) error)
    b.eventHandlers["BufEnter"] = b.BufEnter
    b.inited = true
    return nil
}

func (b *Buffer) SendEvent(e *Event) {
    b.eventChan <- e
}

func (b *Buffer) Serve(ctx context.Context) {
    if !b.inited {
        panic(fmt.Errorf("buffer service is not init before call Serve func"))
    }

    logger := common.GetLogger()
    logger.Info().Msg("BufferService Start")
    defer logger.Info().Msg("BufferService End")

    for {
        select {
        case <- ctx.Done():
            logger.Info().Msg("BufferService Done")
            return
        case e := <- b.eventChan:
            logger.Debug().Interface("Event", e).Msg("ReceiveEvent")
            b.ProcessEvent(e)
        default:
        }
    }
}

func (b *Buffer) ProcessEvent(e *Event) {
    logger := common.GetLogger()
    err := b.eventHandlers[e.Type](e.Data)
    if err != nil {
        logger.Error().Err(err).Msg("ProcessEvent")
    }
}

func (b *Buffer) GetBufWords(buf nvim.Buffer) []string {
    return b.words[buf]
}

func Filter(lst []string, cond func(string) bool) []string{
    var r []string

    for i := range lst {
        if cond(lst[i]) {
            r = append(r, lst[i])
        }
    }

    return r
}

func (b *Buffer) BufEnter(data interface{}) error {
    logger := common.GetLogger()
    defer func() {
        if p := recover(); p != nil {
            logger.Error().Msg(fmt.Sprintf("%v\n", p))
            os.Exit(1)
        }
    }()

    bufnr, _ := data.(nvim.Buffer)
    lineCount, err := b.nvim.BufferLineCount(bufnr)
    if err != nil {
        logger.Error().Err(err).Msg("BufEnter")
        return err
    }
    lines, err := b.nvim.BufferLines(bufnr, 0, lineCount, true)
    if err != nil {
        logger.Error().Err(err).Msg("BufEnter")
        return err
    }

    jieba := gojieba.NewJieba()
    defer jieba.Free()

    words := make([]string, 0)
    for i := range lines {
        words = append(words, jieba.Cut(string(lines[i]), true)...)
    }

    specialStr := " \t\r\n~`!@#$%^&*()_+-={}[]|\\;:'\"<>,.?/"
    if len(words) > 0 {
        sort.Strings(words)
        i := 0
        for j := range words {
            if words[i] != words[j] {
                i++
                words[i] = words[j]
            }
        }
        words = words[:i + 1]
        i = 0
        for j := range words {
            if strings.Contains(specialStr, words[j]) {
                continue
            }
            words[i] = words[j]
            i++
        }
        words = words[:i+1]
    }
    logger.Debug().Int("Bufnr", int(bufnr)).Interface("Words", words).Msg("BufEnter")
    b.words[bufnr] = words
    return nil

}
