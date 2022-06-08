package types

type CfgPlugin struct {
	InstallPath string    `msgpack:"install_path"`
	CompilePath string    `msgpack:"compile_path"`
	Plugins     []*Plugin `msgpack:"plugins"`
}

type Config struct {
	Plugin CfgPlugin `msgpack:"plugin"`
}
