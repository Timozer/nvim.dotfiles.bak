package cmn

type CfgPluginItem struct {
	Type  string      `msgpack:"type"`
	Path  string      `msgpack:"path"`
	Opt   bool        `msgpack:"opt"`
	Event []string    `msgpack:"event"`
	SetUp interface{} `msgpack:"setup"`
}

type CfgLog struct {
	Dir   string `msgpack:"dir"`
	Level string `msgpack:"level"`
}

type CfgPlugin struct {
	InstallPath string                   `msgpack:"install_path"`
	CompilePath string                   `msgpack:"compile_path"`
	Plugins     map[string]CfgPluginItem `msgpack:"plugins"`
}

type Config struct {
	Log    CfgLog    `msgpack:"log"`
	Plugin CfgPlugin `msgpack:"plugin"`
}
