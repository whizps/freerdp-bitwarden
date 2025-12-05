#!/usr/bin/env zsh

# Initialize completion system if not already loaded
if ! type compdef &> /dev/null; then
    autoload -Uz compinit
    compinit -i
fi

: ${xrdp_config_file:="${0:A:h}/rdp-config.json"}

_rdp_completion() {
    local -a connections
    
    if [[ ! -f "$xrdp_config_file" ]]; then
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        return
    fi
    
    connections=($(cat "$xrdp_config_file" | jq -r '.connections | keys[]' | sed 's/^/rdp_/'))
    
    _describe 'rdp connections' connections
}

if type compdef &> /dev/null; then
    compdef _rdp_completion 'rdp_*'
fi

_rdp_pattern_completion() {
    local -a connections
    
    if [[ ! -f "$xrdp_config_file" ]] || ! command -v jq &> /dev/null; then
        return
    fi
    
    connections=($(cat "$xrdp_config_file" | jq -r '.connections | keys[]' | sed 's/^/rdp_/'))
    
    _alternative \
        "connections:rdp connections:($connections)"
}

_rdp_completion_with_descriptions() {
    local -a connections
    local conn_name display_name description
    
    if [[ ! -f "$xrdp_config_file" ]] || ! command -v jq &> /dev/null; then
        return
    fi
    
    while IFS= read -r line; do
        conn_name=$(echo "$line" | jq -r '.name')
        description=$(echo "$line" | jq -r '.description // .hostname')
        connections+=("rdp_${conn_name}:${description}")
    done < <(cat "$xrdp_config_file" | jq -c '.connections | to_entries[] | {name: .key, description: .value.description, hostname: .value.hostname}')
    
    _describe 'rdp connections' connections
}

if type compdef &> /dev/null; then
    compdef _rdp_completion_with_descriptions 'rdp_*'
fi
