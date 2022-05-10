local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local from_entry = require("telescope.from_entry")

local A = {}

local function close_telescope_prompt(prompt_bufnr)
    local entry = actions_state.get_selected_entry()
    actions.close(prompt_bufnr)
    return from_entry.path(entry)
end

-- open the target project
A.open = function(prompt_bufnr)
    local dir = close_telescope_prompt(prompt_bufnr)
    require("telescope.builtin").git_files({ cwd = dir })
end

-- browse the target repository
A.browse = function(prompt_bufnr)
    local entry = actions_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.fn["openbrowser#open"](entry.url)
end

-- global chdir
A.cd = function(prompt_bufnr)
    local dir = close_telescope_prompt(prompt_bufnr)
    vim.cmd("cd " .. dir)
    vim.notify("chdir to " .. dir, vim.log.levels.INFO)
end

-- buffer local chdir
A.lcd = function(prompt_bufnr)
    local dir = close_telescope_prompt(prompt_bufnr)
    vim.cmd("lcd " .. dir)
    vim.notify("chdir buffer local to " .. dir, vim.log.levels.INFO)
end

-- tab local chdir
A.tcd = function(prompt_bufnr)
    local dir = close_telescope_prompt(prompt_bufnr)
    vim.cmd("tcd " .. dir)
    vim.notify("chdir tab to " .. dir, vim.log.levels.INFO)
end

-- get repository
A.get = function(prompt_bufnr)
    local entry = actions_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.notify("getting " .. entry.url)
    vim.cmd("!gogh get " .. entry.rel, vim.log.levels.INFO)
end

return A
