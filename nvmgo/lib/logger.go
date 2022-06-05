package lib

import (
	"io"
	"path/filepath"

	"github.com/rs/zerolog"
	"gopkg.in/natefinch/lumberjack.v2"
)

func NewLogger(fname string, cfg *CfgLog) *zerolog.Logger {
	var logwriters []io.Writer
	// logwriters = append(logwriters, zerolog.ConsoleWriter{Out: os.Stdout})
	maxSize := 1
	maxBackups := 3
	maxAge := 1
	dir := ""
	compress := false
	level := zerolog.DebugLevel
	if cfg != nil {
		if len(cfg.Dir) > 0 {
			dir = cfg.Dir
		}
		if cfg.MaxSize > 0 {
			maxSize = cfg.MaxSize
		}
		if cfg.MaxBackups > 0 {
			maxBackups = cfg.MaxBackups
		}
		if cfg.MaxAge > 0 {
			maxAge = cfg.MaxAge
		}
		compress = cfg.Compress
		l, err := zerolog.ParseLevel(cfg.Level)
		if err == nil {
			level = l
		}
	}

	logwriters = append(logwriters, &lumberjack.Logger{
		Filename:   filepath.Join(dir, fname),
		MaxSize:    maxSize, // megabytes
		MaxBackups: maxBackups,
		MaxAge:     maxAge,   //days
		Compress:   compress, // disabled by default
	})
	multiWriters := io.MultiWriter(logwriters...)

	logger := zerolog.New(multiWriters).With().Timestamp().Caller().Logger().Level(level)
	return &logger
}
