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
    local original = entry.path
    local dir
    if opts.tail_path then
      dir = utils.path_tail(original)
    elseif opts.shorten_path then
      dir = utils.path_shorten(original)
    else
      dir = path.make_relative(original, opts.cwd)
      if vim.startswith(dir, os_home) then
        dir = '~/'..path.make_relative(dir, os_home)
      elseif dir ~= original then
        dir = './'..dir
      end
    end

    return displayer{dir}
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

local function merge_table(base, ext)
  local table = {}
  if base then
    for key, value in next, base do
      table[key] = value
    end
  end
  for key, value in next, ext do
    table[key] = value
  end
  return table
end

local config = {
  bin = 'gogh',
  tail_path = false,
  shorten_path = true,
}

M.list = function(opts)
  opts = merge_table(config, opts or {})
  opts.cwd = utils.get_lazy_default(opts.cwd, vim.fn.getcwd)
  opts.entry_maker = utils.get_lazy_default(opts.entry_maker, gen_from_gogh, opts)

  pickers.new(opts, {
    prompt_title = 'Repositories managed by gogh',
    finder = finders.new_oneshot_job(
      {opts.bin, 'list', '--format', 'full'},
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
          -- TODO: doc may be previewed in a plain text. Can I use syntax highlight?
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

return require('telescope').register_extension{
  setup = function(ext_config)
    config = merge_table(config, ext_config)
  end,
  exports = {
    gogh = M.list,
    list = M.list
  },
}
