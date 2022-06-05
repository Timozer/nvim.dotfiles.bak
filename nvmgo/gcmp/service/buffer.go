package service

import (
	"context"
	"database/sql"
	"fmt"
	"nvmgo/lib"
	"os"
	"strconv"
	"sync"

	"github.com/lithammer/fuzzysearch/fuzzy"
	_ "github.com/mattn/go-sqlite3"
	"github.com/neovim/go-client/nvim"
	"github.com/rs/zerolog"
	"github.com/yanyiwu/gojieba"
)

type BufferWords struct {
	data [][]string
}

func NewBufferWords() *BufferWords {
	return &BufferWords{
		data: make([][]string, 0),
	}
}

func (b *BufferWords) DelLines(s, e int64) {
	if int64(len(b.data)-1) < s || e < 0 {
		return
	}
	if s < 0 {
		s = 0
	}
	if e > int64(len(b.data)) {
		e = int64(len(b.data))
	}
	b.data = append(b.data[:s], b.data[e:]...)
}

func (b *BufferWords) InsertLine(idx int64, words []string) error {
	if idx < 0 {
		return fmt.Errorf("invalid index: %d", idx)
	}
	if idx < int64(len(b.data)) {
		b.data = append(b.data[:idx+1], b.data[idx:]...)
		b.data[idx] = words
	}
	for i := idx - int64(len(b.data)); i > 0; i-- {
		b.data = append(b.data, nil)
	}
	b.data = append(b.data, words)
	return nil
}

func (b *BufferWords) FuzzyFind(word string) CompleteItems {
	ret := make(CompleteItems, 0)
	for i := range b.data {
		targets := fuzzy.RankFindFold(word, b.data[i])
		for j := range targets {
			ret = append(ret, CompleteItem{
				Word:     targets[j].Target,
				Distance: targets[j].Distance,
				Menu:     "BUF",
			})
		}
	}
	return ret
}

func (b *BufferWords) LogData(logger *zerolog.Logger) {
	for i := range b.data {
		logger.Debug().Int("Line", i).Interface("Words", b.data[i]).Msg("BufferWords")
	}
}

type Buffer struct {
	Service

	nvim *nvim.Nvim

	words         map[nvim.Buffer]*BufferWords
	eventChan     chan *Event
	eventHandlers map[string]func(interface{}) error

	db     *sql.DB
	logger *zerolog.Logger

	inited bool
}

func (b *Buffer) initDB() error {
	var err error
	b.db, err = sql.Open("sqlite3", "buffer.db")
	return err
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
	b.words = make(map[nvim.Buffer]*BufferWords)
	b.eventChan = make(chan *Event, 100)
	b.eventHandlers = make(map[string]func(interface{}) error)
	b.eventHandlers["BufLines"] = b.BufLines
	b.logger = lib.NewLogger("logs/service/buffer.log")
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

func (b *Buffer) FuzzyFind(buf nvim.Buffer, word string) CompleteItems {
	b.logger.Debug().Interface("Bufnr", buf).Msg("FuzzyFind")
	bufwords, ok := b.words[buf]
	if !ok {
		b.logger.Debug().Interface("Bufnr", buf).Str("buffer not inited", "").Msg("FuzzyFind")
		return nil
	}
	return bufwords.FuzzyFind(word)
}

func (b *Buffer) ProcessEvent(e *Event) {
	err := b.eventHandlers[e.Type](e.Data)
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

func (b *Buffer) BufLines(data interface{}) error {
	b.logger.Debug().Msg("BufLines Start")
	defer b.logger.Debug().Msg("BufLines End")
	defer func() {
		if p := recover(); p != nil {
			b.logger.Error().Msg(fmt.Sprintf("%v\n", p))
			os.Exit(1)
		}
	}()

	buflines, _ := data.(*nvim.BufLinesEvent)

	bufwords, ok := b.words[buflines.Buffer]
	if !ok {
		bufwords = NewBufferWords()
		b.words[buflines.Buffer] = bufwords
		b.logger.Debug().Interface("Burnr", buflines.Buffer).Msg("BufLines AddBuf")
	} else {
		endIdx := buflines.LastLine
		if endIdx == -1 {
			endIdx = int64(len(buflines.LineData))
		}
		bufwords.DelLines(buflines.FirstLine, endIdx)
	}

	jieba := gojieba.NewJieba()
	defer jieba.Free()

	b.logger.Debug().Interface("Burnr", buflines.Buffer).Msg("BufLines Before AddWords")
	for i := range buflines.LineData {
		words := jieba.Cut(buflines.LineData[i], true)
		words = Filter(words, func(word string) bool {
			if len(word) < 3 {
				return true
			}
			if _, err := strconv.ParseFloat(word, 64); err == nil {
				return true
			}
			return false
		})

		b.logger.Debug().Interface("Burnr", buflines.Buffer).Interface("Words", words).Msg("BufLines AddWords")
		err := bufwords.InsertLine(buflines.FirstLine+int64(i), words)
		if err != nil {
			return err
		}
	}
	b.logger.Debug().Interface("Burnr", buflines.Buffer).Msg("BufLines After AddWords")

	return nil
}
