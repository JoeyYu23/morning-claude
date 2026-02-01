# Morning Claude ☀️

A macOS automation tool that starts your day with Claude Code. Automatically opens Terminal, launches Claude in a tmux session, and greets you at your preferred time every morning.

## Why?

**Claude Code has a 5-hour usage limit reset cycle.** By automatically starting Claude before you wake up, the timer starts early — so by the time you're ready to work, you're closer to your next reset window.

```
Without Morning Claude:
  You wake up at 9:00 AM → Start Claude → 5-hour limit begins
  Heavy usage → Hit limit around 11:00 AM → Wait until 2:00 PM

With Morning Claude (set to 7:00 AM):
  7:00 AM → Claude auto-starts, timer begins (you're still asleep)
  9:00 AM → You wake up, 2 hours already elapsed
  Heavy usage → Hit limit around 11:00 AM → Reset at 12:00 PM (2 hours earlier!)
```

## Features

- 🕐 **Scheduled Launch**: Uses macOS launchd to start Claude Code at a configured time
- 🖥️ **tmux Integration**: Runs Claude in a persistent tmux session for reliability
- 👋 **Auto Greeting**: Automatically sends "hi" to start the conversation
- 📝 **Activity Logging**: Records when Claude opens and your first message of the day
- 🔧 **Easy Configuration**: Simple scripts for install, uninstall, and customization

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    macOS launchd                            │
│         Triggers at configured time (default: 7:00 AM)      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   morning-claude.sh                         │
│  1. Logs the open time to history.log                       │
│  2. Kills any existing tmux session                         │
│  3. Opens Terminal.app via AppleScript                      │
│  4. Creates new tmux session named "morning-claude"         │
│  5. Starts Claude Code CLI                                  │
│  6. Waits for Claude to load (~14 seconds)                  │
│  7. Sends Enter to confirm trust prompt                     │
│  8. Sends "hi" + Enter to start conversation                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              hooks/record_first_message.py                  │
│  (Claude Code UserPromptSubmit hook)                        │
│  - Detects "hi" trigger from morning script                 │
│  - Records your first real message of the day               │
│  - Tracks daily interaction patterns                        │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

- **macOS** (uses launchd and AppleScript)
- **Homebrew** - [Install here](https://brew.sh)
- **tmux** - Terminal multiplexer
- **Claude Code CLI** - [Download here](https://claude.ai/download)

## Installation

### Step 1: Install tmux

```bash
brew install tmux
```

### Step 2: Clone the repository

```bash
git clone https://github.com/JoeyYu23/morning-claude.git
cd morning-claude
```

### Step 3: Configure tmux path

Find your tmux installation path:

```bash
which tmux
```

Edit `morning-claude.sh` and update the path if different from default:

```bash
TMUX="/opt/homebrew/bin/tmux"  # Apple Silicon default
# TMUX="/usr/local/bin/tmux"   # Intel Mac default
```

### Step 4: Configure schedule time

Edit `com.user.morning-claude.plist`:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>7</integer>    <!-- 0-23 (24-hour format) -->
    <key>Minute</key>
    <integer>0</integer>    <!-- 0-59 -->
</dict>
```

### Step 5: Update paths in plist

Edit `com.user.morning-claude.plist` and replace `/Users/ycy/Projects/morning-claude` with your actual path:

```xml
<key>ProgramArguments</key>
<array>
    <string>/bin/bash</string>
    <string>/YOUR/PATH/TO/morning-claude/morning-claude.sh</string>
</array>
<key>StandardOutPath</key>
<string>/YOUR/PATH/TO/morning-claude/logs/stdout.log</string>
<key>StandardErrorPath</key>
<string>/YOUR/PATH/TO/morning-claude/logs/stderr.log</string>
```

### Step 6: Install the service

```bash
chmod +x *.sh
./install.sh
```

### Step 7: Grant permissions

Go to **System Settings → Privacy & Security → Accessibility** and enable **Terminal**.

This allows the script to open Terminal and send keystrokes.

### Step 8: Verify installation

```bash
# Check if service is loaded
launchctl list | grep morning

# Test manually
./morning-claude.sh
```

## Usage

| Command | Description |
|---------|-------------|
| `./install.sh` | Install the scheduled launchd service |
| `./uninstall.sh` | Remove the launchd service |
| `./morning-claude.sh` | Run manually for testing |

## Project Structure

```
morning-claude/
├── morning-claude.sh           # Main script that opens Claude
├── install.sh                  # Installs launchd service
├── uninstall.sh                # Removes launchd service
├── com.user.morning-claude.plist  # launchd configuration
├── hooks/
│   └── record_first_message.py # Claude Code hook for logging
├── logs/
│   ├── history.log             # Records when Claude opens
│   ├── daily_first_message.log # Records first message each day
│   ├── stdout.log              # launchd standard output
│   └── stderr.log              # launchd error output
└── README.md
```

## Optional: First Message Hook

The `hooks/record_first_message.py` script can be configured as a Claude Code hook to track your daily first message. This helps you see patterns in how you start your day with Claude.

To enable, add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "command": "python3 /path/to/morning-claude/hooks/record_first_message.py"
      }
    ]
  }
}
```

The hook works as follows:
1. When "hi" is sent (from the morning script), it enters "waiting" state
2. The next message you send gets recorded to `logs/daily_first_message.log`
3. Only records once per day

## Logs

View activity logs:

```bash
# When Claude was opened
cat logs/history.log

# Your first messages each day
cat logs/daily_first_message.log

# launchd execution logs
cat logs/stdout.log
cat logs/stderr.log
```

Example `daily_first_message.log`:

```
2024-01-15 07:02:34 | [hi triggered]
2024-01-15 07:02:45 | Let's review the pull requests from yesterday
2024-01-16 07:01:12 | [hi triggered]
2024-01-16 07:01:28 | Help me debug the authentication issue in the login flow
```

## Troubleshooting

### "tmux: command not found" in logs

launchd doesn't inherit your shell's PATH. Use the absolute path to tmux:

```bash
# Find your tmux path
which tmux

# Update morning-claude.sh
TMUX="/opt/homebrew/bin/tmux"
```

### "duplicate session: morning-claude"

A previous tmux session is still running:

```bash
/opt/homebrew/bin/tmux kill-session -t morning-claude
```

### Script doesn't run at scheduled time

1. Verify service is loaded:
   ```bash
   launchctl list | grep morning
   ```

2. Check if Terminal has Accessibility permissions

3. Check error logs:
   ```bash
   cat logs/stderr.log
   ```

4. Reinstall:
   ```bash
   ./uninstall.sh && ./install.sh
   ```

### Claude doesn't respond or loads slowly

Increase wait times in `morning-claude.sh`:

```bash
sleep 6   # Wait for Claude to start (increase to 10 if needed)
sleep 8   # Wait for Claude to load (increase to 12 if needed)
```

### Terminal window doesn't appear

Ensure Terminal has "Accessibility" permissions in System Settings.

## Customization

### Change the greeting message

Edit `morning-claude.sh` line 29:

```bash
$TMUX send-keys -t "$SESSION_NAME" "hi"  # Change to your preferred greeting
```

### Change the schedule

1. Edit `com.user.morning-claude.plist`
2. Reinstall: `./uninstall.sh && ./install.sh`

### Run on weekdays only

Edit `com.user.morning-claude.plist`:

```xml
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Weekday</key>
        <integer>1</integer>  <!-- Monday -->
        <key>Hour</key>
        <integer>7</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <!-- Repeat for Tuesday (2) through Friday (5) -->
</array>
```

## Uninstall

```bash
./uninstall.sh
```

This removes the launchd service. You can delete the project folder afterward if desired.

## License

MIT License - Feel free to modify and share!

## Contributing

Issues and pull requests are welcome. Please feel free to contribute improvements or report bugs.
