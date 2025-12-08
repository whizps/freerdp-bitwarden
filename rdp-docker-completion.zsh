#!/usr/bin/env zsh

# Initialize completion system if not already loaded
if ! type compdef &> /dev/null; then
    autoload -Uz compinit
    compinit -i
fi

: ${xrdp_config_file:="${0:A:h}/rdp-config.json"}

_rdp_docker_completion() {
    local -a connections
    
    # Only complete the first argument
    if [[ $CURRENT -gt 2 ]]; then
        return 0
    fi
    
    if [[ ! -f "$xrdp_config_file" ]]; then
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        return
    fi
    
    # Get connection names without rdp_ prefix for docker script
    connections=($(cat "$xrdp_config_file" | jq -r '.connections | keys[]'))
    
    _arguments '1:connection:($connections)'
}

# Get the script directory
local script_dir="${0:A:h}"

# Create a wrapper function for completion to work properly
rdp-docker() {
    "${script_dir}/rdp-docker.sh" "$@"
}

# Completion for the function
compdef _rdp_docker_completion rdp-docker

# Also create convenience aliases that work with completion
if [[ -f "$xrdp_config_file" ]] && command -v jq &> /dev/null; then
    local connections=($(cat "$xrdp_config_file" | jq -r '.connections | keys[]'))
    
    for conn in "${connections[@]}"; do
        alias "rdp_${conn}"="${script_dir}/rdp-docker.sh ${conn}"
    done
fi
