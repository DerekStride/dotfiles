import { ActionPanel, Action, List, Icon, showToast, Toast } from "@raycast/api";
import { useState, useEffect } from "react";
import { execSync } from "child_process";
import {
  listClaudePanes,
  switchToPane,
  shortenPath,
  getStatusIcon,
  getStatusLabel,
  getStatusPriority,
  TMUX,
  type ClaudePane,
} from "./utils";

function handleSwitchToPane(pane: ClaudePane) {
  try {
    switchToPane(pane);
    showToast({ style: Toast.Style.Success, title: "Switched to Claude instance" });
  } catch (error) {
    showToast({ style: Toast.Style.Failure, title: "Failed to switch", message: String(error) });
  }
}

function sendKeysToPane(paneId: string, keys: string, description: string) {
  try {
    execSync(`${TMUX} send-keys -t ${paneId} ${keys}`);
    showToast({ style: Toast.Style.Success, title: `Sent ${description}` });
  } catch (error) {
    showToast({ style: Toast.Style.Failure, title: `Failed to send ${description}`, message: String(error) });
  }
}

function allowAllAwaiting(panes: ClaudePane[]) {
  try {
    const awaitingPanes = panes.filter((pane) => pane.status?.status === "awaiting");

    if (awaitingPanes.length === 0) {
      showToast({ style: Toast.Style.Failure, title: "No awaiting instances found" });
      return;
    }

    for (const pane of awaitingPanes) {
      execSync(`${TMUX} send-keys -t "${pane.paneId}" a`);
    }

    showToast({
      style: Toast.Style.Success,
      title: `Allowed ${awaitingPanes.length} instance${awaitingPanes.length === 1 ? "" : "s"}`,
    });
  } catch (error) {
    showToast({ style: Toast.Style.Failure, title: "Failed to allow instances", message: String(error) });
  }
}

function sortPanes(panes: ClaudePane[]): ClaudePane[] {
  // Sort by: Status (actionable first) -> Session Name -> Directory Name
  return [...panes].sort((a, b) => {
    // Status priority: awaiting (0) > working (1) > idle (2) > unknown (3)
    const statusCmp = getStatusPriority(a.status) - getStatusPriority(b.status);
    if (statusCmp !== 0) return statusCmp;

    const sessionCmp = a.sessionName.localeCompare(b.sessionName);
    if (sessionCmp !== 0) return sessionCmp;

    return shortenPath(a.panePath).localeCompare(shortenPath(b.panePath));
  });
}

export default function Command() {
  const [panes, setPanes] = useState<ClaudePane[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Initial load
    setPanes(listClaudePanes());
    setIsLoading(false);

    // Auto-refresh every 3 seconds
    const intervalId = setInterval(() => {
      setPanes(listClaudePanes());
    }, 3000);

    // Cleanup interval on unmount
    return () => clearInterval(intervalId);
  }, []);

  const sortedPanes = sortPanes(panes);

  return (
    <List isLoading={isLoading}>
      {panes.length === 0 ? (
        <List.EmptyView
          icon={Icon.Terminal}
          title="No Claude instances found"
          description="Start Claude Code in a tmux session to see it here"
        />
      ) : (
        sortedPanes.map((pane) => (
          <List.Item
            key={pane.paneId}
            icon={getStatusIcon(pane.status)}
            title={shortenPath(pane.panePath)}
            subtitle={pane.gitBranch || pane.windowName}
            keywords={[pane.gitBranch, pane.sessionName, pane.windowName, pane.panePath].filter(Boolean) as string[]}
            accessories={[
              { tag: pane.sessionName },
              { text: getStatusLabel(pane.status) },
            ]}
            actions={
              <ActionPanel>
                <Action title="Switch to Pane" onAction={() => switchToPane(pane)} />
                <ActionPanel.Section title="Quick Commands">
                  <Action
                    title="Allow"
                    icon={Icon.Check}
                    onAction={() => sendKeysToPane(pane.paneId, "2", "Allow")}
                    shortcut={{ modifiers: ["cmd", "opt", "ctrl"], key: "a" }}
                  />
                  <Action
                    title="Cycle Mode"
                    icon={Icon.CheckCircle}
                    onAction={() => sendKeysToPane(pane.paneId, "BTab", "Cycle Mode")}
                    shortcut={{ modifiers: ["cmd", "shift"], key: "a" }}
                  />
                  <Action
                    title="Send Yes"
                    icon={Icon.Checkmark}
                    onAction={() => sendKeysToPane(pane.paneId, "1", "Yes")}
                    shortcut={{ modifiers: ["cmd"], key: "y" }}
                  />
                </ActionPanel.Section>
                <ActionPanel.Section>
                  <Action
                    title="Allow All Awaiting"
                    onAction={() => allowAllAwaiting(panes)}
                    icon={Icon.CheckRosette}
                    shortcut={{ modifiers: ["cmd", "shift"], key: "r" }}
                  />
                </ActionPanel.Section>
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
