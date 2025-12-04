## Add these to .zshrc and change the path to the scripts to fit your system

# FreeRDP Bitwarden Integration
export xrdp_config_file="$HOME/repos/github/freerdp-bitwarden/rdp-config.json"
source "$HOME/freerdp-bitwarden/rdp-functions.zsh"
source "$HOME/freerdp-bitwarden/rdp-completion.zsh"

## This is the path to your freerdp binary
export PATH="/opt/freerdp-nightly/bin:$PATH"
