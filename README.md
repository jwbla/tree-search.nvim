# search-tree.nvim

A Neovim plugin that displays search results in a tree view, similar to VSCode's search results. Groups matches by directory and file, showing match counts at each level.

## Features

- 🌳 **Tree View**: Hierarchical display of search results grouped by directory
- 📊 **Match Counts**: See total matches per directory and file
- 🔍 **Ripgrep Integration**: Uses ripgrep directly (no Telescope dependency)
- ⌨️ **Interactive**: Expand/collapse files to view individual matches
- 🎨 **Syntax Highlighting**: Color-coded directories, files, and matches

## Requirements

- Neovim 0.7+
- [ripgrep](https://github.com/BurntSushi/ripgrep) (must be in PATH)
- Optional: [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) for file icons

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jwbla/search-tree.nvim",
  config = function()
    require("search-tree").setup({
      keymap = "<leader>pt",
      window = {
        position = "float", -- or "split"
        width = 0.8,
        height = 0.8,
      },
      ripgrep = {
        case_sensitive = false,
      }
    })
  end
}
```

## Usage

### Commands

- `:SearchTree [term]` - Search for a term and display results in tree view
- If no term is provided, you'll be prompted to enter one

### Keybindings

- `<CR>` - Jump to match (or expand/collapse if on file/directory line)
- `<Space>` - Toggle expansion (file or directory)
- `l` or `<Right>` - Expand current file/directory
- `h` or `<Left>` - Collapse current file/directory
- `a` - Toggle expand/collapse all directories
- `o` - Open file at match location
- `r` - Refresh/re-run search
- `q` - Close tree view

### Example

1. Press `<leader>pt` (or run `:SearchTree`)
2. Enter your search term (e.g., "function")
3. View results grouped by directory:
   ```
   lua/jwbla (14)
     ├─ init.lua (5)
     ├─ plugins/lsp.lua (7)
     └─ remap.lua (2)
   ```

4. Press `<Space>` on a file to expand and see individual matches
5. Press `<CR>` on a match to jump to that location

## Configuration

```lua
require("search-tree").setup({
  keymap = "<leader>pt",  -- Keybinding to trigger search
  window = {
    position = "float",    -- "float" or "split"
    width = 0.8,           -- Window width (0.0 to 1.0)
    height = 0.8,          -- Window height (0.0 to 1.0)
    split_position = "right", -- For split mode: "left" or "right"
  },
  ripgrep = {
    case_sensitive = false, -- Case sensitive search
    file_types = nil,       -- File type filter (e.g., "lua", "py")
    exclude_patterns = {    -- Glob patterns to exclude from search
      "**/libs/*",         -- Exclude any files in libs directories anywhere
      "**/*.tmp",          -- Exclude any .tmp files anywhere
      "*.xfi",             -- Exclude .xfi files at project root
    },
  },
})
```

## Tree View Format

The tree view displays:

- **Directories** with total match count: `lua/jwbla (14)`
- **Files** with match count: `├─ init.lua (5)`
- **Matches** (when expanded): `│   ├─ 10:5: match text`

## Exclude Patterns

You can exclude files and directories from search results using glob patterns in the `exclude_patterns` configuration:

- `**/libs/*` - Excludes any files in `libs` directories anywhere in the project
- `**/*.tmp` - Excludes any `.tmp` files anywhere in the project  
- `*.xfi` - Excludes `.xfi` files at the project root level

Patterns are passed to ripgrep's `--glob-negate` option, so they follow ripgrep's glob syntax. The patterns are converted automatically (e.g., `**/libs/*` becomes `**/libs/**` to match everything in libs directories).
