#!/bin/bash

# Start Xvfb (virtual X11 display)
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

# Wait for Xvfb to start
sleep 2

# Start fluxbox window manager
fluxbox &

# Start x11vnc for VNC access
x11vnc -display :99 -forever -shared -bg -rfbport 5900 -nopw

echo "VNC server started on port 5900"
echo "Connect from your Mac: open vnc://localhost:5900"
echo ""

# Source the RDP functions
source /app/rdp-functions.zsh

# Execute the command passed to docker run
exec "$@"
