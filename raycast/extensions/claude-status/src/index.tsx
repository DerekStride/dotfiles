import { ActionPanel, Action, List, Icon, Color, showToast, Toast } from "@raycast/api";
import { useState, useEffect } from "react";
import { readdirSync, readFileSync, existsSync } from "fs";
import { homedir } from "os";
import { join } from "path";
import { execSync } from "child_process";

const TMUX = "/opt/homebrew/bin/tmux";

interface ClaudeStatus {
  status: "idle" | "working" | "awaiting";
  cwd?: string;
  timestamp?: number;
}

interface ClaudePane {
  paneId: string;
  sessionName: string;
  windowIndex: string;
  windowName: string;
  paneIndex: string;
  panePath: string;
  status: ClaudeStatus | null;
}

function getStatusIcon(status: ClaudeStatus | null): { source: Icon; tintColor: Color } {
  if (!status) {
    return { source: Icon.QuestionMark, tintColor: Color.SecondaryText };
  }
  switch (status.status) {
    case "awaiting":
      return { source: Icon.Clock, tintColor: Color.Yellow };
    case "working":
      return { source: Icon.CircleProgress, tintColor: Color.Blue };
    case "idle":
      return { source: Icon.Moon, tintColor: Color.SecondaryText };
    default:
      return { source: Icon.QuestionMark, tintColor: Color.SecondaryText };
  }
}

function getStatusLabel(status: ClaudeStatus | null): string {
  if (!status) return "Unknown";
  switch (status.status) {
    case "awaiting":
      return "Awaiting Input";
    case "working":
      return "Working";
    case "idle":
      return "Idle";
    default:
      return "Unknown";
  }
}

function getStatusPriority(status: ClaudeStatus | null): number {
  if (!status) return 3;
  switch (status.status) {
    case "awaiting":
      return 0;
    case "working":
      return 1;
    case "idle":
      return 2;
    default:
      return 3;
  }
}

function readStatusFile(paneId: string): ClaudeStatus | null {
  const statusPath = join(homedir(), ".claude", "status", `${paneId}.json`);
  try {
    if (!existsSync(statusPath)) return null;
    const content = readFileSync(statusPath, "utf-8");
    return JSON.parse(content) as ClaudeStatus;
  } catch {
    return null;
  }
}

function listClaudePanes(): ClaudePane[] {
  try {
    // Get all status files - these are the source of truth for Claude instances
    const statusDir = join(homedir(), ".claude", "status");
    if (!existsSync(statusDir)) return [];

    const statusFiles = readdirSync(statusDir).filter((f) => f.endsWith(".json"));
    const statusPaneIds = new Set(statusFiles.map((f) => f.replace(".json", "")));

    // Get tmux pane info
    const output = execSync(
      `${TMUX} list-panes -a -F "#{pane_id}|#{session_name}|#{window_index}|#{window_name}|#{pane_index}|#{pane_current_command}|#{pane_current_path}"`,
      { encoding: "utf-8" }
    );

    const paneMap = new Map<string, string[]>();
    for (const line of output.trim().split("\n")) {
      const parts = line.split("|");
      if (parts.length >= 7) {
        paneMap.set(parts[0], parts);
      }
    }

    const panes: ClaudePane[] = [];

    // Only include panes that have status files AND still exist in tmux
    for (const paneId of statusPaneIds) {
      const parts = paneMap.get(paneId);
      if (!parts) continue; // Pane no longer exists

      const status = readStatusFile(paneId);

      panes.push({
        paneId,
        sessionName: parts[1],
        windowIndex: parts[2],
        windowName: parts[3],
        paneIndex: parts[4],
        panePath: parts[6],
        status,
      });
    }

    // Sort by status priority
    panes.sort((a, b) => getStatusPriority(a.status) - getStatusPriority(b.status));

    return panes;
  } catch {
    return [];
  }
}

function switchToPane(pane: ClaudePane) {
  try {
    const target = `${pane.sessionName}:${pane.windowIndex}.${pane.paneIndex}`;
    execSync(`${TMUX} switch-client -t "${target}"`);
    execSync(`${TMUX} select-pane -t "${pane.paneId}"`);
    showToast({ style: Toast.Style.Success, title: "Switched to Claude instance" });
  } catch (error) {
    showToast({ style: Toast.Style.Failure, title: "Failed to switch", message: String(error) });
  }
}

function shortenPath(path: string): string {
  const home = homedir();
  let shortened = path.replace(home, "~");
  const parts = shortened.split("/");
  return parts[parts.length - 1] || shortened;
}

export default function Command() {
  const [panes, setPanes] = useState<ClaudePane[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setPanes(listClaudePanes());
    setIsLoading(false);
  }, []);

  return (
    <List isLoading={isLoading}>
      {panes.length === 0 ? (
        <List.EmptyView
          icon={Icon.Terminal}
          title="No Claude instances found"
          description="Start Claude Code in a tmux session to see it here"
        />
      ) : (
        panes.map((pane) => (
          <List.Item
            key={pane.paneId}
            icon={getStatusIcon(pane.status)}
            title={getStatusLabel(pane.status)}
            subtitle={`${pane.sessionName}:${pane.windowName}`}
            accessories={[{ text: shortenPath(pane.panePath) }]}
            actions={
              <ActionPanel>
                <Action title="Switch to Pane" onAction={() => switchToPane(pane)} />
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
