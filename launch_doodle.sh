#!/bin/bash

# Script to launch doodle.html in a separate Chrome instance
# This ensures the doodle page runs independently from your main browser session

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Full path to the doodle.html file
DOODLE_PATH="$SCRIPT_DIR/doodle.html"

# Check if doodle.html exists
if [ ! -f "$DOODLE_PATH" ]; then
    echo "Error: doodle.html not found at $DOODLE_PATH"
    exit 1
fi

# Method 1: Try using open command (macOS standard)
echo "Launching doodle page in Chrome..."
open -a "Google Chrome" --new --args --new-window --app="file://$DOODLE_PATH" --window-size=900,700

# Check if Chrome opened successfully
if [ $? -eq 0 ]; then
    echo "Doodle page launched successfully in Chrome"
else
    echo "Failed to launch Chrome with 'open' command"
    echo "Trying alternative method..."
    
    # Method 2: Direct Chrome launch with separate user data
    TEMP_USER_DATA=$(mktemp -d)
    
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
        --user-data-dir="$TEMP_USER_DATA" \
        --new-window \
        --app="file://$DOODLE_PATH" \
        --window-size=900,700 \
        --window-position=100,100 \
        > /dev/null 2>&1 &
    
    if [ $? -eq 0 ]; then
        echo "Doodle page launched in separate Chrome instance"
        echo "Temporary profile will be cleaned up when Chrome closes"
        
        # Clean up temp directory after Chrome closes
        (
            sleep 2
            CHROME_PID=$(pgrep -f "user-data-dir=$TEMP_USER_DATA")
            
            if [ -n "$CHROME_PID" ]; then
                while kill -0 "$CHROME_PID" 2>/dev/null; do
                    sleep 1
                done
            fi
            
            rm -rf "$TEMP_USER_DATA"
        ) &
    else
        echo "Failed to launch Chrome directly"
        exit 1
    fi
fi