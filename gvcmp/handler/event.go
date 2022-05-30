package handler

import(
    "gvcmp/common"
    "gvcmp/service"
	"github.com/neovim/go-client/nvim"
)

func BufLinesEventHandler(e ...interface{}) {
    logger := common.GetLogger()
    logger.Debug().Interface("Event", e).Msg("triggered buf lines event")

    event := &nvim.BufLinesEvent{LineData: []string{}}
    event.Buffer,      _ = e[0].(nvim.Buffer)
    event.Changetick,  _ = e[1].(int64)
    event.FirstLine,   _ = e[2].(int64)
    event.LastLine,    _ = e[3].(int64)
    lines, _ := e[4].([]interface{})
    for i := range lines {
        line, _ := lines[i].(string)
        event.LineData = append(event.LineData, line)
    }
    event.IsMultipart, _ = e[5].(bool)

    service.GetCompleteIns().SendEvent(event)
}

func BufChangedTickEventHandler(e ...interface{}) {
    logger := common.GetLogger()
    logger.Debug().Interface("Event", e).Msg("triggerd changed tick event")
}
