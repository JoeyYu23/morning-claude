#!/bin/bash
# Morning Claude - Opens Terminal and starts Claude Code

osascript <<EOF
tell application "Terminal"
    activate
    do script "claude"
end tell
EOF
