#!/bin/bash

set -x -e

# Check for input argument
if [ -z "$1" ]; then
    echo "Usage: $0 <PWM number>"
    exit 1
fi

PWM=$1
STATE_FILE="/tmp/last_pwm_range"

# Determine current range
if [[ "$PWM" -ge 800 && "$PWM" -lt 1200 ]]; then
    CURRENT_RANGE="active"
elif [[ "$PWM" -ge 1200 && "$PWM" -lt 2200 ]]; then
    CURRENT_RANGE="kill"
else
    CURRENT_RANGE="none"
fi

# Read previous range if available
if [[ -f "$STATE_FILE" ]]; then
    LAST_RANGE=$(<"$STATE_FILE")
else
    LAST_RANGE="none"
fi

# Update state only if range changed
if [[ "$CURRENT_RANGE" != "$LAST_RANGE" ]]; then
    echo "$CURRENT_RANGE" > "$STATE_FILE"

    if [[ "$CURRENT_RANGE" == "active" ]]; then
        echo "PWM $PWM in active range (800-1300): Running commands..."
        sudo rm -rf ~/.cache
        gst-launch-1.0 videotestsrc num-buffers=10 ! testsink
        /tmp/lv/start_underdog.sh &
    elif [[ "$CURRENT_RANGE" == "kill" ]]; then
        echo "PWM $PWM in kill range (1300-2100): Killing worker..."
        pkill -9 -f "python.*worker.py" || true
    else
        echo "PWM $PWM is outside expected range."
    fi
else
    echo "PWM range unchanged ($CURRENT_RANGE), no action taken."
fi