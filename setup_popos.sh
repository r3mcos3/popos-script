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
)


# --- SCRIPT START ---

# Request sudo privileges at the beginning to avoid interruptions.
sudo -v

# 1. Install nala first to use it for updates
echo "--- Installing nala ---"
sudo apt update
sudo apt install -y nala
echo "--- Nala installed ---"
echo ""

# 2. Fetch best mirrors
echo "--- Fetching best mirrors with nala ---"
sudo nala fetch
echo "--- Mirrors fetched ---"
echo ""

# 3. Update system using nala
echo "--- Updating system using nala ---"
sudo nala upgrade -y
echo "--- System updated ---"
echo ""

# 4. Install programs
echo "--- Installing programs via nala ---"
for program in "${PROGRAMS_TO_INSTALL[@]}"; do
    if ! dpkg -l | grep -q "^ii  $program "; then
        echo "Installing $program..."
        sudo nala install -y "$program"
    else
        echo "$program is already installed, skipping."
    fi
done
echo "--- All programs installed ---"
echo ""

# 5. Install Zap (a lightweight Zsh plugin manager)
#    This will install Zap and initialize .zshrc.
if [ ! -d "$HOME/.zap" ]; then
    echo "--- Installing Zap Zsh Plugin Manager ---"
    # Zap's installer creates or modifies ~/.zshrc to initialize itself.
    # We execute this in a Zsh subshell.
    zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
    echo "--- Zap installed ---"
    echo ""
else
    echo "--- Zap is already installed ---"
    echo ""
fi

# 4. Fetch custom .zshrc
echo "--- Fetching custom .zshrc ---"

# Create a backup of the existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

echo "Downloading .zshrc from: $ZSHRC_URL"
wget -O "$HOME/.zshrc" "$ZSHRC_URL"

# NOTE: If you download a custom .zshrc (as above), ensure it
# contains the Zap initialization or correctly sources the Zap configuration,
# otherwise Zap may not function as expected.
# Consult Zap's documentation on how to properly include Zap in your .zshrc.
echo "--- .zshrc successfully placed ---"
echo ""

# 5. Set Zsh as default shell
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "--- Setting Zsh as default shell ---"
    # This command may prompt for your password
    chsh -s "$(which zsh)"
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