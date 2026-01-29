#!/bin/bash
# Morning Claude - Opens Terminal with tmux and starts Claude Code

TMUX="/opt/homebrew/bin/tmux"
SESSION_NAME="morning-claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/logs/history.log"

# Log the open time
echo "$(date '+%Y-%m-%d %H:%M:%S') - Claude Code opened" >> "$LOG_FILE"

# Kill existing session if any
$TMUX kill-session -t "$SESSION_NAME" 2>/dev/null

# Open Terminal and create tmux session with claude
osascript -e 'tell application "Terminal" to activate' \
          -e "tell application \"Terminal\" to do script \"$TMUX new-session -s $SESSION_NAME 'claude'\""

# Wait for Claude to start (need more time for initial load)
sleep 6

# Press Enter to confirm trust
$TMUX send-keys -t "$SESSION_NAME" Enter

# Wait for Claude to fully load
sleep 8

# Type "hi" and press Enter
$TMUX send-keys -t "$SESSION_NAME" "hi"
sleep 0.3
$TMUX send-keys -t "$SESSION_NAME" Enter
