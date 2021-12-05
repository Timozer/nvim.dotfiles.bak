local Job = require "plenary.job"

local finders = {}

finders.new_job = function()
end

local files = {}

files.grep = function(opts)
    local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
    local search_dirs = opts.search_dirs
    local grep_open_files = opts.grep_open_files
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

    local filelist = {}

    for i, path in ipairs(search_dirs) do
        search_dirs[i] = vim.fn.expand(path)
    end

    local additional_args = {}
    if opts.additional_args ~= nil and type(opts.additional_args) == "function" then
        additional_args = opts.additional_args(opts)
    end

    local grepper = finders.new_job(function(prompt)
        -- TODO: Probably could add some options for smart case and whatever else rg offers.

        if not prompt or prompt == "" then
            return nil
        end

        local search_list = {}

        if search_dirs then
            table.insert(search_list, search_dirs)
        else
            table.insert(search_list, ".")
        end

        return flatten { vimgrep_arguments, additional_args, "--", prompt, search_list }
    end, opts.entry_maker or make_entry.gen_from_vimgrep(opts), opts.max_results, opts.cwd)

    pickers.new(opts, {
        prompt_title = "Grep",
        finder = grepper,
        previewer = conf.grep_previewer(opts),
        sorter = sorters.highlighter_only(opts),
    }):find()

end

return files
