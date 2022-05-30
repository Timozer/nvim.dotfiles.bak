package common

import (
    "fmt"
    "io"

	"github.com/rs/zerolog"
	"gopkg.in/natefinch/lumberjack.v2"
)

var (
	gLogger *zerolog.Logger
)

func InitLogger() {
	var logwriters []io.Writer
	// logwriters = append(logwriters, zerolog.ConsoleWriter{Out: os.Stdout})
	logwriters = append(logwriters, &lumberjack.Logger{
		Filename:   "logs/gvcmp.log",
		MaxSize:    1, // megabytes
		MaxBackups: 3,
		MaxAge:     28,   //days
		Compress:   true, // disabled by default
	})
	multiWriters := io.MultiWriter(logwriters...)

	logger := zerolog.New(multiWriters).With().Timestamp().Caller().Logger().Level(zerolog.DebugLevel)
	gLogger = &logger
}

func GetLogger() *zerolog.Logger {
    if gLogger == nil {
        panic(fmt.Errorf("global logger not init"))
    }
    return gLogger
}
