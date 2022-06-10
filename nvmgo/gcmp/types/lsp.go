package types

type LspCompletionList struct {
	IsIncomplete bool                       `msgpack:"isIncomplete"`
	ItemDefaults *LspCompletionItemDefaults `msgpack:"itemDefaults"`
	Items        []LspCompletionItem        `msgpack:"items"`
}

type LspPosition struct {
	Line      int `msgpack:"line"`
	Character int `msgpack:"character"`
}

type LspRange struct {
	Start LspPosition `msgpack:"start"`
	End   LspPosition `msgpack:"end"`
}

type LspEditRange struct {
	LspRange
	Insert  *LspRange `msgpack:"insert"`
	Replace *LspRange `msgpack:"replace"`
}

type LspCompletionItemDefaults struct {
	CommitCharacters []string      `msgpack:"commitCharacters"`
	EditRange        *LspEditRange `msgpack:"editRange"`
	InsertTextFormat int           `msgpack:"insertTextFormat"`
	InsertTextMode   int           `msgpack:"insertTextMode"`
	Data             interface{}   `msgpack:"data"`
}

const (
	LspInsertTextFormatPlainText = 1
	LspInsertTextFormatSnippet   = 2

	LspInsertTextModeAsIs              = 1
	LspInsertTextModeAdjustIndentation = 2
)

type LspCompletionItemLabelDetails struct {
	Detail      string `msgpack:"detail"`
	Description string `msgpack:"description"`
}

type LspCompletionItem struct {
	Label               string                         `msgpack:"label"`
	LabelDetails        *LspCompletionItemLabelDetails `msgpack:"labelDetails"`
	Kind                int                            `msgpack:"kind"`
	Tags                []int                          `msgpack:"tags"`
	Detail              string                         `msgpack:"detail"`
	Documentation       interface{}                    `msgpack:"documentation"`
	PreSelect           bool                           `msgpack:"preselect"`
	SortText            string                         `msgpack:"sortText"`
	FilterText          string                         `msgpack:"filterText"`
	InsertText          string                         `msgpack:"insertText"`
	InsertTextFormat    int                            `msgpack:"insertTextFormat"`
	InsertTextMode      int                            `msgpack:"insertTextMode"`
	TextEdit            *LspTextEdit                   `msgpack:"textEdit"`
	TextEditText        string                         `msgpack:"textEditText"`
	AdditionalTextEdits []LspTextEdit                  `msgpack:"additionalTextEdits"`
	CommitCharacters    []string                       `msgpack:"commitCharacters"`
	Command             *LspCommand                    `msgpack:"command"`
	Data                interface{}                    `msgpack:"data"`
}

type LspCommand struct {
	Title     string        `msgpack:"title"`
	Command   string        `msgpack:"command"`
	Arguments []interface{} `msgpack:"arguments"`
}

type LspTextEdit struct {
	Range   *LspRange `msgpack:"range"`
	Insert  *LspRange `msgpack:"insert"`
	Replace *LspRange `msgpack:"replace"`
	NewText string    `msgpack:"newText"`
}
