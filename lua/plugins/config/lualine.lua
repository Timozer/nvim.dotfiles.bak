local config = {}

local gps_location = function()
    return require('nvim-gps').get_location()
end

local gps_available = function()
    return require('nvim-gps').is_available()
end

function config.init()
    require('lualine').setup {
        options = {
            icons_enabled = true,
            theme = 'onedark',
            disabled_filetypes = {
                'NvimTree', 'OUTLINE',
            },
            component_separators = '|',
            section_separators = {left = '', right = ''}
        },

        sections = {
            lualine_a = {'filename'},
            lualine_b = {{'branch'}, {'diff'}},
            lualine_c = {
                {gps_location, condition = gps_available},
            },
            lualine_x = {
                {
                    'diagnostics',
                    sources = {'nvim_lsp'},
                    color_error = "#BF616A",
                    color_warn = "#EBCB8B",
                    color_info = "#81A1AC",
                    color_hint = "#88C0D0",
                    symbols = {error = ' ', warn = ' ', info = ' '}
                },
            },
            lualine_y = {'filetype', 'encoding', 'fileformat'},
            lualine_z = {'progress', 'location'}
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {'filename'},
            lualine_x = {'location'},
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {},
        extensions = {}
    }
end

return config
