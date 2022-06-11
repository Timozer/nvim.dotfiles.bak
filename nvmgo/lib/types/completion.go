package types

import (
	"nvmgo/lib"
	"sort"
)

type CompletionItem struct {
	Icon   string `msgpack:"icon"`
	Word   string `msgpack:"word"`
	Kind   string `msgpack:"kind"`
	Source string `msgpack:"soruce"`

	UserData interface{} `msgpack:"user_data"`

	Distance int `msgpack:"-"`
}

type CompletionItems []*CompletionItem

func (c CompletionItems) Len() int {
	return len(c)
}

func (c CompletionItems) Less(i, j int) bool {
	return c[i].Distance < c[j].Distance
}

func (c CompletionItems) Swap(i, j int) {
	c[i], c[j] = c[j], c[i]
}

type CompletionList struct {
	Items CompletionItems

	IconWidth   int
	WordWidth   int
	KindWidth   int
	SourceWidth int
}

func (c *CompletionList) AddItem(item *CompletionItem) {
	c.IconWidth = lib.Max(c.IconWidth, len(item.Icon))
	c.WordWidth = lib.Max(c.WordWidth, len(item.Word))
	c.KindWidth = lib.Max(c.KindWidth, len(item.Kind))
	c.SourceWidth = lib.Max(c.SourceWidth, len(item.Source))

	c.Items = append(c.Items, item)
}

func (c *CompletionList) Sort() {
	sort.Sort(c.Items)
}

func (c *CompletionList) Merge(lst *CompletionList) {
	c.IconWidth = lib.Max(c.IconWidth, lst.IconWidth)
	c.WordWidth = lib.Max(c.WordWidth, lst.WordWidth)
	c.KindWidth = lib.Max(c.KindWidth, lst.KindWidth)
	c.SourceWidth = lib.Max(c.SourceWidth, lst.SourceWidth)

	c.Items = append(c.Items, lst.Items...)
}

func (c *CompletionList) Len() int {
	return c.Items.Len()
}
