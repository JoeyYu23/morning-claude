#!/bin/bash
# Uninstall morning-claude launchd service

PLIST_NAME="com.user.morning-claude.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "Uninstalling morning-claude..."

# Unload the service
launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_NAME" 2>/dev/null || true

# Remove plist
rm -f "$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo "Uninstalled!"
