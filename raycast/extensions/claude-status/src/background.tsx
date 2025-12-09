import { showHUD, environment } from "@raycast/api";
import { readdirSync, readFileSync, existsSync, writeFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";
import { execSync } from "child_process";

const TMUX = "/opt/homebrew/bin/tmux";
const STATE_FILE = join(environment.supportPath, "last-known-state.json");

interface ClaudeStatus {
  status: "idle" | "working" | "awaiting";
  cwd?: string;
  timestamp?: number;
}

interface StatusState {
  [paneId: string]: "idle" | "working" | "awaiting";
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

function getPaneInfo(paneId: string): { sessionName: string; windowName: string; path: string } | null {
  try {
    const output = execSync(
      `${TMUX} list-panes -a -F "#{pane_id}|#{session_name}|#{window_name}|#{pane_current_path}"`,
      { encoding: "utf-8" }
    );

    for (const line of output.trim().split("\n")) {
      const parts = line.split("|");
      if (parts[0] === paneId) {
        return {
          sessionName: parts[1],
          windowName: parts[2],
          path: parts[3],
        };
      }
    }
    return null;
  } catch {
    return null;
  }
}

function shortenPath(path: string): string {
  const home = homedir();
  let shortened = path.replace(home, "~");
  const parts = shortened.split("/");
  return parts[parts.length - 1] || shortened;
}

function loadLastState(): StatusState {
  try {
    if (existsSync(STATE_FILE)) {
      const content = readFileSync(STATE_FILE, "utf-8");
      return JSON.parse(content) as StatusState;
    }
  } catch {
    // If we can't load, start fresh
  }
  return {};
}

function saveLastState(state: StatusState): void {
  try {
    writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
  } catch {
    // Ignore errors - this is best-effort
  }
}

function sendNotification(paneId: string, paneInfo: { sessionName: string; windowName: string; path: string }): void {
  const title = "Claude Needs Input";
  const message = `${paneInfo.sessionName}:${paneInfo.windowName} • ${shortenPath(paneInfo.path)}`;

  try {
    // Use macOS native notification system
    execSync(
      `osascript -e 'display notification "${message}" with title "${title}" sound name "Ping"'`,
      { encoding: "utf-8" }
    );
  } catch {
    // Fallback to HUD if notification fails
    showHUD(`${title}: ${message}`);
  }
}

export default async function Command() {
  const statusDir = join(homedir(), ".claude", "status");
  if (!existsSync(statusDir)) {
    return;
  }

  const lastState = loadLastState();
  const currentState: StatusState = {};
  const newlyAwaiting: string[] = [];

  // Read all current status files
  const statusFiles = readdirSync(statusDir).filter((f) => f.endsWith(".json"));

  for (const file of statusFiles) {
    const paneId = file.replace(".json", "");
    const status = readStatusFile(paneId);

    if (!status) continue;

    currentState[paneId] = status.status;

    // Check if this pane just transitioned to "awaiting"
    const previousStatus = lastState[paneId];
    if (status.status === "awaiting" && previousStatus !== "awaiting") {
      newlyAwaiting.push(paneId);
    }
  }

  // Send notifications for newly awaiting instances
  for (const paneId of newlyAwaiting) {
    const paneInfo = getPaneInfo(paneId);
    if (paneInfo) {
      sendNotification(paneId, paneInfo);
    }
  }

  // Save current state for next check
  saveLastState(currentState);
}
