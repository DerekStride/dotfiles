use crate::error::{MehError, Result};
use serde_json::{json, Value};
use std::cmp::Ordering;
use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::{Command, Stdio};

/// Represents a Claude Code pane
#[derive(Debug)]
pub struct ClaudePane {
    pub pane_id: String,
    pub session_name: String,
    pub window_index: String,
    pub window_name: String,
    pub pane_index: String,
    pub pane_path: String,
    pub status: ClaudeStatus,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ClaudeStatus {
    AwaitingInput(String),
    Working,
    Idle,
}

impl ClaudeStatus {
    fn icon(&self) -> &'static str {
        match self {
            ClaudeStatus::AwaitingInput(_) => "⏳",
            ClaudeStatus::Working => "🔄",
            ClaudeStatus::Idle => "💤",
        }
    }

    fn label(&self) -> String {
        match self {
            ClaudeStatus::AwaitingInput(msg) => format!("Awaiting: {}", msg),
            ClaudeStatus::Working => "Working".to_string(),
            ClaudeStatus::Idle => "Idle".to_string(),
        }
    }

    /// Sort priority: AwaitingInput (0) > Working (1) > Idle (2)
    fn priority(&self) -> u8 {
        match self {
            ClaudeStatus::AwaitingInput(_) => 0,
            ClaudeStatus::Working => 1,
            ClaudeStatus::Idle => 2,
        }
    }
}

impl Ord for ClaudeStatus {
    fn cmp(&self, other: &Self) -> Ordering {
        self.priority().cmp(&other.priority())
    }
}

impl PartialOrd for ClaudeStatus {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl ClaudePane {
    fn display(&self) -> String {
        let home = std::env::var("HOME").unwrap_or_default();
        let path = self.pane_path.replace(&home, "~");
        let short_path = path.split('/').last().unwrap_or(&path);

        format!(
            "{} {:<20} │ {}:{} │ {}",
            self.status.icon(),
            self.status.label(),
            self.session_name,
            self.window_name,
            short_path,
        )
    }

    fn target(&self) -> String {
        format!("{}:{}.{}", self.session_name, self.window_index, self.pane_index)
    }
}

pub fn run() -> Result<()> {
    if !crate::tmux::is_in_tmux() {
        return Err(MehError::NotInTmux);
    }

    if !crate::tmux::fzf_available() {
        return Err(MehError::FzfNotFound);
    }

    let mut panes = list_claude_panes()?;

    if panes.is_empty() {
        return Err(MehError::NoPanesAvailable);
    }

    // Sort by status priority: AwaitingInput first, Working middle, Idle last
    panes.sort_by(|a, b| a.status.cmp(&b.status));

    let selected = select_pane_with_fzf(&panes)?;

    // Switch to the selected session and window
    switch_to_pane(&selected)?;

    Ok(())
}

/// Check if a pane is actually running Claude Code by examining its content
fn is_claude_pane(pane_id: &str) -> bool {
    let output = Command::new("tmux")
        .args(["capture-pane", "-t", pane_id, "-p"])
        .output();

    let content = match output {
        Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout).to_string(),
        _ => return false,
    };

    // Claude Code has distinctive UI elements:
    // 1. Horizontal line separators made of ─ characters
    // 2. The > prompt for input
    // 3. Footer hints like "? for shortcuts" or "⏵⏵ accept edits"
    // 4. Tool output markers like ⏺ (filled circle)

    let has_separator = content.contains('─');
    let has_prompt = content.lines().any(|l| {
        let trimmed = l.trim();
        trimmed == ">" || trimmed.starts_with("> ")
    });
    let has_footer = content.contains("? for shortcuts")
        || content.contains("⏵⏵")
        || content.contains("shift+tab");
    let has_tool_marker = content.contains('⏺');

    // Must have at least 2 of these indicators to be considered Claude
    let indicators = [has_separator, has_prompt, has_footer, has_tool_marker];
    indicators.iter().filter(|&&x| x).count() >= 2
}

fn list_claude_panes() -> Result<Vec<ClaudePane>> {
    let output = Command::new("tmux")
        .args([
            "list-panes",
            "-a",
            "-F",
            "#{pane_id}|#{session_name}|#{window_index}|#{window_name}|#{pane_index}|#{pane_current_command}|#{pane_current_path}",
        ])
        .output()?;

    if !output.status.success() {
        return Err(MehError::TmuxCommand("Failed to list panes".into()));
    }

    let panes: Vec<ClaudePane> = String::from_utf8_lossy(&output.stdout)
        .lines()
        .filter_map(|line| {
            let parts: Vec<&str> = line.split('|').collect();
            if parts.len() >= 7 && parts[5] == "node" {
                let pane_id = parts[0].to_string();

                // Verify this is actually a Claude Code pane
                if !is_claude_pane(&pane_id) {
                    return None;
                }

                let status = get_pane_status(&pane_id);

                Some(ClaudePane {
                    pane_id,
                    session_name: parts[1].to_string(),
                    window_index: parts[2].to_string(),
                    window_name: parts[3].to_string(),
                    pane_index: parts[4].to_string(),
                    pane_path: parts[6].to_string(),
                    status,
                })
            } else {
                None
            }
        })
        .collect();

    Ok(panes)
}

fn get_pane_status(pane_id: &str) -> ClaudeStatus {
    let output = Command::new("tmux")
        .args(["capture-pane", "-t", pane_id, "-p"])
        .output();

    let content = match output {
        Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout).to_string(),
        _ => return ClaudeStatus::Idle,
    };

    // Get the last section of the pane (after last separator)
    let lines: Vec<&str> = content.lines().collect();

    // Find the last separator line and get content after it
    let last_sep_idx = lines.iter().rposition(|l| {
        l.chars().all(|c| c == '─' || c.is_whitespace()) && l.contains('─')
    });

    let footer_lines: Vec<&str> = match last_sep_idx {
        Some(idx) => lines[idx..].to_vec(),
        None => lines.iter().rev().take(10).copied().collect(),
    };
    let footer = footer_lines.join("\n").to_lowercase();

    // Check for awaiting input states (most specific first)
    if footer.contains("⏵⏵") || footer.contains("accept edits") || footer.contains("shift+tab") {
        return ClaudeStatus::AwaitingInput("accept edits".to_string());
    }

    if footer.contains("allow once") || footer.contains("allow always") {
        return ClaudeStatus::AwaitingInput("permission".to_string());
    }

    if footer.contains("(y/n)") || footer.contains("[y/n]") || footer.contains("y/n?") {
        return ClaudeStatus::AwaitingInput("confirm".to_string());
    }

    // Check for working state - look in the visible content area
    let visible_content = lines.iter().rev().take(20).copied().collect::<Vec<_>>().join("\n");

    // Spinner characters indicate active work
    let spinners = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    if spinners.iter().any(|&s| visible_content.contains(s)) {
        return ClaudeStatus::Working;
    }

    // Active tool indicators (look for uncompleted tool output)
    if visible_content.contains("⏺ Bash(") && !visible_content.contains("⎿") {
        return ClaudeStatus::Working;
    }

    if visible_content.contains("⏺ Read(") && !visible_content.contains("⎿") {
        return ClaudeStatus::Working;
    }

    // Check if there's a prompt waiting for input (idle state)
    let non_empty_lines: Vec<&str> = footer_lines
        .iter()
        .filter(|l| !l.trim().is_empty() && !l.chars().all(|c| c == '─' || c.is_whitespace()))
        .copied()
        .collect();

    // If the last meaningful line is just ">" or starts with "> ", it's idle
    if let Some(last) = non_empty_lines.last() {
        let trimmed = last.trim();
        if trimmed == ">" || (trimmed.starts_with(">") && trimmed.len() < 3) {
            return ClaudeStatus::Idle;
        }
    }

    // Default to idle if we have shortcuts hint
    if footer.contains("? for shortcuts") {
        return ClaudeStatus::Idle;
    }

    // If nothing else matched but it's a Claude pane, assume working
    ClaudeStatus::Working
}

fn select_pane_with_fzf(panes: &[ClaudePane]) -> Result<&ClaudePane> {
    let fzf_input: String = panes
        .iter()
        .enumerate()
        .map(|(i, p)| format!("{}|{}", i, p.display()))
        .collect::<Vec<_>>()
        .join("\n");

    let mut fzf = Command::new("fzf")
        .args([
            "--prompt=Select Claude instance: ",
            "--height=40%",
            "--reverse",
            "--header=Claude Code Instances",
            "--with-nth=2..",
            "--delimiter=|",
            "--ansi",
            "--no-preview",
        ])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    if let Some(mut stdin) = fzf.stdin.take() {
        stdin.write_all(fzf_input.as_bytes())?;
    }

    let output = fzf.wait_with_output()?;

    if !output.status.success() {
        return Err(MehError::NoSelection);
    }

    let selection = String::from_utf8_lossy(&output.stdout);
    let index_str = selection.trim().split('|').next().ok_or(MehError::NoSelection)?;
    let index: usize = index_str.parse().map_err(|_| MehError::NoSelection)?;

    panes.get(index).ok_or(MehError::NoSelection)
}

fn switch_to_pane(pane: &ClaudePane) -> Result<()> {
    // Switch to the session
    let status = Command::new("tmux")
        .args(["switch-client", "-t", &pane.target()])
        .status()?;

    if !status.success() {
        return Err(MehError::TmuxCommand("Failed to switch to pane".into()));
    }

    // Select the specific pane
    let status = Command::new("tmux")
        .args(["select-pane", "-t", &pane.pane_id])
        .status()?;

    if !status.success() {
        return Err(MehError::TmuxCommand("Failed to select pane".into()));
    }

    Ok(())
}

/// Initialize Claude hooks for real-time status detection
pub fn init() -> Result<()> {
    let settings_path = get_claude_settings_path()?;

    // Read existing settings
    let content = fs::read_to_string(&settings_path).map_err(|e| {
        MehError::TmuxCommand(format!("Failed to read settings.json: {}", e))
    })?;

    let mut settings: Value = serde_json::from_str(&content).map_err(|e| {
        MehError::TmuxCommand(format!("Failed to parse settings.json: {}", e))
    })?;

    // Ensure hooks object exists
    if settings.get("hooks").is_none() {
        settings["hooks"] = json!({});
    }

    let hooks = settings["hooks"].as_object_mut().ok_or_else(|| {
        MehError::TmuxCommand("hooks is not an object".into())
    })?;

    // Status file command template
    let status_cmd = |status: &str| -> Value {
        json!([{
            "matcher": "",
            "hooks": [{
                "type": "command",
                "command": format!(
                    "mkdir -p ~/.claude/status && echo '{{\"status\":\"{}\",\"cwd\":\"'$(pwd)'\",\"timestamp\":'$(date +%s)'}}' > ~/.claude/status/${{TMUX_PANE}}.json",
                    status
                )
            }]
        }])
    };

    // Add/update hooks
    hooks.insert("Stop".to_string(), status_cmd("idle"));
    hooks.insert("UserPromptSubmit".to_string(), status_cmd("working"));
    hooks.insert("PermissionRequest".to_string(), status_cmd("awaiting"));
    hooks.insert("SessionEnd".to_string(), json!([{
        "matcher": "",
        "hooks": [{
            "type": "command",
            "command": "rm -f ~/.claude/status/${TMUX_PANE}.json"
        }]
    }]));

    // Update SessionStart to also set initial status
    if let Some(session_start) = hooks.get_mut("SessionStart") {
        if let Some(arr) = session_start.as_array_mut() {
            if let Some(first) = arr.first_mut() {
                if let Some(hook_arr) = first.get_mut("hooks").and_then(|h| h.as_array_mut()) {
                    // Check if status hook already exists
                    let has_status = hook_arr.iter().any(|h| {
                        h.get("command")
                            .and_then(|c| c.as_str())
                            .map(|s| s.contains("claude/status"))
                            .unwrap_or(false)
                    });
                    if !has_status {
                        hook_arr.push(json!({
                            "type": "command",
                            "command": "mkdir -p ~/.claude/status && echo '{\"status\":\"idle\",\"cwd\":\"'$(pwd)'\",\"timestamp\":'$(date +%s)'}' > ~/.claude/status/${TMUX_PANE}.json"
                        }));
                    }
                }
            }
        }
    }

    // Write back
    let output = serde_json::to_string_pretty(&settings).map_err(|e| {
        MehError::TmuxCommand(format!("Failed to serialize settings: {}", e))
    })?;

    fs::write(&settings_path, output).map_err(|e| {
        MehError::TmuxCommand(format!("Failed to write settings.json: {}", e))
    })?;

    // Create status directory
    let home = std::env::var("HOME").unwrap_or_default();
    let status_dir = PathBuf::from(&home).join(".claude/status");
    fs::create_dir_all(&status_dir).ok();

    println!("✓ Claude hooks configured for real-time status detection");
    println!("  Settings: {}", settings_path.display());
    println!("  Status dir: {}", status_dir.display());
    println!("\nHooks added:");
    println!("  • Stop → idle status");
    println!("  • UserPromptSubmit → working status");
    println!("  • PermissionRequest → awaiting status");
    println!("  • SessionEnd → cleanup status file");
    println!("  • SessionStart → initial idle status");

    Ok(())
}

fn get_claude_settings_path() -> Result<PathBuf> {
    let home = std::env::var("HOME").map_err(|_| {
        MehError::TmuxCommand("HOME environment variable not set".into())
    })?;

    let path = PathBuf::from(home).join(".claude/settings.json");

    if !path.exists() {
        return Err(MehError::TmuxCommand(format!(
            "Claude settings not found at {}",
            path.display()
        )));
    }

    Ok(path)
}
