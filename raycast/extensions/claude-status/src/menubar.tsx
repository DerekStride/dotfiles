import { MenuBarExtra, open, showHUD } from "@raycast/api";
import { useState, useEffect } from "react";
import {
  listClaudePanes,
  switchToPane,
  shortenPath,
  getStatusIcon,
  getStatusLabel,
  type ClaudePane,
} from "./utils";

function getMenuBarTitle(panes: ClaudePane[]): string {
  const awaitingCount = panes.filter((p) => p.status?.status === "awaiting").length;
  const workingCount = panes.filter((p) => p.status?.status === "working").length;

  const parts: string[] = [];
  if (awaitingCount > 0) parts.push(`⏳${awaitingCount}`);
  if (workingCount > 0) parts.push(`🔄${workingCount}`);

  return parts.length > 0 ? parts.join(" ") : "💤";
}

export default function Command() {
  const [panes, setPanes] = useState<ClaudePane[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadPanes = () => {
      setPanes(listClaudePanes());
      setIsLoading(false);
    };

    loadPanes();

    // Refresh every 3 seconds
    const interval = setInterval(loadPanes, 3000);
    return () => clearInterval(interval);
  }, []);

  const handleSwitchToPane = async (pane: ClaudePane) => {
    try {
      switchToPane(pane);
      await showHUD("Switched to Claude instance");
    } catch (error) {
      await showHUD(`Failed to switch: ${error}`);
    }
  };

  return (
    <MenuBarExtra
      icon="icon.png"
      title={getMenuBarTitle(panes)}
      isLoading={isLoading}
      tooltip="Claude Code Status"
    >
      {panes.length === 0 ? (
        <MenuBarExtra.Item title="No Claude instances" />
      ) : (
        panes.map((pane) => {
          const icon = getStatusIcon(pane.status);
          return (
            <MenuBarExtra.Item
              key={pane.paneId}
              icon={icon}
              title={`${getStatusLabel(pane.status)} - ${pane.sessionName}:${pane.windowName}`}
              subtitle={shortenPath(pane.panePath)}
              onAction={() => handleSwitchToPane(pane)}
            />
          );
        })
      )}
      <MenuBarExtra.Separator />
      <MenuBarExtra.Item
        title="Open Claude Instances..."
        onAction={() => open("raycast://extensions/derek/claude-status/index")}
      />
    </MenuBarExtra>
  );
}
