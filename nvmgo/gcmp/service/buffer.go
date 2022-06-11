package service

import (
	"context"
	"fmt"
	"gcmp/types"
	"nvmgo/lib"
	lnvim "nvmgo/lib/nvim"
	ltyp "nvmgo/lib/types"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"sync"

	"github.com/lithammer/fuzzysearch/fuzzy"
	"github.com/neovim/go-client/nvim"
	"github.com/yanyiwu/gojieba"
)

type Buffer struct {
	Service

	words         sync.Map
	eventChan     chan *types.Event
	eventHandlers map[string]func(interface{}) error
}

var (
	gBufferIns  *Buffer
	gBufferOnce sync.Once
)

func GetBufferIns() *Buffer {
	gBufferOnce.Do(func() {
		gBufferIns = &Buffer{}
		gBufferIns.inited = false
	})
	return gBufferIns
}

func (b *Buffer) Init(v *nvim.Nvim) error {
	b.nvim = v
	b.eventChan = make(chan *types.Event, 100)
	b.eventHandlers = make(map[string]func(interface{}) error)
	b.eventHandlers["BufEnter"] = b.BufEnter
	b.eventHandlers["BufWritePost"] = b.BufWritePost
	b.eventHandlers["BufWipeout"] = b.BufWipeout
	b.logger = lib.NewLogger(filepath.Join(lib.GetProgramDir(), "service/buffer.log"))
	b.inited = true
	return nil
}

func (b *Buffer) SendEvent(e *types.Event) {
	b.eventChan <- e
}

func (b *Buffer) Serve(ctx context.Context) {
	if !b.inited {
		panic(fmt.Errorf("buffer service is not init before call Serve func"))
	}

	b.logger.Info().Msg("BufferService Start")
	defer b.logger.Info().Msg("BufferService End")

	for {
		select {
		case <-ctx.Done():
			b.logger.Info().Msg("BufferService Done")
			return
		case e := <-b.eventChan:
			b.logger.Debug().Interface("Event", e).Msg("ReceiveEvent")
			b.ProcessEvent(e)
		default:
		}
	}
}

func (b *Buffer) Complete(ctx *types.NvimCompletionContext) {
	b.logger.Debug().Str("ReqId", ctx.ReqId).Msg("BufferComplete Start")
	val, ok := b.words.Load(ctx.Bufnr)
	if !ok {
		b.logger.Debug().Str("ReqId", ctx.ReqId).Str("buffer not build index", "").Msg("BufferComplete")
		ctx.ResultChan <- nil
		return
	}

	words, _ := val.([]string)

	ret := ltyp.CompletionList{}
	targets := fuzzy.RankFindFold(ctx.LineBefore, words)
	for j := range targets {
		ret.AddItem(&ltyp.CompletionItem{
			Icon:     "",
			Word:     targets[j].Target,
			Kind:     "",
			Source:   "BUF",
			Distance: targets[j].Distance,
		})
	}
	ctx.ResultChan <- &ret
	b.logger.Debug().Str("ReqId", ctx.ReqId).Msg("BufferComplete End")
}

func (b *Buffer) ProcessEvent(e *types.Event) {
	h, ok := b.eventHandlers[e.Type]
	if !ok {
		b.logger.Warn().Str("EventType", e.Type).Msg("Unsupported Event")
		return
	}
	err := h(e.Data)
	if err != nil {
		b.logger.Error().Err(err).Msg("ProcessEvent")
	}
}

func Filter(lst []string, cond func(string) bool) []string {
	var r []string

	for i := range lst {
		if !cond(lst[i]) {
			r = append(r, lst[i])
		}
	}

	return r
}

func (b *Buffer) BuildIndex(buf nvim.Buffer) error {
	defer func() {
		if p := recover(); p != nil {
			b.logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()

	count, err := b.nvim.BufferLineCount(buf)
	if err != nil {
		b.logger.Error().Err(err).Msg("BufferLineCount")
		lnvim.NvimNotifyError(b.nvim, fmt.Sprintf("get buffer line count fail, err: %s", err))
		return err
	}
	b.logger.Debug().Int("LineCount", count).Msg("BufferLineCount")
	lines, err := b.nvim.BufferLines(buf, 0, -1, false)
	if err != nil {
		b.logger.Error().Err(err).Msg("BufferLines")
		lnvim.NvimNotifyError(b.nvim, fmt.Sprintf("get buffer lines fail, err: %s", err))
		return err
	}

	jieba := gojieba.NewJieba()
	defer jieba.Free()

	words := make([]string, 0)
	for i := range lines {
		words = append(words, jieba.Cut(string(lines[i]), true)...)
	}

	// 过滤
	words = Filter(words, func(word string) bool {
		if len(word) < 3 {
			return true
		}
		if _, err := strconv.ParseFloat(word, 64); err == nil {
			return true
		}
		return false
	})

	// 排序
	sort.Strings(words)

	// 去重
	words = DeDup(words)

	b.words.Store(buf, words)
	return nil
}

func DeDup(arr []string) []string {
	length := len(arr)
	if length == 0 {
		return arr
	}

	j := 0
	for i := 1; i < length; i++ {
		if arr[i] != arr[j] {
			j++
			if j < i {
				arr[i], arr[j] = arr[j], arr[i]
			}
		}
	}

	return arr[:j+1]
}

func (b *Buffer) BufEnter(data interface{}) error {
	buf, _ := data.(nvim.Buffer)

	buflisted := false
	buftype := ""
	batch := b.nvim.NewBatch()
	batch.BufferOption(buf, "buflisted", &buflisted)
	batch.BufferOption(buf, "buftype", &buftype)
	if err := batch.Execute(); err != nil {
		lnvim.NvimNotifyError(b.nvim, err.Error())
		return nil
	}

	if !buflisted || buftype == "terminal" {
		return nil
	}
	// TODO: check buffer size, dont build index for large buffer
	// :h wordcount()

	return b.BuildIndex(buf)
}

func (b *Buffer) BufWritePost(data interface{}) error {
	buf, _ := data.(nvim.Buffer)
	if _, ok := b.words.Load(buf); !ok {
		return nil
	}
	return b.BuildIndex(buf)
}
func (b *Buffer) BufWipeout(data interface{}) error {
	buf, _ := data.(nvim.Buffer)
	b.words.Delete(buf)
	return nil
}
