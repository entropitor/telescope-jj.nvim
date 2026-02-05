local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")
local utils = require("telescope-jj.utils")

return function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or utils.get_jj_root()
    if opts.cwd == nil then
        return
    end

    local cmd = { "jj", "diff", "--name-only", "--no-pager" }
    local prompt_title = "Jujutsu Diff"

    if opts.revision then
        table.insert(cmd, "-r")
        table.insert(cmd, opts.revision)
        prompt_title = "Jujutsu Diff (" .. opts.revision .. ")"
    elseif opts.from or opts.to then
        if opts.from then
            table.insert(cmd, "--from")
            table.insert(cmd, opts.from)
        end
        if opts.to then
            table.insert(cmd, "--to")
            table.insert(cmd, opts.to)
        end
        local from_str = opts.from or "@"
        local to_str = opts.to or "@"
        prompt_title = "Jujutsu Diff (" .. from_str .. " → " .. to_str .. ")"
    end

    local cmd_output = utils.get_os_command_output(cmd, opts.cwd)

    pickers
        .new(opts, {
            prompt_title = prompt_title,
            __locations_input = true,
            finder = finders.new_table({
                results = cmd_output,
                entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
            }),
            previewer = utils.diff_previwer.new(opts),
            sorter = conf.file_sorter(opts),
        })
        :find()
end
