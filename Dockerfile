FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including Node.js
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    gnupg \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    python3 \
    python3-pip \
    jq \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Install Jira CLI
RUN set -e && \
    cd /tmp && \
    JIRA_VERSION=$(curl -s https://api.github.com/repos/ankitpokhrel/jira-cli/releases/latest | jq -r '.tag_name' | sed 's/^v//') && \
    echo "Installing Jira CLI version: ${JIRA_VERSION}" && \
    wget -q https://github.com/ankitpokhrel/jira-cli/releases/download/v${JIRA_VERSION}/jira_${JIRA_VERSION}_linux_x86_64.tar.gz && \
    tar -xzf jira_${JIRA_VERSION}_linux_x86_64.tar.gz && \
    install -m 755 jira_${JIRA_VERSION}_linux_x86_64/bin/jira /usr/local/bin/jira && \
    rm -rf /tmp/jira_${JIRA_VERSION}_linux_x86_64*

# Install Confluence CLI (npm-based)
RUN npm install -g confluence-cli

# Create working directory
WORKDIR /workspace

# Create config directories
RUN mkdir -p /root/.config/jira /root/.config/gh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["/bin/bash"]
