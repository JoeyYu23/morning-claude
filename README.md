# Morning Claude

Automatically opens Terminal and starts Claude Code at a scheduled time every day.

## Quick Start

### 1. Install tmux

```bash
brew install tmux
```

### 2. Clone the project

```bash
git clone https://github.com/JoeyYu23/morning-claude.git
cd morning-claude
```

### 3. Configure tmux path (Important!)

Find your tmux path:

```bash
which tmux
```

Edit `morning-claude.sh` and update the TMUX path if different:

```bash
TMUX="/opt/homebrew/bin/tmux"  # Update this if your path is different
```

> **Note**: Intel Macs typically use `/usr/local/bin/tmux`

### 4. Set your preferred time

Edit `com.user.morning-claude.plist`:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>9</integer>    <!-- 0-23 -->
    <key>Minute</key>
    <integer>0</integer>    <!-- 0-59 -->
</dict>
```

### 5. Install the service

```bash
chmod +x *.sh
./install.sh
```

### 6. Grant permissions

Go to **System Settings → Privacy & Security → Accessibility** and enable **Terminal**.

### 7. Verify

```bash
# Check service is loaded
launchctl list | grep morning

# Manual test
./morning-claude.sh
```

## Usage

| Command | Description |
|---------|-------------|
| `./install.sh` | Install the scheduled service |
| `./uninstall.sh` | Remove the scheduled service |
| `./morning-claude.sh` | Run manually to test |

## How It Works

```
┌────────────────────────────────────────────────┐
│  macOS launchd (runs in background)            │
│  Triggers at scheduled time                    │
└────────────────────────────────────────────────┘
                      ↓
┌────────────────────────────────────────────────┐
│  morning-claude.sh                             │
│  1. Opens Terminal with tmux session           │
│  2. Starts Claude Code                         │
│  3. Sends Enter to confirm trust               │
│  4. Sends "hi" + Enter                         │
└────────────────────────────────────────────────┘
```

## Troubleshooting

### "tmux: command not found" in logs

launchd doesn't have the same PATH as your terminal. Use the full path to tmux:

```bash
# Find your tmux path
which tmux

# Update morning-claude.sh with the full path
TMUX="/opt/homebrew/bin/tmux"
```

### "duplicate session: morning-claude"

A previous tmux session is still running:

```bash
/opt/homebrew/bin/tmux kill-session -t morning-claude
```

### Script doesn't run at scheduled time

1. Check if service is loaded:
   ```bash
   launchctl list | grep morning
   ```

2. Check logs:
   ```bash
   cat logs/stdout.log
   cat logs/stderr.log
   ```

3. Reinstall:
   ```bash
   ./uninstall.sh && ./install.sh
   ```

### Claude doesn't auto-confirm or respond

Increase the wait times in `morning-claude.sh`:

```bash
sleep 6   # Wait for Claude to start (increase if needed)
sleep 8   # Wait for Claude to load (increase if needed)
```

## Customization

### Change the message

Edit `morning-claude.sh` line 24:

```bash
$TMUX send-keys -t "$SESSION_NAME" "hi"  # Change "hi" to your message
```

### Change the schedule

Edit `com.user.morning-claude.plist`, then reinstall:

```bash
./uninstall.sh && ./install.sh
```

## Logs

```bash
cat logs/stdout.log   # Standard output
cat logs/stderr.log   # Errors
```

## Uninstall

```bash
./uninstall.sh
```

## Requirements

- macOS
- [Homebrew](https://brew.sh)
- tmux (`brew install tmux`)
- [Claude Code](https://claude.ai/download) CLI installed
