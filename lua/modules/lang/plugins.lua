local lang = {}
local conf = require('modules.lang.config')

lang['kristijanhusak/orgmode.nvim'] = {
    opt = true,
    ft = "org",
    config = conf.lang_org
}
return lang
