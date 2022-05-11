if vim.g.sline_loaded == 1 then
    return
end

if vim.api.nvim_call_function('has', {'nvim-0.7'}) ~= 1 then
    vim.fn.nvim_out_write("sline requires at least nvim-0.7")
    return
end

vim.g.sline_loaded = 1

require("sline").SetUp()
