package lib

import (
	"io"

	"github.com/rs/zerolog"
	"gopkg.in/natefinch/lumberjack.v2"
)

func NewLogger(fname string) *zerolog.Logger {
	var logwriters []io.Writer
	// logwriters = append(logwriters, zerolog.ConsoleWriter{Out: os.Stdout})
	logwriters = append(logwriters, &lumberjack.Logger{
		Filename:   fname,
		MaxSize:    10, // megabytes
		MaxBackups: 2,
		MaxAge:     5,     //days
		Compress:   false, // disabled by default
	})
	multiWriters := io.MultiWriter(logwriters...)

	logger := zerolog.New(multiWriters).With().Timestamp().Caller().Logger().Level(zerolog.DebugLevel)
	return &logger
}
