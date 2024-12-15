#!/bin/bash
STEAM_FOLDERS=(
    "$HOME/.local/share/Steam/steamapps"
    "/mnt/1TB_SSD/SteamLibrary/steamapps"
)
BOTTLES_FOLDERS=(
    "$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles"
)

PRINT_TEXT=false

# Check for --text argument
if [[ "$1" == "--text" ]]; then
    PRINT_TEXT=true
fi

if $PRINT_TEXT; then
    echo "Searching for prefixes in the following directories:"
    echo "Steam Directories:"
    for FOLDER in "${STEAM_FOLDERS[@]}"; do
        echo "  $FOLDER"
    done
    echo "Bottles Directories:"
    for FOLDER in "${BOTTLES_FOLDERS[@]}"; do
        echo "  $FOLDER"
    done
    echo ""

    # Search Steam prefixes
    echo "Steam Prefixes:"
    for FOLDER in "${STEAM_FOLDERS[@]}"; do
        if [ -d "$FOLDER/compatdata" ]; then
            FOUND_PREFIXES=($(find "$FOLDER/compatdata" -type d -name "pfx" 2>/dev/null))
            for PREFIX in "${FOUND_PREFIXES[@]}"; do
                APP_ID=$(basename $(dirname "$PREFIX"))
                if [ -f "$HOME/.local/share/Steam/steamapps/appmanifest_${APP_ID}.acf" ]; then
                    GAME_NAME=$(grep -Po '(?<=^\t"name"\t\t").*(?="$)' "$HOME/.local/share/Steam/steamapps/appmanifest_${APP_ID}.acf")
                elif [ -f "/mnt/1TB_SSD/SteamLibrary/steamapps/appmanifest_${APP_ID}.acf" ]; then
                    GAME_NAME=$(grep -Po '(?<=^\t"name"\t\t").*(?="$)' "/mnt/1TB_SSD/SteamLibrary/steamapps/appmanifest_${APP_ID}.acf")
                else
                    GAME_NAME="Unknown Steam Game"
                fi
                echo "  Game: $GAME_NAME, Prefix: $PREFIX"
            done
        fi
    done

    # Search Bottles prefixes
    echo -e "\nBottles Prefixes:"
    for FOLDER in "${BOTTLES_FOLDERS[@]}"; do
        if [ -d "$FOLDER" ]; then
            # Use the directory names as Bottle names
            FOUND_BOTTLES=($(ls "$FOLDER"))
            for BOTTLE in "${FOUND_BOTTLES[@]}"; do
                BOTTLE_PATH="$FOLDER/$BOTTLE"
                if [ -d "$BOTTLE_PATH" ]; then
                    echo "  Bottle: $BOTTLE, Path: $BOTTLE_PATH"
                fi
            done
        fi
    done
    exit 0
fi

STEAM_PREFIXES=()
BOTTLES_PREFIXES=()

# Search Steam prefixes
for FOLDER in "${STEAM_FOLDERS[@]}"; do
    if [ -d "$FOLDER/compatdata" ]; then
        FOUND_PREFIXES=($(find "$FOLDER/compatdata" -type d -name "pfx" 2>/dev/null))
        STEAM_PREFIXES+=("${FOUND_PREFIXES[@]}")
    fi
done

# Search Bottles prefixes
for FOLDER in "${BOTTLES_FOLDERS[@]}"; do
    if [ -d "$FOLDER" ]; then
        # Use the directory names as Bottle names
        FOUND_BOTTLES=($(ls "$FOLDER"))
        for BOTTLE in "${FOUND_BOTTLES[@]}"; do
            BOTTLE_PATH="$FOLDER/$BOTTLE"
            if [ -d "$BOTTLE_PATH" ]; then
                BOTTLES_PREFIXES+=("$BOTTLE_PATH")
            fi
        done
    fi
done

# Check if any prefixes were found
if [ ${#STEAM_PREFIXES[@]} -eq 0 ] && [ ${#BOTTLES_PREFIXES[@]} -eq 0 ]; then
    exit 1
fi

# Prepare maps for selection
declare -A PREFIX_MAP
for PREFIX in "${STEAM_PREFIXES[@]}"; do
    APP_ID=$(basename $(dirname "$PREFIX"))
    if [ -f "$HOME/.local/share/Steam/steamapps/appmanifest_${APP_ID}.acf" ]; then
        GAME_NAME=$(grep -Po '(?<=^\t"name"\t\t").*(?="$)' "$HOME/.local/share/Steam/steamapps/appmanifest_${APP_ID}.acf")
    elif [ -f "/mnt/1TB_SSD/SteamLibrary/steamapps/appmanifest_${APP_ID}.acf" ]; then
        GAME_NAME=$(grep -Po '(?<=^\t"name"\t\t").*(?="$)' "/mnt/1TB_SSD/SteamLibrary/steamapps/appmanifest_${APP_ID}.acf")
    else
        GAME_NAME="Unknown Steam Game"
    fi
    PREFIX_MAP["$GAME_NAME"]=$PREFIX
done

for BOTTLE_PATH in "${BOTTLES_PREFIXES[@]}"; do
    BOTTLE_NAME=$(basename "$BOTTLE_PATH")
    PREFIX_MAP["Bottle: $BOTTLE_NAME"]=$BOTTLE_PATH
done

# Combine keys from both maps for selection
COMBINED_KEYS=()
for key in "${!PREFIX_MAP[@]}"; do
    COMBINED_KEYS+=("$key")
done

# Prompt user to select a game/application using fzf
SELECTED_ITEM=$(printf "%s\n" "${COMBINED_KEYS[@]}" | fzf --prompt="Select a Game/Application: ")

if [ -z "$SELECTED_ITEM" ]; then
    echo "No item selected."
    exit 1
fi

# Determine if it's a prefix and get the corresponding path
if [[ "${PREFIX_MAP[$SELECTED_ITEM]+_}" ]]; then
    SELECTED_PATH=${PREFIX_MAP["$SELECTED_ITEM"]}
    
    # For Steam prefixes
    if [[ "$SELECTED_PATH" == */compatdata/*/pfx ]]; then
        LOCAL_PATH="$SELECTED_PATH/drive_c/users/steamuser/AppData/Local/"
        if [ ! -d "$LOCAL_PATH" ]; then
            echo "Local directory for game/application not found at: $LOCAL_PATH"
            exit 1
        fi
        nohup nemo "$LOCAL_PATH" >/dev/null 2>&1 &
        echo "Opened Nemo at $LOCAL_PATH"
    
    # For Bottles
    else
        LOCAL_PATH="$SELECTED_PATH/drive_c"
        if [ ! -d "$LOCAL_PATH" ]; then
            echo "drive_c directory not found at: $LOCAL_PATH"
            exit 1
        fi
        nohup nemo "$LOCAL_PATH" >/dev/null 2>&1 &
        echo "Opened Nemo at Bottles Path: $LOCAL_PATH"
    fi
else
    echo "Selected item not found in prefix maps."
    exit 1
fi

exit 0
