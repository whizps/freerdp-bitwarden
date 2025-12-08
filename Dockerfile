FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    ca-certificates \
    gnupg \
    jq \
    curl \
    zsh \
    xvfb \
    x11vnc \
    fluxbox \
    freerdp2-x11 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Set up entrypoint
COPY docker-entrypoint.sh /app/
RUN chmod +x /app/docker-entrypoint.sh

ENTRYPOINT ["/app/docker-entrypoint.sh"]
