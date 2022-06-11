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

type LspCompletionItemKind int

const (
	LspCompletionItemKindText          = 1
	LspCompletionItemKindMethod        = 2
	LspCompletionItemKindFunction      = 3
	LspCompletionItemKindConstructor   = 4
	LspCompletionItemKindField         = 5
	LspCompletionItemKindVariable      = 6
	LspCompletionItemKindClass         = 7
	LspCompletionItemKindInterface     = 8
	LspCompletionItemKindModule        = 9
	LspCompletionItemKindProperty      = 10
	LspCompletionItemKindUnit          = 11
	LspCompletionItemKindValue         = 12
	LspCompletionItemKindEnum          = 13
	LspCompletionItemKindKeyword       = 14
	LspCompletionItemKindSnippet       = 15
	LspCompletionItemKindColor         = 16
	LspCompletionItemKindFile          = 17
	LspCompletionItemKindReference     = 18
	LspCompletionItemKindFolder        = 19
	LspCompletionItemKindEnumMember    = 20
	LspCompletionItemKindConstant      = 21
	LspCompletionItemKindStruct        = 22
	LspCompletionItemKindEvent         = 23
	LspCompletionItemKindOperator      = 24
	LspCompletionItemKindTypeParameter = 25
)

func (k LspCompletionItemKind) String() string {
	switch k {
	case LspCompletionItemKindText:
		return "Text"
	case LspCompletionItemKindMethod:
		return "Method"
	case LspCompletionItemKindFunction:
		return "Func"
	case LspCompletionItemKindConstructor:
		return "Constructor"
	case LspCompletionItemKindField:
		return "Field"
	case LspCompletionItemKindVariable:
		return "Var"
	case LspCompletionItemKindClass:
		return "Class"
	case LspCompletionItemKindInterface:
		return "Interface"
	case LspCompletionItemKindModule:
		return "Module"
	case LspCompletionItemKindProperty:
		return "Property"
	case LspCompletionItemKindUnit:
		return "Unit"
	case LspCompletionItemKindValue:
		return "Value"
	case LspCompletionItemKindEnum:
		return "Enum"
	case LspCompletionItemKindKeyword:
		return "Keyword"
	case LspCompletionItemKindSnippet:
		return "Snip"
	case LspCompletionItemKindColor:
		return "Color"
	case LspCompletionItemKindFile:
		return "File"
	case LspCompletionItemKindReference:
		return "Ref"
	case LspCompletionItemKindFolder:
		return "Folder"
	case LspCompletionItemKindEnumMember:
		return "EnumMember"
	case LspCompletionItemKindConstant:
		return "Constant"
	case LspCompletionItemKindStruct:
		return "Struct"
	case LspCompletionItemKindEvent:
		return "Event"
	case LspCompletionItemKindOperator:
		return "Operator"
	case LspCompletionItemKindTypeParameter:
		return "TypeParameter"
	}
	return ""
}

type LspCompletionItem struct {
	Label               string                         `msgpack:"label"`
	LabelDetails        *LspCompletionItemLabelDetails `msgpack:"labelDetails"`
	Kind                LspCompletionItemKind          `msgpack:"kind"`
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
