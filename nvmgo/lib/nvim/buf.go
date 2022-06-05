package nvim

import "github.com/neovim/go-client/nvim"

type Keymap struct {
	Mode    string // n, i, v, x, !
	Lhs     string
	Rhs     string
	Options map[string]bool // nowait, silent, script, expr, unique, noremap
}

type Buffer struct {
	Nvim    *nvim.Nvim
	Number  nvim.Buffer
	Name    string
	Options map[string]interface{}
	Keymaps []Keymap
}

func NewBuffer(v *nvim.Nvim, name string) *Buffer {
	return &Buffer{
		Nvim:    v,
		Name:    name,
		Options: make(map[string]interface{}),
		Keymaps: make([]Keymap, 0),
	}
}

func (b *Buffer) Create(scratch bool) error {
	valid, err := b.Valid()
	if err != nil {
		return err
	}
	if valid {
		return nil
	}

	b.Number, err = b.Nvim.CreateBuffer(false, scratch)
	if err != nil {
		return err
	}

	batch := b.Nvim.NewBatch()
	if len(b.Name) > 0 {
		batch.SetBufferName(b.Number, b.Name)
	}
	for k := range b.Options {
		batch.SetBufferOption(b.Number, k, b.Options[k])
	}
	for i := range b.Keymaps {
		batch.SetBufferKeyMap(b.Number, b.Keymaps[i].Mode, b.Keymaps[i].Lhs, b.Keymaps[i].Rhs, b.Keymaps[i].Options)
	}
	return batch.Execute()
}

func (b *Buffer) Valid() (bool, error) {
	if b.Number < 1 {
		return false, nil
	}
	return b.Nvim.IsBufferValid(b.Number)
}

func (b *Buffer) Loaded() (bool, error) {
	return b.Nvim.IsBufferLoaded(b.Number)
}

func (b *Buffer) SetOptions(opts map[string]interface{}) error {
	for k := range opts {
		b.Options[k] = opts[k]
	}

	valid, err := b.Valid()
	if err != nil {
		return err
	}
	if !valid {
		return nil
	}

	batch := b.Nvim.NewBatch()
	for k := range opts {
		batch.SetBufferOption(b.Number, k, opts[k])
	}
	return batch.Execute()
}

// function M.GetByFileName(fname)
//     local buf = setmetatable({}, M)
//     buf.name = fname

//     for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
//         if vim.api.nvim_buf_get_name(bufnr) == buf.name then
//             buf.bufnr = bufnr
//             return buf
//         end
//     end

//     return nil
// end

// function M.DelBufByNrs(nrs, force)
//     force = force or true
//     nrs = nrs or {}
//     if type(nrs) ~= "table" then
//         nrs = { nrs }
//     end

//     for _, nr in ipairs(nrs) do
//         if vim.api.nvim_buf_is_valid(nr) then
//             vim.api.nvim_buf_delete(nr, { force = force })
//         end
//     end
// end

// function M.DelBufByNames(names, force)
//     names = names or {}
//     if type(names) ~= "table" then
//         names = { names }
//     end

//     nrs = {}
//     for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
//         bname = vim.api.nvim_buf_get_name(bufnr)
//         for _, name in ipairs(names) do
//             if bname == name then
//                 table.insert(nrs, bufnr)
//                 break
//             end
//         end
//     end

//     M.DelBufByNrs(nrs, force)
// end

// function M.DelBufByNamePrefix(prefix, force)
//     nrs = {}
//     for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
//         bname = vim.api.nvim_buf_get_name(bufnr)
//         print("buf name: " .. bname)
//         if string.find(bname, prefix) == 1 then
//             table.insert(nrs, bufnr)
//         end
//     end
//     M.DelBufByNrs(nrs, force)
// end

// function M.RenameBuf(oldname, newname)
//     for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
//         if vim.api.nvim_buf_get_name(bufnr) == oldname then
//             vim.api.nvim_buf_set_name(bufnr, newname)
//             break
//         end
//     end
// end

// function M.RenameBufByNamePrefix(prefix, newprefix)
//     for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
//         bname = vim.api.nvim_buf_get_name(bufnr)
//         s, e = string.find(bname, prefix)
//         if s == 1 then
//             newname = newprefix .. string.sub(bname, e + 1)
//             vim.api.nvim_buf_set_name(bufnr, newname)
//         end
//     end
// end
