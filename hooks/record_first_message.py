#!/usr/bin/env python3
"""
Record the first user message AFTER "hi" is sent.
"hi" triggers the recording, the next message gets recorded.
"""

import json
import sys
from datetime import datetime
from pathlib import Path

LOG_DIR = Path(__file__).parent.parent / "logs"
LOG_FILE = LOG_DIR / "daily_first_message.log"
STATE_FILE = LOG_DIR / ".recording_state"

def get_today():
    return datetime.now().strftime("%Y-%m-%d")

def get_state():
    """Get current state: None, 'waiting', or 'done'"""
    if not STATE_FILE.exists():
        return None, None
    content = STATE_FILE.read_text().strip().split("|")
    if len(content) == 2:
        return content[0], content[1]  # date, state
    return None, None

def set_state(state):
    """Set state for today: 'waiting' or 'done'"""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(f"{get_today()}|{state}")

def record_message(message: str):
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    short_msg = message[:200].replace("\n", " ")
    with open(LOG_FILE, "a") as f:
        f.write(f"{timestamp} | {short_msg}\n")

def main():
    data = sys.stdin.read()

    try:
        input_data = json.loads(data)
        user_message = input_data.get("prompt", "").strip()

        if not user_message:
            print(data)
            return

        date, state = get_state()
        today = get_today()

        # Reset state if it's a new day
        if date != today:
            state = None

        # "hi" triggers waiting state and log the time
        if user_message.lower() == "hi":
            set_state("waiting")
            # Record hi trigger time
            LOG_DIR.mkdir(parents=True, exist_ok=True)
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            with open(LOG_FILE, "a") as f:
                f.write(f"{timestamp} | [hi triggered]\n")
            sys.stderr.write(f"[Hook] Ready to record next message\n")

        # If waiting, record this message
        elif state == "waiting":
            record_message(user_message)
            set_state("done")
            sys.stderr.write(f"[Hook] Recorded: {datetime.now().strftime('%H:%M:%S')}\n")

    except json.JSONDecodeError:
        pass

    print(data)

if __name__ == "__main__":
    main()
