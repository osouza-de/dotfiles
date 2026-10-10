#!/bin/sh
echo "Starting dotfiles setup..."

# Your Git repository URL
REPO_URL="https://github.com"
DOTFILES_DIR="$HOME/dotfiles"

# 1. Detect execution via curl (pipe) vs local git repo clone
if [ ! -d "./pubkeys" ] || [ ! -d ".git" ]; then
    echo "🌐 Execution via curl detected. Preparing local environment..."

    # Check if git is installed, suggest command if missing
    if ! command -v git >/dev/null 2>&1; then
        echo "❌ Error: git is not installed on this system."
        echo "Please install git using your package manager and rerun the script:"
        
        # Check system binaries to suggest the perfect command
        if command -v pkg >/dev/null 2>&1; then
            echo "   👉 Run: pkg update && pkg install git -y"
        elif command -v apt-get >/dev/null 2>&1; then
            echo "   👉 Run: sudo apt-get update && sudo apt-get install git -y"
        elif command -v pacman >/dev/null 2>&1; then
            echo "   👉 Run: sudo pacman -Syu git"
        else
            echo "   👉 Run your system's equivalent of: install git"
        fi
        exit 1
    fi

    # Clone the repository if the target directory doesn't exist
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo "📥 Cloning dotfiles repository..."
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        echo "🔄 Dotfiles folder already exists. Pulling latest updates..."
        cd "$DOTFILES_DIR" && git pull
    fi

    # Change to the cloned directory context to read keys locally
    cd "$DOTFILES_DIR" || exit 1
else
    echo "📂 Local repository execution detected."
fi

# 2. Generate secure base directories
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.ssh"

# 3. Import all public GPG keys found in pubkeys/gpg/
if [ -d "./pubkeys/gpg" ]; then
    echo "🔑 Importing GPG public keys..."
    for gpg_key in ./pubkeys/gpg/*; do
        case "$gpg_key" in
            *.asc)
                if [ -f "$gpg_key" ]; then
                    echo " -> Importing: $(basename "$gpg_key")"
                    gpg --import "$gpg_key"
                fi
                ;;
        esac
    done
else
    echo "⚠️ Folder pubkeys/gpg not found."
fi

# 4. Add all public SSH keys to authorized_keys
if [ -d "./pubkeys/ssh" ]; then
    echo "🔒 Updating authorized_keys..."
    touch "$HOME/.ssh/authorized_keys"
    
    for ssh_key in ./pubkeys/ssh/*; do
        case "$ssh_key" in
            *.pub)
                if [ -f "$ssh_key" ]; then
                    if ! grep -qFx -f "$ssh_key" "$HOME/.ssh/authorized_keys"; then
                        echo " -> Authorizing SSH key: $(basename "$ssh_key")"
                        cat "$ssh_key" >> "$HOME/.ssh/authorized_keys"
                    fi
                fi
                ;;
        esac
    done
    chmod 600 "$HOME/.ssh/authorized_keys"
else
    echo "⚠️ Folder pubkeys/ssh not found."
fi

# 5. Host-specific configuration selector
HOSTNAME=$(hostname)
case "$HOSTNAME" in
    "l1l3v1ll")
        echo " -> Configuring for Laptop..."
        ;;
    "karpi3bb86b")
        echo " -> Configuring for Kali Raspberry Pi..."
        ;;
    "d4nd")
        echo " -> Configuring for WSL Arch..."
        ;;
    *)
        echo " -> Host profile ($HOSTNAME) not defined. Skipping specific tweaks."
        ;;
esac

# 6. Bind global shell configuration profiles
echo "🔗 Binding config files..."
ln -sf "$DOTFILES_DIR/config/.bashrc" "$HOME/.bashrc"

echo "Done!"
