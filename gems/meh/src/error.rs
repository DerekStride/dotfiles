use thiserror::Error;

#[derive(Error, Debug)]
pub enum MehError {
    #[error("Not running inside tmux")]
    NotInTmux,

    #[error("bg-tasks session does not exist. Run 'mux' to create it.")]
    BgTasksNotFound,

    #[error("No panes available in bg-tasks session")]
    NoPanesAvailable,

    #[error("fzf is required but not found in PATH")]
    FzfNotFound,

    #[error("No pane selected")]
    NoSelection,

    #[error("Failed to execute tmux command: {0}")]
    TmuxCommand(String),

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
}

pub type Result<T> = std::result::Result<T, MehError>;
