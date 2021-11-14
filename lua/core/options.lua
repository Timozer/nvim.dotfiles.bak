local global = require('core.global')

local function bind_option(options)
    for k, v in pairs(options) do
        if v == true then
            vim.cmd('set ' .. k)
        elseif v == false then
            vim.cmd('set no' .. k)
        else
            vim.cmd('set ' .. k .. '=' .. v)
        end
    end
end

local function load_options()
    local global_local = {
        -- cursor
        cul = true,
        cuc = true,
        ruler = true,
        -- 
        termguicolors = true,
        -- bells
        errorbells = true,
        visualbell = true,
        -- 
        fileformats = "unix,mac,dos",
        magic = true,
        virtualedit = "block",
        encoding = "utf-8",
        clipboard = "unnamed,unnamedplus",
        -- complete
        complete = ".,w,b,k",
        completeopt = "menuone,noselect",
        wildignorecase = true,
        wildignore = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**",
        backup = true,
        backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim",
        backupdir = global.cache_dir .. "backup/",
        swapfile = true,
        directory = global.cache_dir .. "swag/",
        undodir = global.cache_dir .. "undo/",
        viewdir = global.cache_dir .. "view/",
        spellfile = global.cache_dir .. "spell/en.uft-8.add",
        history = 2000,
        smarttab = true,
        shiftround = true,
        timeoutlen = 500,
        ttimeoutlen = 0,
        -- search
        ignorecase = true,
        smartcase = true,
        infercase = true,
        incsearch = true,
        inccommand = "nosplit",
        grepformat = "%f:%l:%c:%m",
        grepprg = 'rg --hidden --vimgrep --smart-case --',
        whichwrap = "<,>,[,],~",
        splitbelow = true,
        splitright = true,
        switchbuf = "useopen",
        backspace = "indent",
        diffopt = "filler,iwhite,internal,algorithm:patience",
        jumpoptions = "stack",
        showmode = false,
        shortmess = "aoOTIcF",
        scrolloff = 3,
        sidescrolloff = 5,
        foldlevelstart = 99,
        showtabline = 0,
        winwidth = 30,
        winminwidth = 10,
        pumheight = 15,
        helpheight = 12,
        previewheight = 12,
        showcmd = false,
        cmdheight = 2,
        cmdwinheight = 5,
        equalalways = false,
        laststatus = 2,
        display = "lastline",
        showbreak = "↳  ",
        listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
        pumblend = 10,
        winblend = 10,
        autoread = true,
        autowrite = true,
        undofile = true,
        synmaxcol = 2500,
        formatoptions = "1jcroql",
        textwidth = 80,
        colorcolumn = "+1",
        expandtab = true,
        smartindent = true,
        tabstop = 4,
        shiftwidth = 4,
        softtabstop = 4,
        breakindentopt = "shift:2,min:20",
        wrap = true,
        linebreak = true,
        number = true,
        foldenable = true,
        signcolumn = "yes",
        conceallevel = 0,
        concealcursor = "niv"
    }

    for name, value in pairs(global_local) do 
        vim.o[name] = value 
    end
end

load_options()
