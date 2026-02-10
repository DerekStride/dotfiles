local keymap = vim.keymap
local default_opts = { silent = true, noremap = true }

local function find_claude_pane()
  local find_claude_cmd = "tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep -E '(claude|node)' | head -1 | cut -d' ' -f1"
  local claude_pane = vim.fn.system(find_claude_cmd):gsub("%s+", "")

  if claude_pane == "" then
    print("No Claude Code pane found. Make sure claude code is running in a tmux pane.")
    return nil
  end

  return claude_pane
end

local function get_relative_filepath(filepath)
  local cwd = vim.fn.getcwd()
  local home = vim.fn.expand("~")
  local relative_path

  -- Try relative to current workspace first
  if filepath:sub(1, #cwd) == cwd then
    relative_path = filepath:sub(#cwd + 2) -- +2 to skip the trailing slash
  -- Try relative to home directory
  elseif filepath:sub(1, #home) == home then
    relative_path = "~" .. filepath:sub(#home + 1)
  -- Use absolute path for everything else
  else
    relative_path = filepath
  end

  -- Check if in visual mode and add line numbers
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- Exit visual mode to update the marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]

    if start_line == end_line then
      relative_path = relative_path .. string.format("#L%d", start_line)
    else
      relative_path = relative_path .. string.format("#L%d-L%d", start_line, end_line)
    end
  end

  return relative_path
end

local function send_to_claude_pane(content, description)
  local claude_pane = find_claude_pane()
  if not claude_pane then
    return
  end

  local escaped_content = vim.fn.shellescape(content)
  local tmux_cmd = string.format(
    "tmux send-keys -t %s %s Enter",
    claude_pane,
    escaped_content
  )

  vim.fn.system("bash -c " .. vim.fn.shellescape(tmux_cmd))
  print(description .. " (pane " .. claude_pane .. ")")
end

local function send_to_claude()
  local text = ""

  -- Get visual selection if in visual mode
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    -- Exit visual mode to update the marks
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])

    if mode == "v" then
      if #lines == 1 then
        lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
      else
        lines[1] = string.sub(lines[1], start_pos[3])
        lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
      end
    end

    text = table.concat(lines, "\n")
  else
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    text = table.concat(lines, "\n")
  end

  if text == "" then
    print("No text to send to Claude")
    return
  end

  send_to_claude_pane(text, "Sent " .. #text .. " characters to Claude Code")
end

local function send_filepath_to_claude()
  local filepath = vim.fn.expand("%:p")

  if filepath == "" then
    print("No file currently open")
    return
  end

  local relative_path = "@" .. get_relative_filepath(filepath)

  send_to_claude_pane(relative_path, "Sent filepath to Claude Code: " .. relative_path)
end

local function copy_filepath_to_clipboard()
  local filepath = vim.fn.expand("%:p")

  if filepath == "" then
    print("No file currently open")
    return
  end

  local relative_filepath = get_relative_filepath(filepath)

  vim.fn.setreg('+', relative_filepath)
  vim.fn.setreg('*', relative_filepath)
  print("Copied filepath to clipboard: " .. relative_filepath)
end

local function open_in_github()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    print("No file currently open")
    return
  end

  -- Get git toplevel
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+", "")
  if git_root == "" then
    print("Not in a git repository")
    return
  end

  -- Get relative path from git root
  local relative_path = filepath:sub(#git_root + 2)

  -- Get remote URL
  local remote_url = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%s+", "")
  if remote_url == "" then
    print("No git remote 'origin' found")
    return
  end

  -- Parse remote URL to GitHub base URL (handles SSH and HTTPS)
  local github_url
  local ssh_match = remote_url:match("git@github%.com:(.+)%.git$") or remote_url:match("git@github%.com:(.+)$")
  if ssh_match then
    github_url = "https://github.com/" .. ssh_match
  else
    github_url = remote_url:gsub("%.git$", "")
  end

  local url = github_url .. "/blob/main/" .. relative_path

  -- Handle line numbers for visual mode
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)
    local start_line = vim.fn.getpos("'<")[2]
    local end_line = vim.fn.getpos("'>")[2]
    if start_line == end_line then
      url = url .. "#L" .. start_line
    else
      url = url .. "#L" .. start_line .. "-L" .. end_line
    end
  end

  vim.fn.system("open " .. vim.fn.shellescape(url))
  print("Opened in GitHub: " .. url)
end

local function open_prompt_notes()
  local scratch_dir = vim.fn.expand("$NOTES")
  if scratch_dir == "$NOTES" or scratch_dir == "" then
    print("NOTES environment variable not set")
    return
  end

  local git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+", "")
  local note_name

  if git_branch == "" then
    note_name = "no-git"
  elseif git_branch == "main" or git_branch == "master" then
    -- Get git project name from remote origin URL
    local git_remote = vim.fn.system("git remote get-url origin 2>/dev/null"):gsub("%s+", "")
    if git_remote ~= "" then
      -- Extract project name from git URL (handles both SSH and HTTPS formats)
      local project_name = git_remote:match("([^/]+)%.git$") or git_remote:match("([^/]+)$")
      if project_name then
        note_name = project_name
      else
        note_name = git_branch
      end
    else
      note_name = git_branch
    end
  else
    note_name = git_branch
  end

  local prompts_dir = scratch_dir .. "/claude/prompts"
  local prompt_file = prompts_dir .. "/" .. note_name .. ".md"

  vim.cmd("wincmd s")
  vim.cmd("edit " .. vim.fn.fnameescape(prompt_file))
end

keymap.set("n", "<leader><leader>m", "<cmd>!mux split<cr><cr>", default_opts)
keymap.set("n", "<leader><leader>s", "<cmd>set nonumber<cr>", default_opts)
keymap.set("n", "<leader><leader>p", "<cmd>set number<cr>", default_opts)
keymap.set({"n", "v"}, "<leader><leader>c", send_to_claude, default_opts)
keymap.set({"n", "v"}, "<leader><leader>f", send_filepath_to_claude, default_opts)
keymap.set({"n", "v"}, "<leader><leader>y", copy_filepath_to_clipboard, default_opts)
keymap.set({"n", "v"}, "<leader><leader>g", open_in_github, default_opts)
keymap.set("n", "<leader>np", open_prompt_notes, default_opts)
