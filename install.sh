#!/bin/sh
echo "Starting dotfiles setup..."

# 1. Generate base directories if they do not exist
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.gnupg"
chmod 700 "$HOME/.ssh"

# 2. Import all public GPG keys found in the pubkeys/gpg directory
if [ -d "./pubkeys/gpg" ]; then
    echo "🔑 Importando chaves públicas GPG..."
    # Using ls safely inside a POSIX compliant population check
    for gpg_key in ./pubkeys/gpg/*; do
        case "$gpg_key" in
            *.asc)
                if [ -f "$gpg_key" ]; then
                    echo " -> Importando: $(basename "$gpg_key")"
                    gpg --import "$gpg_key"
                fi
                ;;
        esac
    done
else
    echo "⚠️ Pasta pubkeys/gpg não encontrada."
fi

# 3. Add all public SSH keys to the authorized_keys file
if [ -d "./pubkeys/ssh" ]; then
    echo "Updating authorized_keys..."
    touch "$HOME/.ssh/authorized_keys"
    
    for ssh_key in ./pubkeys/ssh/*; do
        case "$ssh_key" in
            *.pub)
                if [ -f "$ssh_key" ]; then
                    # -F treats key as raw string, -x matches exact whole line
                    if ! grep -qFx -f "$ssh_key" "$HOME/.ssh/authorized_keys"; then
                        echo " -> Autorizando SSH: $(basename "$ssh_key")"
                        cat "$ssh_key" >> "$HOME/.ssh/authorized_keys"
                    fi
                fi
                ;;
        esac
    done
    chmod 600 "$HOME/.ssh/authorized_keys"
else
    echo "⚠️ Pasta pubkeys/ssh não encontrada."
fi

# 4. Host-specific configurations (POSIX shell compatible using 'case')
HOSTNAME=$(hostname)
case "$HOSTNAME" in
    "l1l3v1ll")
        echo " -> Configuring for Laptop..."
        ;;
    "karpi3bb86b")
        echo " -> Configuring for Raspberry Pi..."
        ;;
    "d4nd")
        echo " -> Configuring for WSL/Arch..."
        ;;
    *)
        echo " -> Unknown host: $HOSTNAME (Skipping custom profiles)"
        ;;
esac

# 5. Binding global config files
echo " Binding config files..."
ln -sf "$HOME/dotfiles/config/.bashrc" "$HOME/.bashrc"

echo "Done!"
