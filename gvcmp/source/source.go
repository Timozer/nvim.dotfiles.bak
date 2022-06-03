package source

import (
	"io"
	"sync"

	"github.com/neovim/go-client/nvim"
	"github.com/rs/zerolog"
	"gopkg.in/natefinch/lumberjack.v2"
)

type SourceInterface interface {
	Complete(string, chan<- CompleteItem)
}

type SourceManager struct {
	Nvim    *nvim.Nvim
	Sources []SourceInterface

	logger *zerolog.Logger
}

func NewSourceManager() *SourceManager {
	sm := &SourceManager{}
	sm.initLogger()
	return sm
}

func (s *SourceManager) initLogger() {
	var logwriters []io.Writer
	// logwriters = append(logwriters, zerolog.ConsoleWriter{Out: os.Stdout})
	logwriters = append(logwriters, &lumberjack.Logger{
		Filename:   "logs/source_manager.log",
		MaxSize:    100, // megabytes
		MaxBackups: 3,
		MaxAge:     7,    //days
		Compress:   true, // disabled by default
	})
	multiWriters := io.MultiWriter(logwriters...)

	logger := zerolog.New(multiWriters).With().Timestamp().Caller().Logger().Level(zerolog.DebugLevel)
	s.logger = &logger
}

type CompleteItem struct {
	Word     string      `msgpack:"word"`
	Abbr     string      `msgpack:"abbr"`
	Menu     string      `msgpack:"menu"`
	Info     string      `msgpack:"info"`
	Kind     string      `msgpack:"kind"`
	Icase    int         `msgpack:"icase"`
	Equal    int         `msgpack:"equal"`
	Dup      int         `msgpack:"dup"`
	Empty    int         `msgpack:"empty"`
	UserData interface{} `msgpack:"user_data"`

	Distance int `msgpack:"-"`
}

func (s *SourceManager) Complete(prefix string) []CompleteItem {
	itemChan := make(chan CompleteItem, 1000)
	wg := sync.WaitGroup{}
	for i := range s.Sources {
		wg.Add(1)
		go func(src SourceInterface) {
			defer wg.Done()
			src.Complete(prefix, itemChan)
		}(s.Sources[i])
	}
	wg.Wait()
	return nil
}
