# ProtonFinder

ProtonFinder is a simple Bash script that scans your Steam library folders for Proton prefixes, maps them to their corresponding game names, and lets you open the selected game’s folder in your default Linux file manager. It's perfect for locating save files or modding your games.

---

![](https://github.com/StoicaTielemans/ProtonFinder/blob/main/protonfinder.gif)

---

## Features
- Scans multiple Steam library folders for Proton prefixes.
- Maps prefixes to game names for easy identification.
- Interactive game selection using `fzf`.
- Opens the selected game folder in your Linux file manager.

---

## How to Set Up

### Create the Bash Script
1. Clone this repository or manually create the script:
    ```bash
    nano protonfinder.sh
    ```

2. Copy the script content into the file and save it.
3. Make the script executable:
    ```bash
    chmod +x protonfinder.sh
    ```

---

## How to Use

1. Run the script:
    ```bash
    ./protonfinder.sh
    ```

2. Use the interactive menu (fzf) to select a game.
3. The script will open the selected game’s folder in your file manager.

---

## Customization

### Add Custom Steam Library Paths

To include additional Steam library folders:

1. Open the script in your editor:
    ```bash
    nano protonfinder.sh
    ```

2. Add your custom path(s) to the `STEAM_FOLDERS` array:
    ```bash
    STEAM_FOLDERS=(
        "$HOME/.local/share/Steam/steamapps"
        "/mnt/1TB_SSD/SteamLibrary/steamapps"
        "/your/custom/path/steamapps"
    )
    ```

3. Save and exit.

### Change the Default File Manager

To use a different file manager:

1. Replace `nemo` at the end of the script with your preferred file manager (e.g., `nautilus`, `dolphin`):
    ```bash
    # Example: Using Nautilus instead of Nemo
    nautilus "$LOCAL_PATH"
    ```

---

## Requirements

- `fzf`: Install it via your package manager (e.g., `sudo apt install fzf`).
- A Linux file manager (e.g., Nemo, Nautilus, Dolphin).
