# Morning Claude

Automatically opens Terminal and starts Claude Code every morning at 9:00 AM.

## Installation

```bash
chmod +x install.sh
./install.sh
```

## Uninstallation

```bash
./uninstall.sh
```

## Test

Run manually to test:

```bash
./morning-claude.sh
```

## Configuration

Edit `com.user.morning-claude.plist` to change the time:

```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>9</integer>   <!-- Change hour here (0-23) -->
    <key>Minute</key>
    <integer>0</integer>   <!-- Change minute here (0-59) -->
</dict>
```

After editing, reinstall:

```bash
./uninstall.sh && ./install.sh
```

## Logs

Check logs at `./logs/stdout.log` and `./logs/stderr.log`
