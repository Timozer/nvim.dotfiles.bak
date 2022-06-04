package cmn

import (
	"io"

	"github.com/rs/zerolog"
	"gopkg.in/natefinch/lumberjack.v2"
)

func NewLogger(logfname string) *zerolog.Logger {
	var logwriters []io.Writer
	// logwriters = append(logwriters, zerolog.ConsoleWriter{Out: os.Stdout})
	logwriters = append(logwriters, &lumberjack.Logger{
		Filename:   logfname,
		MaxSize:    1, // megabytes
		MaxBackups: 3,
		MaxAge:     28,   //days
		Compress:   true, // disabled by default
	})
	multiWriters := io.MultiWriter(logwriters...)

	logger := zerolog.New(multiWriters).With().Timestamp().Caller().Logger().Level(zerolog.DebugLevel)
	return &logger
}
