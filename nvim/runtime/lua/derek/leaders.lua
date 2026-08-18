local keymap = vim.keymap
local default_opts = { silent = true, noremap = true }

local function run_herdr(args)
  local herdr = vim.env.HERDR_BIN_PATH
  if not herdr or herdr == "" then
    herdr = "herdr"
  end

  local command = { herdr }
  vim.list_extend(command, args)

  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    local message = vim.trim(output)
    return nil, message ~= "" and message or "Herdr command failed"
  end

  return output
end

local function run_herdr_json(args)
  local output, command_error = run_herdr(args)
  if not output then
    return nil, command_error
  end

  local ok, response = pcall(vim.json.decode, output)
  if not ok or type(response) ~= "table" or type(response.result) ~= "table" then
    return nil, "Herdr returned an invalid response"
  end

  return response.result
end

local function find_agent_pane()
  if not vim.env.HERDR_PANE_ID or vim.env.HERDR_PANE_ID == "" then
    print("Not running inside a Herdr pane")
    return nil
  end

  local current_result, current_error = run_herdr_json({ "pane", "current", "--current" })
  if not current_result then
    print("Could not identify the current Herdr pane: " .. current_error)
    return nil
  end

  local agents_result, agents_error = run_herdr_json({ "agent", "list" })
  if not agents_result then
    print("Could not list Herdr agents: " .. agents_error)
    return nil
  end

  local current_pane = current_result.pane
  for _, agent in ipairs(agents_result.agents or {}) do
    if agent.tab_id == current_pane.tab_id and agent.pane_id ~= current_pane.pane_id then
      return agent
    end
  end

  print("No agent pane found in the current Herdr tab")
  return nil
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

local function send_to_agent_pane(content, description)
  local agent = find_agent_pane()
  if not agent then
    return
  end

  local _, send_error = run_herdr({ "pane", "send-text", agent.pane_id, content })
  if send_error then
    print("Could not send text to the agent pane: " .. send_error)
    return
  end

  print(string.format("%s (%s, pane %s)", description, agent.agent or "agent", agent.pane_id))
end

local function send_to_agent()
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
    print("No text to send to the agent")
    return
  end

  send_to_agent_pane(text, "Sent " .. #text .. " characters to the agent")
end

local function send_filepath_to_agent()
  local filepath = vim.fn.expand("%:p")

  if filepath == "" then
    print("No file currently open")
    return
  end

  local relative_path = "@" .. get_relative_filepath(filepath)

  send_to_agent_pane(relative_path, "Sent filepath to the agent: " .. relative_path)
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

  -- If origin points to the Git Stream mirror, prefer the 'github' remote
  if remote_url:match("gitstream%.shopify%.io") then
    local github_remote = vim.fn.system("git remote get-url github 2>/dev/null"):gsub("%s+", "")
    if github_remote ~= "" then
      remote_url = github_remote
    end
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
keymap.set({"n", "v"}, "<leader><leader>c", send_to_agent, default_opts)
keymap.set({"n", "v"}, "<leader><leader>f", send_filepath_to_agent, default_opts)
keymap.set({"n", "v"}, "<leader><leader>y", copy_filepath_to_clipboard, default_opts)
keymap.set({"n", "v"}, "<leader><leader>g", open_in_github, default_opts)
keymap.set("n", "<leader>np", open_prompt_notes, default_opts)
