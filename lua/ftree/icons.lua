local M = {
    icons = {
        ["babelrc"] = {
            icon = "ﬥ",
            color = "#cbcb41",
            name = "Babelrc",
        },
        ["bash_profile"] = {
            icon = "",
            color = "#89e051",
            name = "BashProfile",
        },
        ["bashrc"] = {
            icon = "",
            color = "#89e051",
            name = "Bashrc",
        },
        ["ds_store"] = {
            icon = "",
            color = "#41535b",
            name = "DsStore",
        },
        [".gitattributes"] = {
            icon = "",
            color = "#41535b",
            name = "GitAttributes",
        },
        [".gitconfig"] = {
            icon = "",
            color = "#41535b",
            name = "GitConfig",
        },
        [".gitignore"] = {
            icon = "",
            color = "#41535b",
            name = "GitIgnore",
        },
        [".gitmodules"] = {
            icon = "",
            color = "#41535b",
            name = "GitModules",
        },
        ["gvimrc"] = {
            icon = "",
            color = "#019833",
            name = "Gvimrc",
        },
        ["npmignore"] = {
            icon = "",
            color = "#E8274B",
            name = "NPMIgnore",
        },
        ["npmrc"] = {
            icon = "",
            color = "#E8274B",
            name = "NPMrc",
        },
        ["settings.json"] = {
            icon = "",
            color = "#854CC7",
            name = "SettingsJson",
        },
        ["vimrc"] = {
            icon = "",
            color = "#019833",
            name = "Vimrc",
        },
        ["zprofile"] = {
            icon = "",
            color = "#89e051",
            name = "Zshprofile",
        },
        ["zshenv"] = {
            icon = "",
            color = "#89e051",
            name = "Zshenv",
        },
        ["zshrc"] = {
            icon = "",
            color = "#89e051",
            name = "Zshrc",
        },
        ["CMakeLists.txt"] = {
            icon = "",
            color = "#6d8086",
            name = "CMakeLists",
        },
        ["COMMIT_EDITMSG"] = {
            icon = "",
            color = "#41535b",
            name = "GitCommit",
        },
        ["COPYING"] = {
            icon = "",
            color = "#cbcb41",
            name = "License",
        },
        ["COPYING.LESSER"] = {
            icon = "",
            color = "#cbcb41",
            name = "License",
        },
        ["Dockerfile"] = {
            icon = "",
            color = "#384d54",
            name = "Dockerfile",
        },
        ["LICENSE"] = {
            icon = "",
            color = "#d0bf41",
            name = "License",
        },
        ["_vimrc"] = {
            icon = "",
            color = "#019833",
            name = "Vimrc",
        },
        ["awk"] = {
            icon = "",
            color = "#4d5a5e",
            name = "Awk",
        },
        ["bash"] = {
            icon = "",
            color = "#89e051",
            name = "Bash",
        },
        ["bat"] = {
            icon = "",
            color = "#C1F12E",
            name = "Bat",
        },
        ["bmp"] = {
            icon = "",
            color = "#a074c4",
            name = "Bmp",
        },
        ["c"] = {
            icon = "",
            color = "#599eff",
            name = "C",
        },
        ["cc"] = {
            icon = "",
            color = "#f34b7d",
            name = "CPlusPlus",
        },
        ["cfg"] = {
            icon = "",
            color = "#ECECEC",
            name = "Configuration",
        },
        ["cmake"] = {
            icon = "",
            color = "#6d8086",
            name = "CMake",
        },
        ["conf"] = {
            icon = "",
            color = "#6d8086",
            name = "Conf",
        },
        ["cpp"] = {
            icon = "",
            color = "#519aba",
            name = "Cpp",
        },
        ["cs"] = {
            icon = "",
            color = "#596706",
            name = "Cs",
        },
        ["csh"] = {
            icon = "",
            color = "#4d5a5e",
            name = "Csh",
        },
        ["css"] = {
            icon = "",
            color = "#563d7c",
            name = "Css",
        },
        ["csv"] = {
            icon = "",
            color = "#89e051",
            name = "Csv",
        },
        ["cxx"] = {
            icon = "",
            color = "#519aba",
            name = "Cxx",
        },
        ["d"] = {
            icon = "",
            color = "#427819",
            name = "D",
        },
        ["dart"] = {
            icon = "",
            color = "#03589C",
            name = "Dart",
        },
        ["db"] = {
            icon = "",
            color = "#dad8d8",
            name = "Db",
        },
        ["desktop"] = {
            icon = "",
            color = "#563d7c",
            name = "DesktopEntry",
        },
        ["diff"] = {
            icon = "",
            color = "#41535b",
            name = "Diff",
        },
        ["doc"] = {
            icon = "",
            color = "#185abd",
            name = "Doc",
        },
        ["dockerfile"] = {
            icon = "",
            color = "#384d54",
            name = "Dockerfile",
        },
        ["favicon.ico"] = {
            icon = "",
            color = "#cbcb41",
            name = "Favicon",
        },
        ["fnl"] = {
            color = "#fff3d7",
            icon = "🌜",
            name = "Fennel"
        },
        ["gif"] = {
            icon = "",
            color = "#a074c4",
            name = "Gif",
        },
        ["git"] = {
            icon = "",
            color = "#F14C28",
            name = "GitLogo",
        },
        ["go"] = {
            icon = "",
            color = "#519aba",
            name = "Go",
        },
        ["h"] = {
            icon = "",
            color = "#a074c4",
            name = "H",
        },
        ["hh"] = {
            icon = "",
            color = "#a074c4",
            name = "Hh",
        },
        ["hpp"] = {
            icon = "",
            color = "#a074c4",
            name = "Hpp",
        },
        ["htm"] = {
            icon = "",
            color = "#e34c26",
            name = "Htm",
        },
        ["html"] = {
            icon = "",
            color = "#e34c26",
            name = "Html",
        },
        ["hxx"] = {
            icon = "",
            color = "#a074c4",
            name = "Hxx",
        },
        ["ico"] = {
            icon = "",
            color = "#cbcb41",
            name = "Ico",
        },
        ["import"] = {
            icon = "",
            color = "#ECECEC",
            name = "ImportConfiguration",
        },
        ["ini"] = {
            icon = "",
            color = "#6d8086",
            name = "Ini",
        },
        ["java"] = {
            icon = "",
            color = "#cc3e44",
            name = "Java",
        },
        ["jpeg"] = {
            icon = "",
            color = "#a074c4",
            name = "Jpeg",
        },
        ["jpg"] = {
            icon = "",
            color = "#a074c4",
            name = "Jpg",
        },
        ["js"] = {
            icon = "",
            color = "#cbcb41",
            name = "Js",
        },
        ["json"] = {
            icon = "",
            color = "#cbcb41",
            name = "Json",
        },
        ["jsx"] = {
            icon = "",
            color = "#519aba",
            name = "Jsx",
        },
        ["license"] = {
            icon = "",
            color = "#cbcb41",
            name = "License",
        },
        ["lua"] = {
            icon = "",
            color = "#51a0cf",
            name = "Lua",
        },
        ["makefile"] = {
            icon = "",
            color = "#6d8086",
            name = "Makefile",
        },
        ["markdown"] = {
            icon = "",
            color = "#519aba",
            name = "Markdown",
        },
        ["md"] = {
            icon = "",
            color = "#519aba",
            name = "Md",
        },
        ["node_modules"] = {
            icon = "",
            color = "#E8274B",
            name = "NodeModules",
        },
        ["otf"] = {
            icon = "",
            color = "#ECECEC",
            name = "OpenTypeFont",
        },
        ['package.json'] = {
            icon = "",
            color = "#e8274b",
            name = "PackageJson"
        },
        ['package-lock.json'] = {
            icon = "",
            color = "#7a0d21",
            name = "PackageLockJson"
        },
        ["pdf"] = {
            icon = "",
            color = "#b30b00",
            name = "Pdf",
        },
        ["php"] = {
            icon = "",
            color = "#a074c4",
            name = "Php",
        },
        ["png"] = {
            icon = "",
            color = "#a074c4",
            name = "Png",
        },
        ["ppt"] = {
            icon = "",
            color = "#cb4a32",
            name = "Ppt",
        },
        ["psb"] = {
            icon = "",
            color = "#519aba",
            name = "Psb",
        },
        ["psd"] = {
            icon = "",
            color = "#519aba",
            name = "Psd",
        },
        ["py"] = {
            icon = "",
            color = "#ffbc03",
            name = "Py",
        },
        ["pyc"] = {
            icon = "",
            color = "#ffe291",
            name = "Pyc",
        },
        ["pyd"] = {
            icon = "",
            color = "#ffe291",
            name = "Pyd",
        },
        ["pyo"] = {
            icon = "",
            color = "#ffe291",
            name = "Pyo",
        },
        ["r"] = {
            icon = "ﳒ",
            color = "#358a5b",
            name = "R",
        },
        ["rb"] = {
            icon = "",
            color = "#701516",
            name = "Rb",
        },
        ["rss"] = {
            icon = "",
            color = "#FB9D3B",
            name = "Rss",
        },
        ["scala"] = {
            icon = "",
            color = "#cc3e44",
            name = "Scala",
        },
        ["scss"] = {
            icon = "",
            color = "#f55385",
            name = "Scss",
        },
        ["sh"] = {
            icon = "",
            color = "#4d5a5e",
            name = "Sh",
        },
        ["sig"] = {
            icon = "λ",
            color = "#e37933",
            name = "Sig",
        },
        ["sln"] = {
            icon = "",
            color = "#854CC7",
            name = "Sln",
        },
        ["sql"] = {
            icon = "",
            color = "#dad8d8",
            name = "Sql",
        },
        ["sqlite"] = {
            icon = "",
            color = "#dad8d8",
            name = "Sql",
        },
        ["sqlite3"] = {
            icon = "",
            color = "#dad8d8",
            name = "Sql",
        },
        ["sublime"] = {
            icon = "",
            color = "#e37933",
            name = "Suo",
        },
        ["svg"] = {
            icon = "ﰟ",
            color = "#FFB13B",
            name = "Svg",
        },
        ["swift"] = {
            icon = "",
            color = "#e37933",
            name = "Swift",
        },
        ["t"] = {
            icon = "",
            color = "#519aba",
            name = "Tor",
        },
        ["tex"] = {
            icon = "ﭨ",
            color = "#3D6117",
            name = "Tex",
        },
        ["toml"] = {
            icon = "",
            color = "#6d8086",
            name = "Toml",
        },
        ["ts"] = {
            icon = "",
            color = "#519aba",
            name = "Ts",
        },
        ["tsx"] = {
            icon = "",
            color = "#519aba",
            name = "Tsx",
        },
        ["twig"] = {
            icon = "",
            color = "#8dc149",
            name = "Twig",
        },
        ["txt"] = {
            icon = "",
            color = "#89e051",
            name = "Txt",
        },
        ["vim"] = {
            icon = "",
            color = "#019833",
            name = "Vim",
        },
        ["vue"] = {
            icon = "﵂",
            color = "#8dc149",
            name = "Vue",
        },
        ["webmanifest"] = {
            icon = "",
            color = "#f1e05a",
            name = "Webmanifest",
        },
        ["webp"] = {
            icon = "",
            color = "#a074c4",
            name = "Webp",
        },
        ["webpack"] = {
            icon = "ﰩ",
            color = "#519aba",
            name = "Webpack",
        },
        ["xls"] = {
            icon = "",
            color = "#207245",
            name = "Xls",
        },
        ["xml"] = {
            icon = "謹",
            color = "#e37933",
            name = "Xml",
        },
        ["yaml"] = {
            icon = "",
            color = "#6d8086",
            name = "Yaml",
        },
        ["yml"] = {
            icon = "",
            color = "#6d8086",
            name = "Yml",
        },
        ["zig"] = {
            icon = "",
            color = "#f69a1b",
            name = "Zig",
        },
        ["zsh"] = {
            icon = "",
            color = "#89e051",
            name = "Zsh",
        },
    }
}

function M.GetIcon(filename)
    local ret = M.icons[filename]
    if ret == nil then
        local ext = string.match(filename, ".?[^.]+%.(.*)") or ""
        ret = M.icons[ext] or {
            icon = "",
            color = "#6d8086",
            name = "Default",
        }
    end
    return ret.icon, "Icon" .. ret.name
end

function M.setup(opts)
    opts = opts or {}
    vim.tbl_extend("force", M.icons, opts)
    for _, v in pairs(M.icons) do
        local fg = " guifg=" .. v.color
        vim.api.nvim_command("hi def Icon" .. v.name .. fg)
    end
end

return M
