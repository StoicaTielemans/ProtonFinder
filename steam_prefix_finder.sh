#!/bin/bash

STEAM_FOLDERS=(
    "$HOME/.local/share/Steam/steamapps"
    "/mnt/1TB_SSD/SteamLibrary/steamapps"
)

echo "Searching for Steam prefixes in the following directories:"
for FOLDER in "${STEAM_FOLDERS[@]}"; do
    echo "$FOLDER"
done

echo ""

PREFIXES=()
for FOLDER in "${STEAM_FOLDERS[@]}"; do
    if [ -d "$FOLDER/compatdata" ]; then
        PREFIXES+=($(find "$FOLDER/compatdata" -type d -name "pfx" 2>/dev/null))
    fi
done

if [ ${#PREFIXES[@]} -eq 0 ]; then
    echo "No Steam prefixes found."
    exit 1
fi

echo "Found Steam prefixes and their corresponding games:"

declare -A PREFIX_MAP
for PREFIX in "${PREFIXES[@]}"; do
    APP_ID=$(basename $(dirname "$PREFIX"))
    if [ -f "$HOME/.local/share/Steam/steamapps/appmanifest_${APP_ID}.acf" ]; then
        GAME_NAME=$(grep -Po '(?<=^\t"name"\t\t").*(?="$)' "$HOME/.local/share/Steam/steamapps/appmanifest_${APP_ID}.acf")
    elif [ -f "/mnt/1TB_SSD/SteamLibrary/steamapps/appmanifest_${APP_ID}.acf" ]; then
        GAME_NAME=$(grep -Po '(?<=^\t"name"\t\t").*(?="$)' "/mnt/1TB_SSD/SteamLibrary/steamapps/appmanifest_${APP_ID}.acf")
    else
        GAME_NAME="Unknown"
    fi
    PREFIX_MAP["$GAME_NAME"]=$PREFIX
    echo "Game: $GAME_NAME, Prefix: $PREFIX"
done

# Prompt user to select a game using fzf
SELECTED_GAME=$(printf "%s\n" "${!PREFIX_MAP[@]}" | fzf --prompt="Select a Game: ")

if [ -z "$SELECTED_GAME" ]; then
    echo "No game selected."
    exit 1
fi

# Get the prefix of the selected game
SELECTED_PREFIX=${PREFIX_MAP["$SELECTED_GAME"]}

if [ ! -d "$SELECTED_PREFIX" ]; then
    echo "Prefix not found."
    exit 1
fi

# Construct the path to the AppData/Local directory
LOCAL_PATH="$SELECTED_PREFIX/drive_c/users/steamuser/AppData/Local/"

if [ ! -d "$LOCAL_PATH" ]; then
    echo "Local directory for game not found at: $LOCAL_PATH"
    exit 1
fi

# Open Nemo at the local path
nemo "$LOCAL_PATH"

echo "Opened Nemo at $LOCAL_PATH"

