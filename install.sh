#!/bin/bash
echo "Starting dotenv setup..."

# 1. Generate base directories if they do not exist
mkdir -p ~/.ssh
mkdir -p ~/.gnupg
chmod 700 ~/.ssh

# 2. Import all public GPG keys found in the pubkeys/gpg directory
if [ -d "./pubkeys/gpg" ]; then
    echo "🔑 Importando chaves públicas GPG..."
    for gpg_key in ./pubkeys/gpg/*.asc; do
        [ -e "$gpg_key" ] || continue
        echo " -> Importando: $(basename "$gpg_key")"
        gpg --import "$gpg_key"
    done
else
    echo "⚠️ Pasta pubkeys/gpg não encontrada."
fi

# 3. Add all public SSH keys to the authorized_keys file
if [ -d "./pubkeys/ssh" ]; then
    echo "🔒 Atualizando chaves SSH autorizadas (authorized_keys)..."
    
    # Criar ou limpar arquivo temporário para evitar duplicatas básicas se rodar o script duas vezes
    touch ~/.ssh/authorized_keys
    
    for ssh_key in ./pubkeys/ssh/*.pub; do
        [ -e "$ssh_key" ] || continue
        # Verifica se a chave já existe no arquivo antes de adicionar
        if ! grep -qf "$ssh_key" ~/.ssh/authorized_keys; then
            echo " -> Autorizando SSH: $(basename "$ssh_key")"
            cat "$ssh_key" >> ~/.ssh/authorized_keys
        fi
    done
    chmod 600 ~/.ssh/authorized_keys
else
    echo "⚠️ Pasta pubkeys/ssh não encontrada."
fi

# 4. Host specific configurations

# if [[ "$(hostname)" == "l1l3v1ll" ]]; then
    
# elif [[ "$(hostname)" == "karpi3bb86b" ]]; then
    
# elif [[ "$(hostname)" == "d4nd" ]]; then
   
# fi


# 5. Binding global config files
echo " Binding config files..."
ln -sf ~/dotfiles/config/.bashrc ~/.bashrc

echo "Done!"
