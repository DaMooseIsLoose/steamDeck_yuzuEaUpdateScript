#!/bin/bash

# GitHub API URL for the latest release
API_URL="https://api.github.com/repos/pineappleEA/pineapple-src/releases/latest"

# Directory where the AppImage will be stored
TARGET_DIR="/home/deck/Applications"
TARGET_FILE="yuzu.AppImage"

# Send GET request to the GitHub API and parse the result
download_url=$(curl -s $API_URL | jq -r '.assets[] | select(.name | endswith(".AppImage")).browser_download_url')

# Check if a suitable file was found
if [ -z "$download_url" ]; then
    echo "No .AppImage file found in the latest release."
    exit 1
fi

# Download the AppImage file, rename it, and move it to the target directory
curl -L -o "$TARGET_DIR/$TARGET_FILE" "$download_url"

echo "Download finished. The file has been saved as $TARGET_DIR/$TARGET_FILE."
