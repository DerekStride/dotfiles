use crate::error::{MehError, Result};
use std::io::Write;
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

#[derive(Debug)]
pub enum ClaudeStatus {
    Idle,
    AwaitingInput(String),
    Working,
    Unknown,
}

impl ClaudeStatus {
    fn icon(&self) -> &'static str {
        match self {
            ClaudeStatus::Idle => "💤",
            ClaudeStatus::AwaitingInput(_) => "⏳",
            ClaudeStatus::Working => "🔄",
            ClaudeStatus::Unknown => "❓",
        }
    }

    fn label(&self) -> String {
        match self {
            ClaudeStatus::Idle => "Idle".to_string(),
            ClaudeStatus::AwaitingInput(msg) => format!("Awaiting: {}", msg),
            ClaudeStatus::Working => "Working".to_string(),
            ClaudeStatus::Unknown => "Unknown".to_string(),
        }
    }
}

impl ClaudePane {
    fn display(&self) -> String {
        let home = std::env::var("HOME").unwrap_or_default();
        let path = self.pane_path.replace(&home, "~");
        let short_path = path.split('/').last().unwrap_or(&path);

        format!(
            "{} {} │ {}:{} │ {}",
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

    let panes = list_claude_panes()?;

    if panes.is_empty() {
        return Err(MehError::NoPanesAvailable);
    }

    let selected = select_pane_with_fzf(&panes)?;

    // Switch to the selected session and window
    switch_to_pane(&selected)?;

    Ok(())
}

fn list_claude_panes() -> Result<Vec<ClaudePane>> {
    // List all panes with node command (Claude Code runs on Node.js)
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
        _ => return ClaudeStatus::Unknown,
    };

    // Get the last ~10 lines for status detection
    let lines: Vec<&str> = content.lines().rev().take(15).collect();
    let recent = lines.join("\n").to_lowercase();

    // Check for various status indicators
    if recent.contains("accept edits") || recent.contains("shift+tab") {
        return ClaudeStatus::AwaitingInput("accept edits".to_string());
    }

    if recent.contains("y/n") || recent.contains("[y]") || recent.contains("(y/n)") {
        return ClaudeStatus::AwaitingInput("y/n prompt".to_string());
    }

    if recent.contains("approve?") || recent.contains("permission") {
        return ClaudeStatus::AwaitingInput("permission".to_string());
    }

    // Check for working indicators (spinner characters, progress)
    if recent.contains("⠋") || recent.contains("⠙") || recent.contains("⠹")
        || recent.contains("⠸") || recent.contains("⠼") || recent.contains("⠴")
        || recent.contains("⠦") || recent.contains("⠧") || recent.contains("⠇")
        || recent.contains("⠏")
    {
        return ClaudeStatus::Working;
    }

    // Check for tool usage indicators
    if recent.contains("running") || recent.contains("reading") || recent.contains("writing")
        || recent.contains("searching") || recent.contains("executing")
    {
        return ClaudeStatus::Working;
    }

    // Check for idle - prompt with just ">"
    let last_nonblank: Vec<&str> = content
        .lines()
        .rev()
        .filter(|l| !l.trim().is_empty() && !l.contains('─'))
        .take(3)
        .collect();

    if last_nonblank.iter().any(|l| l.trim() == ">" || l.trim().starts_with("> ")) {
        return ClaudeStatus::Idle;
    }

    // Check for shortcuts hint (idle state)
    if recent.contains("? for shortcuts") {
        return ClaudeStatus::Idle;
    }

    ClaudeStatus::Unknown
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
