package lib

type CfgLog struct {
	Dir        string `msgpack:"dir"`
	Level      string `msgpack:"level"`
	MaxSize    int    `msgpack:"max_size"` // megabytes
	MaxBackups int    `msgpack:"max_backups"`
	MaxAge     int    `msgpack:"max_age"`
	Compress   bool   `msgpack:"compress"`
}
