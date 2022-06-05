package types

import "nvmgo/lib"

type Config struct {
	Log lib.CfgLog `msgpack:"log,omitempty"`
}
