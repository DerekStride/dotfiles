use crate::error::{MehError, Result};
use chrono::{DateTime, Utc};
use serde::Deserialize;
use std::cmp::Ordering;
use std::fs;
use std::io::{BufRead, BufReader, Write};
use std::path::PathBuf;
use std::process::{Command, Stdio};

/// Entry from Claude's session JSONL file
#[derive(Debug, Deserialize)]
struct SessionEntry {
    #[serde(rename = "type")]
    entry_type: Option<String>,
    timestamp: Option<String>,
}

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

    panes.sort_by(|a, b| a.status.cmp(&b.status));

    let selected = select_pane_with_fzf(&panes)?;
    switch_to_pane(&selected)?;

    Ok(())
}

/// Encode a cwd path to Claude's project folder format
/// /Users/derek/.dotfiles -> -Users-derek--dotfiles
fn encode_project_path(cwd: &str) -> String {
    cwd.replace('/', "-")
}

/// Find the most recently modified session file for a project
fn find_session_file(cwd: &str) -> Option<PathBuf> {
    let home = std::env::var("HOME").ok()?;
    let encoded = encode_project_path(cwd);
    let project_dir = PathBuf::from(format!("{}/.claude/projects/{}", home, encoded));

    if !project_dir.exists() {
        return None;
    }

    // Find the most recently modified .jsonl file
    fs::read_dir(&project_dir)
        .ok()?
        .filter_map(|e| e.ok())
        .filter(|e| {
            e.path()
                .extension()
                .map(|ext| ext == "jsonl")
                .unwrap_or(false)
        })
        .max_by_key(|e| e.metadata().and_then(|m| m.modified()).ok())
        .map(|e| e.path())
}

/// Read the last line of a JSONL file efficiently
fn read_last_jsonl_entry(path: &PathBuf) -> Option<SessionEntry> {
    let file = fs::File::open(path).ok()?;
    let reader = BufReader::new(file);

    // Read all lines and get the last non-empty one
    let last_line = reader
        .lines()
        .filter_map(|l| l.ok())
        .filter(|l| !l.trim().is_empty())
        .last()?;

    serde_json::from_str(&last_line).ok()
}

/// Get status from Claude's session file
fn get_status_from_session(cwd: &str) -> Option<ClaudeStatus> {
    let session_file = find_session_file(cwd)?;
    let entry = read_last_jsonl_entry(&session_file)?;

    let entry_type = entry.entry_type.as_deref()?;
    let timestamp_str = entry.timestamp.as_deref()?;

    // Parse timestamp
    let timestamp = DateTime::parse_from_rfc3339(timestamp_str)
        .ok()?
        .with_timezone(&Utc);
    let age = Utc::now().signed_duration_since(timestamp);

    match entry_type {
        "user" => Some(ClaudeStatus::Working), // Claude processing user input
        "assistant" => {
            // If response was recent (< 30s), might still be streaming
            if age.num_seconds() < 30 {
                Some(ClaudeStatus::Working)
            } else {
                Some(ClaudeStatus::Idle)
            }
        }
        _ => None,
    }
}

/// Check pane content for UI-specific awaiting states
fn check_pane_for_awaiting(pane_id: &str) -> Option<ClaudeStatus> {
    let output = Command::new("tmux")
        .args(["capture-pane", "-t", pane_id, "-p"])
        .output()
        .ok()?;

    if !output.status.success() {
        return None;
    }

    let content = String::from_utf8_lossy(&output.stdout);
    let lines: Vec<&str> = content.lines().collect();

    // Get footer area (after last separator)
    let last_sep_idx = lines.iter().rposition(|l| {
        l.chars().all(|c| c == '─' || c.is_whitespace()) && l.contains('─')
    });

    let footer_lines: Vec<&str> = match last_sep_idx {
        Some(idx) => lines[idx..].to_vec(),
        None => lines.iter().rev().take(10).copied().collect(),
    };
    let footer = footer_lines.join("\n").to_lowercase();

    // Check for UI-specific awaiting states
    if footer.contains("⏵⏵") || footer.contains("accept edits") || footer.contains("shift+tab") {
        return Some(ClaudeStatus::AwaitingInput("accept edits".to_string()));
    }

    if footer.contains("allow once") || footer.contains("allow always") {
        return Some(ClaudeStatus::AwaitingInput("permission".to_string()));
    }

    if footer.contains("(y/n)") || footer.contains("[y/n]") || footer.contains("y/n?") {
        return Some(ClaudeStatus::AwaitingInput("confirm".to_string()));
    }

    None
}

/// Check if a pane is actually running Claude Code
fn is_claude_pane(pane_id: &str) -> bool {
    let output = Command::new("tmux")
        .args(["capture-pane", "-t", pane_id, "-p"])
        .output();

    let content = match output {
        Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout).to_string(),
        _ => return false,
    };

    let has_separator = content.contains('─');
    let has_prompt = content.lines().any(|l| {
        let trimmed = l.trim();
        trimmed == ">" || trimmed.starts_with("> ")
    });
    let has_footer = content.contains("? for shortcuts")
        || content.contains("⏵⏵")
        || content.contains("shift+tab");
    let has_tool_marker = content.contains('⏺');

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
                let pane_path = parts[6].to_string();

                if !is_claude_pane(&pane_id) {
                    return None;
                }

                // Try file-based status first, then check for awaiting states
                let status = check_pane_for_awaiting(&pane_id)
                    .or_else(|| get_status_from_session(&pane_path))
                    .unwrap_or(ClaudeStatus::Idle);

                Some(ClaudePane {
                    pane_id,
                    session_name: parts[1].to_string(),
                    window_index: parts[2].to_string(),
                    window_name: parts[3].to_string(),
                    pane_index: parts[4].to_string(),
                    pane_path,
                    status,
                })
            } else {
                None
            }
        })
        .collect();

    Ok(panes)
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
    let status = Command::new("tmux")
        .args(["switch-client", "-t", &pane.target()])
        .status()?;

    if !status.success() {
        return Err(MehError::TmuxCommand("Failed to switch to pane".into()));
    }

    let status = Command::new("tmux")
        .args(["select-pane", "-t", &pane.pane_id])
        .status()?;

    if !status.success() {
        return Err(MehError::TmuxCommand("Failed to select pane".into()));
    }

    Ok(())
}
