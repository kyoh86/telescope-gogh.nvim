local actions = require'telescope.actions'
local conf = require'telescope.config'.values
local entry_display = require'telescope.pickers.entry_display'
local finders = require'telescope.finders'
local from_entry = require'telescope.from_entry'
local path = require'telescope.path'
local pickers = require'telescope.pickers'
local previewers = require'telescope.previewers'
local utils = require'telescope.utils'

local os_home = vim.loop.os_homedir()

local M = {}

local function is_readable(filepath)
  local fd = vim.loop.fs_open(filepath, 'r', 438)
  local result = fd and true or false
  if result then
    vim.loop.fs_close(fd)
  end
  return result
end

local function search_readme(dir)
  for _, name in pairs{'README', 'README.md', 'README.markdown'} do
    local filepath = dir..path.separator..name
    if is_readable(filepath) then
      return filepath
    end
  end
  return nil
end

local function search_doc(dir)
  local doc_path = vim.fn.join({dir, 'doc', '**', '*.txt'}, path.separator)
  local maybe_doc = vim.split(vim.fn.glob(doc_path), '\n')
  for _, filepath in pairs(maybe_doc) do
    if is_readable(filepath) then
      return filepath
    end
  end
  return nil
end

local function gen_from_gogh(opts)
  local displayer = entry_display.create{
    items = {{}},
  }

  local function make_display(entry)
    return displayer{entry.path}
  end

  return function(line)
    return {
      value = line,
      ordinal = line,
      path = line,
      display = make_display,
    }
  end
end

M.list = function(opts)
  opts = opts or {}
  opts.bin = opts.bin and vim.fn.expand(opts.bin) or 'gogh'

  local bin = vim.fn.expand(opts.bin)
  pickers.new(opts, {
    prompt_title = 'Repositories managed by gogh',
    finder = finders.new_oneshot_job(
      {bin, 'list'},
      opts
    ),
    previewer = previewers.new_termopen_previewer{
      get_command = function(entry)
        local dir = from_entry.path(entry)
        local doc = search_readme(dir)
        local is_mardown
        if doc then
          is_mardown = true
        else
          doc = search_doc(dir)
        end
        if doc then
          if is_mardown and vim.fn.executable'glow' == 1 then
            return {'glow', doc}
          elseif vim.fn.executable'bat' == 1 then
            return {'bat', '--style', 'header,grid', doc}
          end
          return {'cat', doc}
        end
        return {'echo', ''}
      end,
    },
    sorter = conf.file_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions._goto_file_selection:replace(function(_, cmd)
        local entry = actions.get_selected_entry()
        actions.close(prompt_bufnr)
        local dir = from_entry.path(entry)
        if cmd == 'edit' then
          require'telescope.builtin'.git_files{cwd = dir}
        elseif cmd == 'new' then
          vim.cmd('cd '..dir)
          print('chdir to '..dir)
        elseif cmd == 'vnew' then
          vim.cmd('lcd '..dir)
          print('lchdir to '..dir)
        elseif cmd == 'tabedit' then
          vim.cmd('tcd '..dir)
          print('tchdir to '..dir)
        end
      end)
      return true
    end,
  }):find()
end

return M
