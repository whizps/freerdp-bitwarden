#!/bin/bash

if [ -z "$BW_SESSION" ]; then
    echo "Error: BW_SESSION not set. Please unlock Bitwarden first:"
    echo "  export BW_SESSION=\$(bw unlock --raw)"
    exit 1
fi

CONNECTION_NAME="$1"
CONNECTION_NAME="${CONNECTION_NAME#rdp_}"

if [ -z "$CONNECTION_NAME" ]; then
    echo "Usage: $0 <connection-name>"
    echo ""
    echo "Available connections:"
    if [ -f "$(pwd)/rdp-config.json" ]; then
        cat "$(pwd)/rdp-config.json" | jq -r '.connections | keys[]' | sed 's/^/  /'
    fi
    exit 1
fi

# Get credentials from Bitwarden on the host
CONFIG=$(cat "$(pwd)/rdp-config.json" | jq -r ".connections.\"$CONNECTION_NAME\"")

if [ "$CONFIG" == "null" ]; then
    echo "Error: Connection '$CONNECTION_NAME' not found in configuration"
    exit 1
fi

HOSTNAME=$(echo "$CONFIG" | jq -r '.hostname')
BW_ITEM=$(echo "$CONFIG" | jq -r '.bitwarden_item')
DESCRIPTION=$(echo "$CONFIG" | jq -r '.description // "N/A"')

echo "Fetching credentials from Bitwarden..."
USERNAME=$(bw get username "$BW_ITEM" 2>/dev/null)
PASSWORD=$(bw get password "$BW_ITEM" 2>/dev/null)

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Error: Failed to retrieve credentials from Bitwarden for item: $BW_ITEM"
    exit 1
fi

echo "Connecting to: $DESCRIPTION"
echo "Host: $HOSTNAME"
echo "Username: $USERNAME"
echo ""
echo "Starting RDP connection via Docker..."
echo "Once the container starts, connect with VNC:"
echo "  open vnc://localhost:5900"
echo ""

# Parse domain from username if it contains a slash
DOMAIN=""
USER_ONLY="$USERNAME"
if [[ "$USERNAME" == */* ]]; then
    DOMAIN="${USERNAME%%/*}"
    USER_ONLY="${USERNAME##*/}"
    echo "Domain: $DOMAIN"
fi

# Build xfreerdp command
RDP_CMD="xfreerdp /v:$HOSTNAME /cert-ignore +compression +auto-reconnect +clipboard /dynamic-resolution"

if [ -n "$DOMAIN" ]; then
    RDP_CMD="$RDP_CMD /d:$DOMAIN /u:$USER_ONLY"
else
    RDP_CMD="$RDP_CMD /u:$USERNAME"
fi

RDP_CMD="$RDP_CMD /p:$PASSWORD"

# Run the Docker container with VNC
docker run --rm -it \
    -e DISPLAY=:99 \
    -p 5900:5900 \
    rdp-client \
    bash -c "$RDP_CMD"
