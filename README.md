# osouza.de dotfiles

## Requirements
```
curl git gpg ssh
```

If using a [Alpine Linux](https://it.osouza.de/docs/ops/docker/snippets#alpine)

## Installation
```
git clone https://github.com/osouza-de/dotfiles ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## One-line install
```
curl -fsSL https://raw.githubusercontent.com/osouza-de/dotfiles/refs/heads/master/install.sh | sed 's/\r$//' | sh
```

## Adding GPG and SSH Public Keys

1. GPG
```
gpg -aK
# Get the key ID and then run

gpg --armor --export {GPG_KEY_ID} > pubkeys/gpg/{HOSTNAME}.asc
```

2. SSH
```
cp ~/.ssh/id_ed25519.pub >> pubkeys/ssh/{HOSTNAME}.pub
```