local gogh_builtin = require'telescope._extensions.gogh_builtin'

return require'telescope'.register_extension{
  exports = {
    list = gogh_builtin.list
  },
}
