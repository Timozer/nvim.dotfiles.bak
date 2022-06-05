package nvim

import "github.com/neovim/go-client/nvim"

func NvimNotifyWarn(v *nvim.Nvim, msg string) error {
	return NvimNotify(v, msg, nvim.LogWarnLevel)
}

func NvimNotifyInfo(v *nvim.Nvim, msg string) error {
	return NvimNotify(v, msg, nvim.LogInfoLevel)
}

func NvimNotifyTrace(v *nvim.Nvim, msg string) error {
	return NvimNotify(v, msg, nvim.LogTraceLevel)
}

func NvimNotifyError(v *nvim.Nvim, msg string) error {
	return NvimNotify(v, msg, nvim.LogErrorLevel)
}

func NvimNotifyDebug(v *nvim.Nvim, msg string) error {
	return NvimNotify(v, msg, nvim.LogDebugLevel)
}

func NvimNotify(v *nvim.Nvim, msg string, level nvim.LogLevel) error {
	return v.Notify(msg, level, map[string]interface{}{})
}
