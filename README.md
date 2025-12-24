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
      -- Keybinding to trigger search (set to nil to disable)
      keymap = "<leader>pt",
      
      -- Window configuration
      window = {
        -- Window display mode: "float" (centered popup) or "split" (side panel)
        position = "float",
        
        -- Window size as fraction of screen (0.0 to 1.0)
        -- For float: both width and height are used
        -- For split: width used for vertical splits, height for horizontal splits
        width = 0.8,   -- 80% of screen width
        height = 0.8,  -- 80% of screen height
        
        -- Split position: "left" or "right" (only used when position = "split")
        split_position = "right",
      },
      
      -- Ripgrep search options
      ripgrep = {
        -- Case sensitive search (default: false)
        case_sensitive = false,
        
        -- Filter by file type (nil = all files, or specify like "lua", "py", etc.)
        file_types = nil,
        
        -- Glob patterns to exclude from search (empty table = no exclusions)
        exclude_patterns = {},
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

All configuration options with their defaults and descriptions:

```lua
require("search-tree").setup({
  -- ============================================================================
  -- KEYBINDING
  -- ============================================================================
  -- Keybinding to trigger the search tree
  -- Set to nil to disable the keybinding (you can still use :SearchTree command)
  -- Default: "<leader>pt"
  keymap = "<leader>pt",
  
  -- ============================================================================
  -- WINDOW CONFIGURATION
  -- ============================================================================
  window = {
    -- Window display mode
    --   "float" - Centered floating window (default)
    --   "split" - Split window (side panel)
    -- Default: "float"
    position = "float",
    
    -- Window dimensions as fraction of screen size (0.0 to 1.0)
    -- For "float" mode: both width and height are used
    -- For "split" mode: width is used for vertical splits (left/right)
    -- Default: 0.8 (80% of screen)
    width = 0.8,
    height = 0.8,
    
    -- Split window position (only used when position = "split")
    --   "right" - Open split on the right side (default)
    --   "left"  - Open split on the left side
    -- Default: "right"
    split_position = "right",
  },
  
  -- ============================================================================
  -- RIPGREP SEARCH OPTIONS
  -- ============================================================================
  ripgrep = {
    -- Enable case-sensitive search
    --   false - Case insensitive (default)
    --   true  - Case sensitive
    -- Default: false
    case_sensitive = false,
    
    -- Filter search results by file type
    --   nil   - Search all file types (default)
    --   "lua" - Only search Lua files
    --   "py"  - Only search Python files
    --   etc.
    -- Default: nil
    file_types = nil,
    
    -- Glob patterns to exclude files/directories from search
    -- Patterns follow ripgrep's glob syntax (see Exclude Patterns section below)
    -- Default: {} (no exclusions)
    exclude_patterns = {
      "**/libs/*",    -- Exclude any files in libs directories anywhere
      "**/*.tmp",     -- Exclude any .tmp files anywhere
      "*.xfi",        -- Exclude .xfi files at project root
      "node_modules", -- Exclude node_modules directory
      ".git",         -- Exclude .git directory
    },
  },
})
```

### Minimal Configuration

If you want to use all defaults, you can call setup with an empty table:

```lua
require("search-tree").setup({})
```

This will use:
- Keybinding: `<leader>pt`
- Window: Float mode, 80% width/height
- Search: Case insensitive, all file types, no exclusions

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
