package handler

import (
    "gvcmp/common"
	"github.com/neovim/go-client/nvim"
	"github.com/neovim/go-client/nvim/plugin"
)

func Register(p *plugin.Plugin) error {
    logger := common.GetLogger()
    // Commands
    p.HandleCommand(&plugin.CommandOptions{Name: "ExCmd", NArgs: "?", Bang: true, Eval: "[getcwd(),bufname()]"},
    func(args []string, bang bool, eval *cmdEvalExample) {
        // drint("called command ExCmd")
        logger.Debug().Msg("called command ExCmd")
        exCmd(p, args, bang, eval)
    })

    // AutoCommands
    p.HandleAutocmd(&plugin.AutocmdOptions{Event: "BufEnter", Group: "GVCmp", Pattern: "*"}, BufEnter(p.Nvim))
    p.HandleAutocmd(&plugin.AutocmdOptions{Event: "InsertEnter", Group: "GVCmp", Pattern: "*"}, BufEnter(p.Nvim))
    p.HandleAutocmd(&plugin.AutocmdOptions{Event: "BufAdd", Group: "ExmplNvGoClientGrp", Pattern: "*", Eval: "*"},
    func(eval *autocmdEvalExample) {
        logger.Debug().Str("CWD", eval.Cwd).Msg("CWD")
    })

    // Functions
    p.HandleFunction(&plugin.FunctionOptions{Name: "Upper"},
    func(args []string) (string, error) {
        logger.Debug().Msg("calling upper")
        return upper(p, args[0]), nil
    })
    p.HandleFunction(&plugin.FunctionOptions{Name: "UpperCwd", Eval: "getcwd()"},
    func(args []string, dir string) (string, error) {
        logger.Debug().Msg("calling upppercwd")
        return upper(p, dir), nil
    })
    p.HandleFunction(&plugin.FunctionOptions{Name: "ShowThings", Eval: "[getcwd(),argc()]"},
    func(args []string, eval *someArgs) ([]string, error) {
        logger.Debug().Msg("calling ShowThings")
        return returnArgs(p, eval)
    })
    p.HandleFunction(&plugin.FunctionOptions{Name: "GetVV"},
    func(args []string) ([]string, error) {
        logger.Debug().Msg("calling GetVV")
        return getvv(p, args[0])
    })
    p.HandleFunction(&plugin.FunctionOptions{Name: "ShowFirst"},
    func(args []string) (string, error) {
        logger.Debug().Msg("calling ShowFirst")
        return showfirst(p), nil
    })

    // Command Completion
    p.HandleCommand(&plugin.CommandOptions{Name: "CompleteThis", NArgs: "?", Complete: "customlist,CompleteThisC"},
    func() {
        logger.Debug().Msg("calling command CompleteThis")
    })
    p.HandleFunction(&plugin.FunctionOptions{Name: "CompleteThisC"},
    func(c *nvim.CommandCompletionArgs) ([]string, error) {
        logger.Debug().Msg("calling CompleteThisC")
        logger.Debug().Str("ArgLead", c.ArgLead).Msg("calling CompleteThisC")
        logger.Debug().Str("CmdLine", c.CmdLine).Msg("calling CompleteThisC")
        logger.Debug().Int("CursorPosStr", c.CursorPosString).Msg("calling CompleteThisC")
        return []string{"abc", "def", "ghi", "jkl"}, nil
    })

    // Buffer events (see :h api-buffer-updates for more); these special p.Handle events are
    // paired with the call to AttachBuffer in TurnOnEvents below
    p.Handle("nvim_buf_lines_event",
    func(e ...interface{}) {
        logger.Debug().Interface("Event", e).Msg("triggered buf lines event")
    })
    p.Handle("nvim_buf_changedtick_event",
    func(e ...interface{}) {
        logger.Debug().Interface("Event", e).Msg("triggerd changed tick event")
    })
    return nil
}

