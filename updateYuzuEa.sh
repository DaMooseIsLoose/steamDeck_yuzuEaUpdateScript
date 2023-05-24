#!/bin/bash

# Check Wi-fi connection
wifi_status=$(iwconfig | grep -q "ESSID:off/any" && echo "false" || echo "true")
if [ -z "$wifi_status" ]; then
    zenity --eror --text="No Wi-Fi connection detected. Please check that you're connected to Wi-Fi before running this script."
    exit 1
fi

# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/pineappleEA/pineapple-src/releases/latest"

# Directory where the AppImage will be stored
TARGET_DIR="/home/deck/Applications"
TARGET_FILE="yuzu.AppImage"

# Send GET request to the GitHub API and parse the result
download_url=$(curl -s $API_URL | jq -r '.assets[] | select(.name | endswith(".AppImage")).browser_download_url')
release_tag=$(curl -s $API_URL | jq -r '.tag_name')

# Check if a suitable file was found	
if [ -z "$download_url" ]; then
    zenity --error --text="No .AppImage file found in the latest release."
    exit 1
fi

# Download the AppImage file, rename it, and move it to the target directory in the background
curl -L -o "$TARGET_DIR/$TARGET_FILE" "$download_url" &

# Get PID of the curl process
CURL_PID=$!

# Show a progress dialog until curl completes
zenity --progress --pulsate --no-cancel --auto-close --title="Updating" --text="Downloading Yuzu $release_tag..." < <(
    while kill -0 $CURL_PID 2> /dev/null; do
        sleep 1
    done
)

# Wait for the curl process to finish and then check if the file is indeed downloaded
wait $CURL_PID
while [ ! -f "$TARGET_DIR/$TARGET_FILE" ]; do sleep 1; done

zenity --info --text="Yuzu $release_tag is now installed."
