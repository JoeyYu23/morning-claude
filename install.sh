#!/bin/bash
# Install morning-claude launchd service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_NAME="com.user.morning-claude.plist"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "Installing morning-claude..."

# Create logs directory
mkdir -p "$SCRIPT_DIR/logs"

# Make script executable
chmod +x "$SCRIPT_DIR/morning-claude.sh"

# Copy plist to LaunchAgents
cp "$SCRIPT_DIR/$PLIST_NAME" "$LAUNCH_AGENTS_DIR/"

# Load the service
launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME"

echo "Installed! Claude will open every day at 9:00 AM."
echo ""
echo "Useful commands:"
echo "  Uninstall: launchctl unload ~/Library/LaunchAgents/$PLIST_NAME"
echo "  Test now:  bash $SCRIPT_DIR/morning-claude.sh"
echo "  View logs: cat $SCRIPT_DIR/logs/stdout.log"
