local M = {}

-- Check if nvim-web-devicons is available
local function get_icon(filename)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok then
    local icon, hl = devicons.get_icon(filename, nil, { default = true })
    return icon or " ", hl or ""
  end
  return " ", ""
end

-- Recursively render a directory node
local function render_node(node, expanded_dirs, expanded_files, indent_prefix, is_last, lines, highlights, line_map)
  indent_prefix = indent_prefix or ""
  local tree_char = is_last and "└─" or "├─"
  local connector = is_last and "  " or "│ "
  
  -- Check if this directory is expanded (default to true - fully expanded by default)
  local is_expanded = expanded_dirs[node.path] ~= false
  
  -- Render directory name
  local dir_name = node.name == "." and "." or node.name
  local dir_line = string.format("%s%s %s (%d)", indent_prefix, tree_char, dir_name, node.count)
  table.insert(lines, dir_line)
  table.insert(highlights, { "SearchTreeDirectory", #lines })
  table.insert(line_map, { type = "directory", path = node.path, node = node, expanded = is_expanded })
  
  -- Only render children if expanded
  if not is_expanded then
    return
  end
  
  local new_indent = indent_prefix .. (is_last and "  " or "│ ")
  
  -- Render subdirectories
  if node.sorted_dirs then
    for dir_idx, dir_entry in ipairs(node.sorted_dirs) do
      local dir_node = dir_entry.node
      local is_last_dir = dir_idx == #node.sorted_dirs and (not node.sorted_files or #node.sorted_files == 0)
      render_node(dir_node, expanded_dirs, expanded_files, new_indent, is_last_dir, lines, highlights, line_map)
    end
  end
  
  -- Render files
  if node.sorted_files then
    for file_idx, file_entry in ipairs(node.sorted_files) do
      local file_node = file_entry.node
      local filename = file_entry.name
      local is_last_file = file_idx == #node.sorted_files
      
      -- Build full file path for lookup
      local file_path = node.path == "." and filename or (node.path .. "/" .. filename)
      
      -- Tree characters
      local file_tree_char = is_last_file and "└─" or "├─"
      
      -- File icon
      local icon, icon_hl = get_icon(filename)
      
      -- File line
      local file_line = string.format("%s%s %s %s (%d)", new_indent, file_tree_char, icon, filename, file_node.count)
      table.insert(lines, file_line)
      table.insert(highlights, { "SearchTreeFile", #lines })
      if icon_hl ~= "" then
        local icon_start = #new_indent + #file_tree_char + 2
        table.insert(highlights, { icon_hl, #lines, icon_start, icon_start + #icon })
      end
      
      -- Use the stored file path
      local actual_file_path = file_node.path or file_path
      local is_expanded = expanded_files[actual_file_path] or false
      
      table.insert(line_map, { type = "file", path = actual_file_path, expanded = is_expanded, node = file_node })
      
      -- Match lines (if expanded)
      if is_expanded and file_node.matches then
        local match_indent = new_indent .. (is_last_file and "  " or "│ ")
        for match_idx, match in ipairs(file_node.matches) do
          local is_last_match = match_idx == #file_node.matches
          local match_tree = is_last_match and "└─" or "├─"
          
          -- Truncate match text if too long
          local match_text = match.text
          if #match_text > 100 then
            match_text = match_text:sub(1, 97) .. "..."
          end
          
          local match_line = string.format("%s%s %d:%d: %s", match_indent, match_tree, match.line, match.column, match_text)
          table.insert(lines, match_line)
          table.insert(highlights, { "SearchTreeMatch", #lines })
          table.insert(line_map, {
            type = "match",
            path = actual_file_path,
            line = match.line,
            column = match.column,
            text = match.text,
          })
        end
      end
    end
  end
end

-- Render tree to buffer lines
function M.render_tree(root_node, expanded_files, expanded_dirs)
  expanded_files = expanded_files or {}
  expanded_dirs = expanded_dirs or {}
  local lines = {}
  local highlights = {}
  local line_map = {}
  
  -- Start rendering from root, but skip root if it's just "."
  if root_node.name == "." and root_node.sorted_dirs then
    -- Render each top-level directory
    for dir_idx, dir_entry in ipairs(root_node.sorted_dirs) do
      local is_last = dir_idx == #root_node.sorted_dirs and (not root_node.sorted_files or #root_node.sorted_files == 0)
      render_node(dir_entry.node, expanded_dirs, expanded_files, "", is_last, lines, highlights, line_map)
    end
    
    -- Also render root-level files if any
    if root_node.sorted_files then
      for file_idx, file_entry in ipairs(root_node.sorted_files) do
        local file_node = file_entry.node
        local filename = file_entry.name
        local is_last_file = file_idx == #root_node.sorted_files
        
        local file_tree_char = is_last_file and "└─" or "├─"
        local icon, icon_hl = get_icon(filename)
        local actual_file_path = file_node.path or filename
        local is_expanded = expanded_files[actual_file_path] or false
        
        local file_line = string.format("%s %s %s (%d)", file_tree_char, icon, filename, file_node.count)
        table.insert(lines, file_line)
        table.insert(highlights, { "SearchTreeFile", #lines })
        if icon_hl ~= "" then
          local icon_start = #file_tree_char + 2
          table.insert(highlights, { icon_hl, #lines, icon_start, icon_start + #icon })
        end
        table.insert(line_map, { type = "file", path = actual_file_path, expanded = is_expanded, node = file_node })
        
        if is_expanded and file_node.matches then
          for match_idx, match in ipairs(file_node.matches) do
            local is_last_match = match_idx == #file_node.matches
            local match_tree = is_last_match and "└─" or "├─"
            local match_text = match.text
            if #match_text > 100 then
              match_text = match_text:sub(1, 97) .. "..."
            end
            local match_line = string.format("  %s %d:%d: %s", match_tree, match.line, match.column, match_text)
            table.insert(lines, match_line)
            table.insert(highlights, { "SearchTreeMatch", #lines })
            table.insert(line_map, {
              type = "match",
              path = actual_file_path,
              line = match.line,
              column = match.column,
              text = match.text,
            })
          end
        end
      end
    end
  else
    -- Render root node directly
    render_node(root_node, {}, expanded_files, "", true, lines, highlights, line_map)
  end
  
  return lines, highlights, line_map
end

-- Setup syntax highlighting
function M.setup_highlights()
  vim.api.nvim_set_hl(0, "SearchTreeDirectory", { fg = "#89b4fa", bold = true })
  vim.api.nvim_set_hl(0, "SearchTreeFile", { fg = "#a6e3a1" })
  vim.api.nvim_set_hl(0, "SearchTreeMatch", { fg = "#cdd6f4" })
end

return M

