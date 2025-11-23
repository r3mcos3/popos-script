#!/bin/bash

# =================================================================================
# Pop!_OS New Installation Script
#
# This script installs and configures commonly used programs and
# fetches a .zshrc configuration from a Git repository.
#
# IMPORTANT: Execute this script with caution. Read its content
# and customize it to your needs before running.
# =================================================================================

# Stop the script immediately if any command fails
set -e

# --- CONFIGURATION ---
# Adjust these variables to your preferences.

# 1. URL to your raw .zshrc file (e.g., from GitHub Gist or a public repo)
# Example: ZSHRC_URL="https://raw.githubusercontent.com/yourusername/dotfiles/main/.zshrc"
ZSHRC_URL="https://raw.githubusercontent.com/r3mcos3/dotfiles/master/zsh-popos/.zshrc" # Customize this!

# 2. List of programs you want to install via apt.
#    Add or remove programs from this list.
PROGRAMS_TO_INSTALL=(
    "zsh"
    "gh"
    "curl"
    "unzip"
)

# --- DRY RUN LOGIC ---
DRY_RUN=false

_HELP_MESSAGE() {
    echo "Usage: $0 [-d|--dry-run] [-h|--help]"
    echo ""
    echo "  -d, --dry-run   Simulate script execution without making actual changes."
    echo "  -h, --help      Display this help message."
    echo ""
    echo "This script installs and configures commonly used programs on Pop!_OS."
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            echo "--- DRY RUN MODE ENABLED ---"
            shift
            ;;
        -h|--help)
            _HELP_MESSAGE
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            _HELP_MESSAGE
            exit 1
            ;;
    esac
done

# Helper function to run commands or just echo them in dry-run mode
run_command() {
    if "$DRY_RUN"; then
        echo "DRY RUN: $*"
    else
        "$@"
    fi
}

# --- SCRIPT START ---

# Request sudo privileges at the beginning to avoid interruptions.
# This command is run regardless of DRY_RUN as it just asks for credentials.
if ! "$DRY_RUN"; then
    sudo -v
fi

# 1. Install nala first to use it for updates
echo "--- Installing nala ---"
run_command sudo apt update
if ! dpkg -l | grep -q "^ii  nala "; then
    run_command sudo apt install -y nala
else
    echo "nala is already installed, skipping."
fi
echo "--- Nala installed ---"
echo ""

# 2. Fetch best mirrors
echo "--- Fetching best mirrors with nala ---"
run_command sudo nala fetch
echo "--- Mirrors fetched ---"
echo ""

# 3. Update system using nala
echo "--- Updating system using nala ---"
run_command sudo nala upgrade -y
echo "--- System updated ---"
echo ""


# 4. Ask for additional programs to install
echo "--- Checking for additional programs ---"
echo "The following programs are currently set to be installed:"
printf "  - %s\n" "${PROGRAMS_TO_INSTALL[@]}"
echo ""
read -r -p "Do you want to add more programs to install? (comma-separated, or press Enter to skip): " additional_programs

if [ -n "$additional_programs" ]; then
    # Replace commas with spaces for read -a
    additional_programs_spaced=${additional_programs//,/ }
    
    # Read the space-separated string into an array
    read -ra additional_programs_array <<< "$additional_programs_spaced"
    
    # Add the new programs to the main array
    PROGRAMS_TO_INSTALL+=("${additional_programs_array[@]}")
    
    echo "--- Updated list of programs to install: ---"
    printf "  - %s\n" "${PROGRAMS_TO_INSTALL[@]}"
fi
echo ""


# 5. Install programs
echo "--- Installing programs via nala ---"
for program in "${PROGRAMS_TO_INSTALL[@]}"; do
    if ! dpkg -l | grep -q "^ii  $program "; then
        echo "Installing $program..."
        run_command sudo nala install -y "$program"
    else
        echo "$program is already installed, skipping."
    fi
done
echo "--- All programs installed ---"
echo ""

# 6. Install a Nerd Font (Fira Code) for icons
echo "--- Installing Fira Code Nerd Font ---"
FONT_NAME="FiraCode"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
FONT_DIR="$HOME/.local/share/fonts"

# Check if font is already installed
if fc-list | grep -q "$FONT_NAME Nerd Font"; then
    echo "Fira Code Nerd Font is already installed, skipping."
else
    echo "Downloading and installing Fira Code Nerd Font..."
    run_command mkdir -p "$FONT_DIR"

    # Download the font zip file
    run_command wget -q --show-progress -O "/tmp/${FONT_NAME}.zip" "$FONT_URL"

    # Unzip the font
    run_command unzip -o "/tmp/${FONT_NAME}.zip" -d "$FONT_DIR"

    # Clean up the zip file
    run_command rm "/tmp/${FONT_NAME}.zip"

    # Update the font cache
    echo "Updating font cache..."
    run_command fc-cache -f -v

    echo "Fira Code Nerd Font installed successfully."
fi
echo ""


# 7. Install Zap (a lightweight Zsh plugin manager)
#    This will install Zap and initialize .zshrc.
if [ ! -d "$HOME/.zap" ]; then
    echo "--- Installing Zap Zsh Plugin Manager ---"
    # Zap's installer creates or modifies ~/.zshrc to initialize itself.
    # We execute this in a Zsh subshell.
    run_command zsh -c "$(curl -fsSL https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1"
    echo "--- Zap installed ---"
    echo ""
else
    echo "--- Zap is already installed ---"
    echo ""
fi

# 8. Fetch custom .zshrc
echo "--- Fetching custom .zshrc ---"

# Create a backup of the existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak"
    run_command mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

echo "Downloading .zshrc from: $ZSHRC_URL"
run_command wget -O "$HOME/.zshrc" "$ZSHRC_URL"

# NOTE: If you download a custom .zshrc (as above), ensure it
# contains the Zap initialization or correctly sources the Zap configuration,
# otherwise Zap may not function as expected.
# Consult Zap's documentation on how to properly include Zap in your .zshrc.
echo "--- .zshrc successfully placed ---"
echo ""

# 9. Set Zsh as default shell
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "--- Setting Zsh as default shell ---"
    # This command may prompt for your password
    run_command chsh -s "$(which zsh)"
    echo "--- Zsh is now the default shell. ---"
    echo "NOTE: You must log out and log back in for this to take effect."
    echo ""
else
    echo "--- Zsh is already the default shell. ---"
    echo ""
fi


echo "============================================================"
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Customize the list of programs in this script for future use."
echo "2. Adjust the ZSHRC_URL to the location of your own .zshrc file."
echo "   Ensure your .zshrc contains the correct Zap initialization and configuration."
echo "3. Restart your terminal or log back in to start using Zsh."
echo "============================================================"
