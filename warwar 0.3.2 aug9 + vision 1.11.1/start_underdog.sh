#!/bin/bash

# Variables
USB_DEVICE="/dev/sda1"
MOUNT_POINT="/tmp/lv"
APP_PATH="$MOUNT_POINT/app/worker.py"
VENV_PATH="/home/lv/.venv/bin/activate"

# Create a mount point if it doesn't exist
# if [ ! -d "$MOUNT_POINT" ]; then
#     sudo mkdir -p "$MOUNT_POINT"
# fi

# Mount the USB drive
# echo "Mounting USB drive..."
# sudo mount "$USB_DEVICE" "$MOUNT_POINT"
# if [ $? -ne 0 ]; then
#     echo "Failed to mount $USB_DEVICE. Exiting."
#     exit 1
# fi

# echo "USB drive mounted at $MOUNT_POINT."

# Check if the virtual environment exists
if [ ! -f "$VENV_PATH" ]; then
    echo "Virtual environment not found at $VENV_PATH. Exiting."
    # sudo umount "$MOUNT_POINT"
    exit 1
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source "$VENV_PATH"

# Set PYTHONPATH
export HOME="/home/lv"
export PYTHONPATH="$MOUNT_POINT/app:$PYTHONPATH"

# Change to application directory
cd "$MOUNT_POINT/app"

# Start the application
if [ -f "$APP_PATH" ]; then
    echo "Starting application: $APP_PATH"
    python worker.py &
    APP_PID=$!
    echo "Application started with PID: $APP_PID"
else
    echo "Application not found at $APP_PATH. Exiting."
    deactivate
    # sudo umount "$MOUNT_POINT"
    exit 1
fi

# Wait briefly to ensure the application initializes
sleep 10

# Deactivate the virtual environment
deactivate

# Remount USB drive as read-only
# echo "Setting USB drive to read-only mode..."
# sudo mount -o remount,ro "$USB_DEVICE" "$MOUNT_POINT"
# if [ $? -eq 0 ]; then
#     echo "USB drive is now read-only."
# else
#     echo "Failed to set USB drive to read-only."
# fi
