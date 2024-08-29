#!/bin/bash

# Arrays to track installed and failed installations
installed=()
failed=()

# Function to check if a command exists and install if it doesn't
check_and_install() {
    local package=$1
    local command=$2
    if ! command -v "$command" &>/dev/null; then
        echo "$package not found. Installing $package..."
        if brew install "$package"; then
            installed+=("$package")
        else
            failed+=("$package")
        fi
    else
        echo "$package is already installed."
        installed+=("$package")
    fi
}

# Step 1: Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        installed+=("Homebrew")
    else
        failed+=("Homebrew")
    fi
else
    echo "Homebrew is already installed."
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    installed+=("Homebrew")
fi

# Step 2: Install necessary tools
echo "Checking for essential tools and installing if necessary..."
check_and_install "Git" "git"
check_and_install "Curl" "curl"
check_and_install "Tmux" "tmux"
check_and_install "Zsh" "zsh"
check_and_install "fzf" "fzf"
check_and_install "zoxide" "zoxide"
check_and_install "Gum" "gum"

# Step 3: Symlink dotfiles to the appropriate locations
echo "Creating symlinks for dotfiles..."

# Bash configuration
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc

# Zsh configuration
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc

# Tmux configuration
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# Tmuxp configuration
mkdir -p ~/.tmuxp
ln -sf ~/dotfiles/tmuxp/* ~/.tmuxp/

# Step 4: Set up fzf
echo "Setting up fzf..."
if [ -d "$HOME/.fzf" ]; then
    echo "fzf is already set up."
else
    echo "Installing fzf..."
    if $(brew --prefix)/opt/fzf/install --all --no-bash --no-zsh --no-fish; then
        installed+=("fzf setup")
    else
        failed+=("fzf setup")
    fi
fi

# Add fzf to shell configuration
echo "source $(brew --prefix)/opt/fzf/shell/completion.zsh" >> ~/.zshrc
echo "source $(brew --prefix)/opt/fzf/shell/key-bindings.zsh" >> ~/.zshrc
echo "source $(brew --prefix)/opt/fzf/shell/completion.bash" >> ~/.bashrc
echo "source $(brew --prefix)/opt/fzf/shell/key-bindings.bash" >> ~/.bashrc

# Step 5: Source the shell configuration to apply changes
echo "Reloading shell configuration..."
source ~/.zshrc  # or ~/.bashrc depending on which shell you use

# Final message: Summary of installations
echo "Setup complete. Here is a summary of the installation process:"

# Print successful installations
if [ ${#installed[@]} -gt 0 ]; then
    echo -e "\nSuccessfully installed:"
    for package in "${installed[@]}"; do
        echo "  - $package"
    done
fi

# Print failed installations
if [ ${#failed[@]} -gt 0 ]; then
    echo -e "\nFailed to install:"
    for package in "${failed[@]}"; do
        echo "  - $package"
    done
else
    echo -e "\nAll installations were successful."
fi
