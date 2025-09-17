local keymap = vim.keymap
local default_opts = { silent = true, noremap = true }

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

  local escaped_text = vim.fn.shellescape(text)

  -- Find the Claude Code pane
  local find_claude_cmd = "tmux list-panes -F '#{pane_id} #{pane_current_command}' | grep -E '(claude|node)' | head -1 | cut -d' ' -f1"
  local claude_pane = vim.fn.system(find_claude_cmd):gsub("%s+", "")

  if claude_pane == "" then
    print("No Claude Code pane found. Make sure claude code is running in a tmux pane.")
    return
  end

  local tmux_cmd = string.format(
    "tmux send-keys -t %s %s Enter",
    claude_pane,
    escaped_text
  )

  vim.fn.system("bash -c " .. vim.fn.shellescape(tmux_cmd))
  print("Sent " .. #text .. " characters to Claude Code (pane " .. claude_pane .. ")")
end

local function open_scratch_prompt()
  local scratch_dir = vim.fn.expand("$SCRATCH")
  if scratch_dir == "$SCRATCH" or scratch_dir == "" then
    print("SCRATCH environment variable not set")
    return
  end

  local git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+", "")
  if git_branch == "" then
    git_branch = "no-git"
  end

  local prompts_dir = scratch_dir .. "/prompts"
  local prompt_file = prompts_dir .. "/" .. git_branch .. ".md"

  vim.cmd("wincmd s")
  vim.cmd("edit " .. vim.fn.fnameescape(prompt_file))
end

keymap.set("n", "<leader><leader>m", "<cmd>!mux split<cr><cr>", default_opts)
keymap.set("n", "<leader><leader>s", "<cmd>set nonumber<cr>", default_opts)
keymap.set("n", "<leader><leader>p", "<cmd>set number<cr>", default_opts)
keymap.set({"n", "v"}, "<leader><leader>c", send_to_claude, default_opts)
keymap.set("n", "<leader>np", open_scratch_prompt, default_opts)
