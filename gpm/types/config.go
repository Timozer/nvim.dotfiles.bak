package types

type CfgLog struct {
	Dir   string `msgpack:"dir"`
	Level string `msgpack:"level"`
}

type CfgPlugin struct {
	InstallPath string    `msgpack:"install_path"`
	CompilePath string    `msgpack:"compile_path"`
	Plugins     []*Plugin `msgpack:"plugins"`
}

type Config struct {
	Log    CfgLog    `msgpack:"log"`
	Plugin CfgPlugin `msgpack:"plugin"`
}
