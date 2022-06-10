package types

import (
	"context"
	"nvmgo/lib"

	"github.com/google/uuid"
	"github.com/neovim/go-client/nvim"
)

type NvimLspCompletionResp struct {
	ReqId  string             `msgpack:"req_id"`
	Err    interface{}        `msgpack:"err"`
	Result *LspCompletionList `msgpack:"result"`
}

type NvimCompletionItem struct {
	Word     string      `msgpack:"word"`
	Abbr     string      `msgpack:"abbr"`
	Menu     string      `msgpack:"menu"`
	Info     string      `msgpack:"info"`
	Kind     string      `msgpack:"kind"`
	Icase    int         `msgpack:"icase"`
	Equal    bool        `msgpack:"equal"`
	Dup      bool        `msgpack:"dup"`
	Empty    bool        `msgpack:"empty"`
	UserData interface{} `msgpack:"user_data"`

	Distance int `msgpack:"-"`
}

type NvimCompletionList []NvimCompletionItem

func (c NvimCompletionList) Len() int {
	return len(c)
}

func (c NvimCompletionList) Less(i, j int) bool {
	return c[i].Distance < c[j].Distance
}

func (c NvimCompletionList) Swap(i, j int) {
	c[i], c[j] = c[j], c[i]
}

type NvimCompletionContext struct {
	Bufnr         nvim.Buffer
	BufName       string
	FileType      string
	FileFormat    string
	TabStop       int
	ExpandTab     bool
	Cursor        [2]int
	CommentString string
	LineCount     int
	Mode          nvim.Mode
	CompleteInfos map[string]interface{}
	Line          string
	LineBefore    string
	StartCol      int
	LineAfter     string

	ReqId      string
	ResultChan chan *NvimCompletionList
	Context    context.Context
	CancelFunc context.CancelFunc
}

func NewCompleteContext(v *nvim.Nvim, buf nvim.Buffer) (*NvimCompletionContext, error) {
	c, cancel := context.WithCancel(context.Background())
	ctx := NvimCompletionContext{
		Bufnr:         buf,
		CompleteInfos: make(map[string]interface{}),
		ReqId:         uuid.NewString(),
		Context:       c,
		CancelFunc:    cancel,
	}

	b := v.NewBatch()
	b.Mode(&ctx.Mode)
	b.BufferName(buf, &ctx.BufName)
	b.BufferLineCount(buf, &ctx.LineCount)
	b.BufferOption(buf, "filetype", &ctx.FileType)
	b.BufferOption(buf, "fileformat", &ctx.FileFormat)
	b.BufferOption(buf, "tabstop", &ctx.TabStop)
	b.BufferOption(buf, "expandtab", &ctx.ExpandTab)
	b.BufferOption(buf, "commentstring", &ctx.CommentString)
	b.Call("complete_info", &ctx.CompleteInfos, []string{"mode", "pum_visible", "items", "selected"})
	b.WindowCursor(nvim.Window(0), &ctx.Cursor)
	err := b.Execute()
	if err != nil {
		return nil, err
	}

	lines, err := v.BufferLines(buf, ctx.Cursor[0]-1, ctx.Cursor[0], true)
	if err != nil {
		return nil, err
	}
	ctx.Line = string(lines[0])

	line_before := ctx.Line[:ctx.Cursor[1]]
	before := make([]byte, 0)
	for i := len(line_before) - 1; i >= 0; i-- {
		if lib.IsSpace(line_before[i]) {
			break
		}
		before = append(before, line_before[i])
	}
	before = lib.ReverseBytes(before)
	ctx.LineBefore = string(before)
	ctx.StartCol = len(line_before) - len(before)

	// line_after := line[ctx.Cursor[1]:]
	// after := make([]byte, 0)
	// for i := 0; i < len(line_after); i++ {
	// 	if common.IsSpace(line_after[i]) {
	// 		break
	// 	}
	// 	after = append(after, line_after[i])
	// }
	// endCol := len(line_before) + len(after)

	return &ctx, err
}
