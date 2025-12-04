#!/usr/bin/env zsh

xrdp_config_file="${xrdp_config_file:-${0:A:h}/rdp-config.json}"

_check_bw_session() {
    if [[ -z "$BW_SESSION" ]]; then
        echo "Error: Bitwarden session not found. Please unlock your vault:"
        echo "  export BW_SESSION=\$(bw unlock --raw)"
        return 1
    fi
    
    if ! bw unlock --check &>/dev/null; then
        echo "Error: Bitwarden session expired. Please unlock your vault:"
        echo "  export BW_SESSION=\$(bw unlock --raw)"
        return 1
    fi
    
    return 0
}

_get_bw_credentials() {
    local item_name="$1"
    local field="$2"
    
    if ! _check_bw_session; then
        return 1
    fi
    
    case "$field" in
        username)
            bw get username "$item_name" 2>/dev/null
            ;;
        password)
            bw get password "$item_name" 2>/dev/null
            ;;
        *)
            echo "Error: Invalid field type: $field" >&2
            return 1
            ;;
    esac
}

_rdp_connect() {
    local connection_name="$1"
    
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed. Install it with: brew install jq"
        return 1
    fi
    
    if [[ ! -f "$xrdp_config_file" ]]; then
        echo "Error: Configuration file not found: $xrdp_config_file"
        return 1
    fi
    
    local config=$(cat "$xrdp_config_file" | jq -r ".connections.\"$connection_name\"")
    
    if [[ "$config" == "null" ]]; then
        echo "Error: Connection '$connection_name' not found in configuration"
        echo "Available connections:"
        cat "$xrdp_config_file" | jq -r '.connections | keys[]' | sed 's/^/  - rdp_/'
        return 1
    fi
    
    local hostname=$(echo "$config" | jq -r '.hostname')
    local bw_item=$(echo "$config" | jq -r '.bitwarden_item')
    local description=$(echo "$config" | jq -r '.description // "N/A"')
    
    echo "Connecting to: $description"
    echo "Host: $hostname"
    
    local username=$(_get_bw_credentials "$bw_item" "username")
    if [[ $? -ne 0 || -z "$username" ]]; then
        echo "Error: Failed to retrieve username from Bitwarden for item: $bw_item"
        return 1
    fi
    
    local password=$(_get_bw_credentials "$bw_item" "password")
    if [[ $? -ne 0 || -z "$password" ]]; then
        echo "Error: Failed to retrieve password from Bitwarden for item: $bw_item"
        return 1
    fi
    
    echo "Username: $username"
    echo "Connecting..."
    
    local -a rdp_args
    rdp_args=(
        /v:${hostname}
        /u:${username}
        /p:${password}
        /cert:ignore
        +compression
        +auto-reconnect
        +clipboard
        +dynamic-resolution
    )
    
    /opt/freerdp-nightly/bin/xfreerdp3 "${rdp_args[@]}"
}

_generate_rdp_functions() {
    if [[ ! -f "$xrdp_config_file" ]]; then
        return
    fi
    
    if ! command -v jq &> /dev/null; then
        return
    fi
    
    local connections=($(cat "$xrdp_config_file" | jq -r '.connections | keys[]'))
    
    for func in $(typeset -f | grep '^rdp_' | cut -d' ' -f1); do
        unset -f "$func"
    done
    
    for conn in "${connections[@]}"; do
        eval "rdp_${conn}() { _rdp_connect \"${conn}\" \"\$@\" }"
    done
}

_generate_rdp_functions
