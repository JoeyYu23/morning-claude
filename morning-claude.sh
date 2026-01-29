#!/bin/bash
# Morning Claude - Opens Terminal with tmux and starts Claude Code

SESSION_NAME="morning-claude"

# Kill existing session if any
tmux kill-session -t "$SESSION_NAME" 2>/dev/null

# Open Terminal and create tmux session with claude
osascript -e 'tell application "Terminal" to activate' \
          -e "tell application \"Terminal\" to do script \"tmux new-session -s $SESSION_NAME 'claude'\""

# Wait for Claude to start
sleep 4

# Press Enter to confirm trust
tmux send-keys -t "$SESSION_NAME" Enter

# Wait for Claude to fully load
sleep 5

# Type "hi" and press Enter
tmux send-keys -t "$SESSION_NAME" "hi"
sleep 0.3
tmux send-keys -t "$SESSION_NAME" Enter
