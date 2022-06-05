local M = {}

function M.SetUp()
    vim.api.nvim_set_keymap("v", "<Enter>", ":EasyAlign<cr>", {noremap=false})
end

return M