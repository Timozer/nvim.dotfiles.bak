package handler

import (
	"gcmp/events"
	"gcmp/service"

	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

func Register(p *plugin.Plugin) error {
	// Commands
	p.HandleCommand(&plugin.CommandOptions{Name: "ExCmd", NArgs: "?", Bang: true, Eval: "[getcwd(),bufname()]"},
		func(args []string, bang bool, eval *cmdEvalExample) {
			exCmd(p, args, bang, eval)
		})

	// AutoCommands
	p.HandleAutocmd(&plugin.AutocmdOptions{Event: "BufEnter", Group: "GCmp", Pattern: "*"}, events.BufEnter(p.Nvim))
	p.HandleAutocmd(&plugin.AutocmdOptions{Event: "VimEnter", Group: "GCmp", Pattern: "*"}, events.VimEnter(p.Nvim))

	p.HandleAutocmd(&plugin.AutocmdOptions{Event: "BufWritePost", Group: "GCmp", Pattern: "*", Eval: "expand(\"<abuf>\")"}, events.BufWritePost(p.Nvim))
	p.HandleAutocmd(&plugin.AutocmdOptions{Event: "ModeChanged", Group: "GCmp", Pattern: "[ic]:*"}, events.ModeChanged(p.Nvim))

	// GcmpOnLspAttach
	p.HandleFunction(&plugin.FunctionOptions{Name: "GcmpOnLspAttach"}, GcmpOnLspAttach(p.Nvim))

	// Functions
	p.HandleFunction(&plugin.FunctionOptions{Name: "ShowThings", Eval: "[getcwd(),argc()]"},
		func(args []string, eval *someArgs) ([]string, error) {
			return returnArgs(p, eval)
		})
	p.HandleFunction(&plugin.FunctionOptions{Name: "LspCompletionResp"}, service.GetLspIns().CompletionResp)

	p.HandleFunction(&plugin.FunctionOptions{Name: "CmpMenuVisible"}, CmpMenuVisible(p.Nvim))
	p.HandleFunction(&plugin.FunctionOptions{Name: "CmpMenuNextItem"}, CmpMenuNextItem(p.Nvim))
	p.HandleFunction(&plugin.FunctionOptions{Name: "CmpMenuPrevItem"}, CmpMenuPrevItem(p.Nvim))

	// Command Completion
	p.HandleCommand(&plugin.CommandOptions{Name: "CompleteThis", NArgs: "?", Complete: "customlist,CompleteThisC"},
		func() {
		})
	p.HandleFunction(&plugin.FunctionOptions{Name: "CompleteThisC"},
		func(c *nvim.CommandCompletionArgs) ([]string, error) {
			return []string{"abc", "def", "ghi", "jkl"}, nil
		})

	p.Handle("nvim_buf_lines_event", BufLinesEventHandler)
	p.Handle("nvim_buf_changedtick_event", BufChangedTickEventHandler)

	return nil
}
