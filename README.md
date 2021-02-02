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

#### options

#### `bin`

Filepath for the binary `gogh`.

```vim
" path can be expanded
:Telescope gogh list bin=~/gogh
```

# LICENSE

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg)](http://www.opensource.org/licenses/MIT)

This is distributed under the [MIT License](http://www.opensource.org/licenses/MIT).
