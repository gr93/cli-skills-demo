#!/bin/bash

# Configure SSH for Git if key is mounted
if [ -n "$SSH_KEY_PATH" ] && [ -f "$SSH_KEY_PATH" ]; then
    echo "Configuring SSH for Git..."
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/id_* 2>/dev/null || true
    chmod 644 /root/.ssh/*.pub 2>/dev/null || true
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$SSH_KEY_PATH" 2>/dev/null || true
    
    # Configure git to use SSH
    git config --global core.sshCommand "ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=accept-new"
    
    echo "SSH configured for Git (key: $SSH_KEY_PATH)"
fi

# Configure GitHub CLI if token is provided
if [ -n "$GH_TOKEN" ]; then
    echo "Configuring GitHub CLI..."
    export GH_TOKEN
fi

# Configure Jira CLI if credentials are provided
if [ -n "$JIRA_API_URL" ] && [ -n "$JIRA_API_TOKEN" ]; then
    echo "Configuring Jira CLI..."
    
    # Create Jira CLI config directory (note the dot before "jira")
    mkdir -p /root/.config/.jira
    
    # Initialize Jira with environment variables
    export JIRA_API_TOKEN
    export JIRA_AUTH_TYPE=${JIRA_AUTH_TYPE:-bearer}
    
    # Create config file for Jira CLI with proper auth structure
    cat > /root/.config/.jira/.config.yml <<EOF
server: $JIRA_API_URL
login: $JIRA_LOGIN
installation: cloud
project:
  key: ""
  type: ""
board:
  id: 0
  name: ""
auth:
  type: $JIRA_AUTH_TYPE
  token: $JIRA_API_TOKEN
EOF
    
    chmod 600 /root/.config/.jira/.config.yml
    echo "Jira CLI configured successfully"
fi

# Configure Confluence CLI if credentials are provided
if [ -n "$CONFLUENCE_URL" ] && [ -n "$CONFLUENCE_API_TOKEN" ]; then
    echo "Configuring Confluence CLI..."
    
    # Extract domain from URL (remove protocol and path)
    CONFLUENCE_DOMAIN=$(echo "$CONFLUENCE_URL" | sed -E 's|^https?://||' | sed 's|/.*$||')
    
    # Run confluence init non-interactively
    confluence init \
        --domain "$CONFLUENCE_DOMAIN" \
        --auth-type basic \
        --email "$CONFLUENCE_USERNAME" \
        --token "$CONFLUENCE_API_TOKEN" \
        --protocol https \
        --api-path /wiki/rest/api
    
    echo "Confluence CLI configured successfully"
fi

echo "CLI tools ready!"
echo ""
echo "Available commands:"
echo "  gh --version"
echo "  jira version"
echo "  confluence --help"
echo ""

# Execute the main command
exec "$@"
