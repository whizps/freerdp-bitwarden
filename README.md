# FreeRDP Bitwarden Integration

## Add these to .zshrc and change the path to the scripts to fit your system (Docker) (Windows)
export xrdp_config_file="$HOME/repos/rdp-config.json" \
source "$HOME/repos/rdp-functions.zsh" \
source "$HOME/repos/rdp-completion.zsh"
export PATH="/opt/freerdp-nightly/bin:$PATH"

# Add these to .zshrc and change the path to the scripts to fit your system (Docker) (MacOS)
export xrdp_config_file="$HOME/repos/rdp-config.json"
source "$HOME/repos/rdp-docker-completion.zsh"

## This is the path to your freerdp binary (If running it wihtout docker you might need this)
export PATH="/opt/freerdp-nightly/bin:$PATH"
