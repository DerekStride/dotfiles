use crate::error::{MehError, Result};
use std::process::{Command, Stdio};

const BG_TASKS_SESSION: &str = "bg-tasks";

/// Check if we're running inside tmux
pub fn is_in_tmux() -> bool {
    std::env::var("TMUX").is_ok()
}

/// Check if a tmux session exists
pub fn session_exists(session: &str) -> Result<bool> {
    let output = Command::new("tmux")
        .args(["has-session", "-t", session])
        .stderr(Stdio::null())
        .status()?;

    Ok(output.success())
}

/// Ensure bg-tasks session exists
pub fn ensure_bg_tasks() -> Result<()> {
    if !session_exists(BG_TASKS_SESSION)? {
        return Err(MehError::BgTasksNotFound);
    }
    Ok(())
}

/// Get the current window name
pub fn current_window_name() -> Result<String> {
    let output = Command::new("tmux")
        .args(["display-message", "-p", "#{window_name}"])
        .output()?;

    if !output.status.success() {
        return Err(MehError::TmuxCommand("Failed to get current window name".into()));
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

/// Get the current pane's working directory
pub fn current_pane_path() -> Result<String> {
    let output = Command::new("tmux")
        .args(["display-message", "-p", "#{pane_current_path}"])
        .output()?;

    if !output.status.success() {
        return Err(MehError::TmuxCommand("Failed to get pane path".into()));
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

/// Get the current pane's running command
pub fn current_pane_command() -> Result<String> {
    let output = Command::new("tmux")
        .args(["display-message", "-p", "#{pane_current_command}"])
        .output()?;

    if !output.status.success() {
        return Err(MehError::TmuxCommand("Failed to get pane command".into()));
    }

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

/// Break the current pane and move it to bg-tasks session
pub fn break_pane_to_bg_tasks(window_name: &str) -> Result<()> {
    let status = Command::new("tmux")
        .args([
            "break-pane",
            "-d",
            "-t", &format!("{}:", BG_TASKS_SESSION),
            "-n", window_name,
        ])
        .status()?;

    if !status.success() {
        return Err(MehError::TmuxCommand("Failed to break pane".into()));
    }

    Ok(())
}

/// Represents a pane in the bg-tasks session
#[derive(Debug)]
pub struct BgPane {
    pub window_index: String,
    pub window_name: String,
    pub pane_index: String,
    pub pane_current_command: String,
    pub pane_current_path: String,
}

impl BgPane {
    /// Format for fzf display
    pub fn display(&self) -> String {
        let home = std::env::var("HOME").unwrap_or_default();
        let path = self.pane_current_path.replace(&home, "~");

        format!(
            "{}: {} [{}] ({})",
            self.window_name, self.pane_current_command, path, self.pane_index
        )
    }

    /// Target string for tmux join-pane
    pub fn target(&self) -> String {
        format!("{}:{}.{}", BG_TASKS_SESSION, self.window_index, self.pane_index)
    }
}

/// List all panes in the bg-tasks session
pub fn list_bg_panes() -> Result<Vec<BgPane>> {
    let output = Command::new("tmux")
        .args([
            "list-panes",
            "-s",
            "-t", BG_TASKS_SESSION,
            "-F", "#{window_index}|#{window_name}|#{pane_index}|#{pane_current_command}|#{pane_current_path}",
        ])
        .output()?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        if stderr.contains("can't find session") {
            return Err(MehError::BgTasksNotFound);
        }
        return Err(MehError::TmuxCommand(stderr.to_string()));
    }

    let panes: Vec<BgPane> = String::from_utf8_lossy(&output.stdout)
        .lines()
        .filter_map(|line| {
            let parts: Vec<&str> = line.split('|').collect();
            if parts.len() >= 5 {
                Some(BgPane {
                    window_index: parts[0].to_string(),
                    window_name: parts[1].to_string(),
                    pane_index: parts[2].to_string(),
                    pane_current_command: parts[3].to_string(),
                    pane_current_path: parts[4].to_string(),
                })
            } else {
                None
            }
        })
        .collect();

    Ok(panes)
}

/// Join a pane from bg-tasks to the current session
pub fn join_pane_from_bg_tasks(target: &str) -> Result<()> {
    let status = Command::new("tmux")
        .args(["join-pane", "-s", target])
        .status()?;

    if !status.success() {
        return Err(MehError::TmuxCommand("Failed to join pane".into()));
    }

    Ok(())
}

/// Check if fzf is available
pub fn fzf_available() -> bool {
    Command::new("which")
        .arg("fzf")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}
