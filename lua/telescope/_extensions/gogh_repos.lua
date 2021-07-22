local actions = require "telescope.actions"
local conf = require "telescope.config".values
local entry_display = require "telescope.pickers.entry_display"
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local utils = require "telescope.utils"
local gogh_a = require "telescope._extensions.gogh_actions"
local strings = require "plenary.strings"

local M = {}

M.repos = function(opts)
  opts.cwd = utils.get_lazy_default(opts.cwd, vim.fn.getcwd)

  local results = {}
  local widths = {
    rel = 0,
    attr = 0
  }

  local parse_line = function(line)
    local entry = vim.fn.json_decode(line)
    entry.rel = entry.spec.host .. "/" .. entry.spec.owner .. "/" .. entry.spec.name
    local attr = {}
    if entry.private then
      table.insert(attr, "private")
    end
    if entry.fork then
      table.insert(attr, "fork")
    end
    if entry.archived then
      table.insert(attr, "archived")
    end
    entry.attr = table.concat(attr, ",")
    for key, value in pairs(widths) do
      widths[key] = math.max(value, strings.strdisplaywidth(entry[key] or ""))
    end
    table.insert(results, entry)
  end

  local output =
    utils.get_os_command_output(
    {
      opts.bin,
      "repos",
      "--format",
      "json",
      "--limit",
      "0"
    },
    opts.cwd
  )
  for _, line in ipairs(output) do
    parse_line(line)
  end
  if #results == 0 then
    return
  end

  local displayer =
    entry_display.create {
    separator = " ",
    items = {
      {width = widths.rel},
      {width = widths.attr},
      {remaing = true}
    }
  }

  local make_display = function(entry)
    return displayer {
      {entry.rel, "TelescopeResultsIdentifier"},
      {entry.attr},
      {entry.description}
    }
  end

  pickers.new(
    opts,
    {
      prompt_title = "Repositories on GitHub",
      finder = finders.new_table {
        results = results,
        entry_maker = function(entry)
          entry.value = entry.url
          entry.ordinal = entry.url
          entry.display = make_display
          return entry
        end
      },
      sorter = conf.file_sorter(opts),
      attach_mappings = function(_, map)
        ckeys = opts["keys"]["repos"]
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
