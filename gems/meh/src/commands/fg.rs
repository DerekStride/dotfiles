use crate::error::{MehError, Result};
use crate::tmux::{self, BgPane};
use std::io::Write;
use std::process::{Command, Stdio};

pub fn run() -> Result<()> {
    if !tmux::is_in_tmux() {
        return Err(MehError::NotInTmux);
    }

    if !tmux::fzf_available() {
        return Err(MehError::FzfNotFound);
    }

    tmux::ensure_bg_tasks()?;

    let panes: Vec<_> = tmux::list_bg_panes()?
        .into_iter()
        .filter(|p| p.window_name != "primary")
        .collect();

    if panes.is_empty() {
        return Err(MehError::NoPanesAvailable);
    }

    let selected = select_pane_with_fzf(&panes)?;

    tmux::join_pane_from_bg_tasks(&selected.target())?;

    println!("Brought '{}' back to current session", selected.window_name);

    Ok(())
}

fn select_pane_with_fzf(panes: &[BgPane]) -> Result<&BgPane> {
    // Prepare fzf input: index|display_string
    let fzf_input: String = panes
        .iter()
        .enumerate()
        .map(|(i, p)| format!("{}|{}", i, p.display()))
        .collect::<Vec<_>>()
        .join("\n");

    let mut fzf = Command::new("fzf")
        .args([
            "--prompt=Select pane to bring back: ",
            "--height=40%",
            "--reverse",
            "--header=bg-tasks panes",
            "--with-nth=2..",
            "--delimiter=|",
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
