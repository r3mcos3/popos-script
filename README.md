# Pop!_OS Setup Script

This script automates the setup and configuration of a new Pop!_OS installation. It installs essential programs, sets up the Zsh shell with the Zap plugin manager, and fetches a custom `.zshrc` configuration.

## Features

- **System Update:** Fully updates and upgrades your system using `apt`.
- **Package Installation:** Installs a predefined list of essential command-line tools:
  - `zsh`: A powerful and modern shell.
  - `nala`: A prettier and faster front-end for `apt`.
  - `gh`: The official GitHub CLI.
- **Zsh & Zap:**
  - Installs `zsh` and sets it as the default shell.
  - Installs [Zap](https://www.zapzsh.org/), a minimal and fast Zsh plugin manager.
- **Custom Configuration:** Downloads a `.zshrc` file from a specified URL to quickly set up your shell environment. It automatically backs up any existing `.zshrc` file.

## How to Use

1.  **Alternatively, Run Directly from GitHub:**

    You can execute this script directly from GitHub without cloning the repository first. This is useful for new Pop!_OS installations.

    ```bash
    bash <(curl -s https://raw.githubusercontent.com/r3mcos3/popos-script/main/setup_popos.sh)
    ```

    The script will ask for your `sudo` password at the beginning and then run non-interactively.

2.  **Customize the Script (Optional):**

    Open `setup_popos.sh` and modify the following variables to fit your needs:
    - `ZSHRC_URL`: Change the URL to point to your own raw `.zshrc` file.
    - `PROGRAMS_TO_INSTALL`: Add or remove programs from the list.

3.  **Make the Script Executable (if running locally):**

    If you cloned the repository and want to run the script locally, make it executable:

    ```bash
    chmod +x setup_popos.sh
    ```

4.  **Run the Script (if running locally):**

    ```bash
    ./setup_popos.sh
    ```

    The script will ask for your `sudo` password at the beginning and then run non-interactively.

5.  **Log Out and Log Back In:**

    For the default shell change to take effect, you must log out of your session and log back in.

## Disclaimer

This script runs commands with `sudo` and modifies your system configuration (e.g., your default shell and `.zshrc`). Please review the script's contents carefully to ensure you understand what it does before executing it.
