# telescope-gogh.nvim

`telescope-gogh` is an extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) that provides its users with operating [kyoh86/gogh](https://github.com/kyoh86/gogh).

## Installation

```lua
use{
  'nvim-telescope/telescope.nvim',
  requires = {
    'nvim-telescope/telescope-gogh.nvim',
  },
  config = function()
    require'telescope'.load_extension'gogh'
  end,
}
```

## Configuration

This extension can be configured using extensions field inside Telescope setup function.

```lua
require('telescope').setup {
  extensions = {
    gogh = {
      bin = 'gogh',
      tail_path = false,
      shorten_path = true,
    }
  },
}
```

### `bin`

Filepath for the binary `gogh`. The path can be expanded.

### `tail_path`

Show only basename of the path.

Default value: `false`

### `shorten_path`

Call `pathshorten()` for each path.

Default value: `true`

## Usage

### list

`:Telescope gogh list`

Running `gogh list` and list repositories' paths.
In default, it does actions below when you input keys.

| key              | action               |
|------------------|----------------------|
| `<CR>` (edit)    | `builtin.git_files`  |
| `<C-x>` (split)  | `:chdir` to the dir  |
| `<C-v>` (vsplit) | `:lchdir` to the dir |
| `<C-t>` (tabnew) | `:tchdir` to the dir |

### options

#### Override configurations

You can override configurations with options like below:

- `bin`
- `tail_path`
- `shorten_path`

```vim
:Telescope gogh list bin=~/gogh tail_path=false
```

#### `cwd`

Transform the result paths into relative ones with this value as the base dir.

Default value: `vim.fn.getcwd()`

# LICENSE

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg)](http://www.opensource.org/licenses/MIT)

This is distributed under the [MIT License](http://www.opensource.org/licenses/MIT).
