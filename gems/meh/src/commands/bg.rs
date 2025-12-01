use crate::error::{MehError, Result};
use crate::tmux;
use chrono::Local;

pub fn run() -> Result<()> {
    if !tmux::is_in_tmux() {
        return Err(MehError::NotInTmux);
    }

    tmux::ensure_bg_tasks()?;

    let window_name = generate_window_name()?;

    tmux::break_pane_to_bg_tasks(&window_name)?;

    Ok(())
}

/// Generate a window name based on current context
/// Priority: running command (if not a shell) > window name > directory basename
fn generate_window_name() -> Result<String> {
    let timestamp = Local::now().format("%H%M%S").to_string();

    // Check if there's a meaningful command running (not just a shell)
    let command = tmux::current_pane_command()?;
    let shells = ["zsh", "bash", "fish", "sh", "dash", "ksh", "tcsh", "csh"];

    if !shells.contains(&command.as_str()) && !command.is_empty() {
        return Ok(format!("{}-{}", command, timestamp));
    }

    // Fall back to window name if meaningful
    let window_name = tmux::current_window_name()?;
    if !window_name.chars().all(|c| c.is_ascii_digit()) {
        return Ok(format!("{}-{}", window_name, timestamp));
    }

    // Last resort: use directory basename
    let path = tmux::current_pane_path()?;
    let base_name = std::path::Path::new(&path)
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or(&window_name);

    Ok(format!("{}-{}", base_name, timestamp))
}
