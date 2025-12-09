use clap::{Parser, Subcommand};

mod commands;
mod error;
mod tmux;

use commands::{bg, claude, fg};

#[derive(Parser)]
#[command(name = "meh")]
#[command(about = "Manage tmux background tasks", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Move the current pane to the bg-tasks session
    Bg,
    /// Claude Code instance management
    Claude {
        #[command(subcommand)]
        action: Option<ClaudeAction>,
    },
    /// Select a pane from bg-tasks and bring it to the current session
    Fg,
}

#[derive(Subcommand)]
enum ClaudeAction {
    /// Set up Claude hooks for real-time status detection
    Init,
}

fn main() {
    let cli = Cli::parse();

    let result = match cli.command {
        Commands::Bg => bg::run(),
        Commands::Claude { action } => match action {
            Some(ClaudeAction::Init) => claude::init(),
            None => claude::run(),
        },
        Commands::Fg => fg::run(),
    };

    if let Err(e) = result {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}
