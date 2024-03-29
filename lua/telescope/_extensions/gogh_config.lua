local C = {}

local function merge_config(base, ext)
  local table = {}
  -- copy base
  for key, value in next, base do
    table[key] = value
  end

  for key, value in next, ext do
    old = table[key]
    if type(old) == "table" and type(value) == "table" then
      table[key] = merge_config(old, value)
    else
      table[key] = value
    end
  end

  return table
end
C.merge = merge_config

C.default = function()
  return {
    bin = "gogh",
    tail_path = false,
    shorten_path = false,
    keys = {
      list = {
        open = "default",
        cd = "<c-g>",
        lcd = "<c-l>",
        tcd = "<c-t>",
        browse = "<c-o>",
      },
      repos = {
        browse = "default",
        get = "<c-g>",
      },
    },
  }
end

return C
