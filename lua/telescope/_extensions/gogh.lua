local gogh_c = require("telescope._extensions.gogh_config")

local config = gogh_c.default()

local function list(opts)
  opts = gogh_c.merge(config, opts or {})
  require("telescope._extensions.gogh_list").list(opts)
end

local function repos(opts)
  opts = gogh_c.merge(config, opts or {})
  require("telescope._extensions.gogh_repos").repos(opts)
end

return require("telescope").register_extension({
  setup = function(ext_config)
    config = gogh_c.merge(config, ext_config)
  end,
  exports = {
    gogh = list,
    list = list,
    repos = repos,
  },
})
