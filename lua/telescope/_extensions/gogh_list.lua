local actions = require "telescope.actions"
local conf = require "telescope.config".values
local entry_display = require "telescope.pickers.entry_display"
local finders = require "telescope.finders"
local from_entry = require "telescope.from_entry"
local path = require "plenary.path"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local utils = require "telescope.utils"
local gogh_a = require "telescope._extensions.gogh_actions"

local M = {}

local function is_readable(filepath)
  local fd = vim.loop.fs_open(filepath, "r", 438)
  local result = fd and true or false
  if result then
    vim.loop.fs_close(fd)
  end
  return result
end

local function search_readme(dir)
  for _, name in pairs {"README", "README.md", "README.markdown"} do
    local filepath = dir .. path.separator .. name
    if is_readable(filepath) then
      return filepath
    end
  end
  return nil
end

local function search_doc(dir)
  local doc_path = vim.fn.join({dir, "doc", "**", "*.txt"}, path.separator)
  local maybe_doc = vim.split(vim.fn.glob(doc_path), "\n")
  for _, filepath in pairs(maybe_doc) do
    if is_readable(filepath) then
      return filepath
    end
  end
  return nil
end

local function entry_maker(opts)
  local displayer =
    entry_display.create {
    items = {{}}
  }

  local os_home = vim.loop.os_homedir()

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
        dir = "~/" .. path.make_relative(dir, os_home)
      elseif dir ~= original then
        dir = "./" .. dir
      end
    end

    return displayer {dir}
  end

  return function(line)
    local entry = vim.fn.json_decode(line)
    return {
      value = entry.fullFilePath,
      ordinal = line,
      url = entry.url,
      path = entry.fullFilePath,
      display = make_display
    }
  end
end

M.list = function(opts)
  opts.cwd = utils.get_lazy_default(opts.cwd, vim.fn.getcwd)
  opts.entry_maker = utils.get_lazy_default(opts.entry_maker, entry_maker, opts)

  local results =
    utils.get_os_command_output(
    {
      opts.bin,
      "list",
      "--format",
      "json"
    },
    opts.cwd
  )
  pickers.new(
    opts,
    {
      prompt_title = "Repositories managed by gogh",
      finder = finders.new_table {
        results = results,
        entry_maker = opts.entry_maker
      },
      previewer = previewers.new_termopen_previewer {
        get_command = function(entry)
          local dir = from_entry.path(entry)
          local doc = search_readme(dir)
          local is_markdown
          if doc then
            is_markdown = true
          else
            -- TODO: doc may be previewed in a plain text. Can I use syntax highlight?
            doc = search_doc(dir)
          end
          if doc then
            if is_markdown and vim.fn.executable "glow" == 1 then
              return {"glow", doc}
            elseif vim.fn.executable "bat" == 1 then
              return {"bat", "--style", "header,grid", doc}
            end
            return {"cat", doc}
          end
          return {"echo", ""}
        end
      },
      sorter = conf.file_sorter(opts),
      attach_mappings = function(_, map)
        ckeys = opts["keys"]["list"]
        for op, key in next, ckeys do
          act = gogh_a[op]
          if key ~= nil then
            if key == "default" then
              actions.select_default:replace(act)
            else
              map("i", key, act)
            end
          end
        end
        return true
      end
    }
  ):find()
end

return M
