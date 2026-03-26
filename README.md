# CLI Tools Container - GitHub, Jira, Confluence

A Dockerized environment combining three powerful CLI tools for development workflow automation:

- **GitHub CLI (`gh`)** - Official GitHub command-line tool
- **Jira CLI** - Interact with Jira from the terminal
- **Confluence CLI** - Manage Confluence pages and content

## Demo

https://github.com/user-attachments/assets/084b7c8f-2ff6-4743-8cb2-0066fe6c16f6

## Quick Start

### 1. Configure Environment Variables

Copy the example environment file and fill in your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your actual credentials.

### 2. Build and Run

```bash
docker-compose up -d
```

### 3. Initialize CLI Tools

After starting the container, you need to initialize Jira and Confluence CLI tools:

```bash
# Enter the container
docker-compose exec cli /bin/bash

# Inside the container, initialize Jira
jira init

# Initialize Confluence
confluence init

# Exit the container
exit
```

These initialization steps create the necessary configuration files for the CLI tools.

### 4. Execute Commands

```bash
# GitHub CLI
docker-compose exec cli gh repo list

# Jira CLI
docker-compose exec cli jira issue list

# Confluence CLI
docker-compose exec cli confluence spaces
```

Or enter interactive shell:

```bash
docker-compose exec cli /bin/bash
```

## Authentication Setup

### GitHub CLI (`gh`)

Option 1: Personal Access Token (PAT)
```bash
export GH_TOKEN=your_github_token
```

Option 2: Interactive login (inside container)
```bash
gh auth login
```

### Jira CLI

Requires:
- `JIRA_API_URL` - Your Jira instance URL
- `JIRA_AUTH_TYPE` - Authentication type (basic or bearer)
- `JIRA_API_TOKEN` - API token from Atlassian account
- `JIRA_LOGIN` - Your email address

Generate token: https://id.atlassian.com/manage-profile/security/api-tokens

### Confluence CLI

Requires:
- `CONFLUENCE_URL` - Your Confluence instance URL
- `CONFLUENCE_USERNAME` - Your username/email
- `CONFLUENCE_API_TOKEN` - API token (same as Jira)

Uses the same API token as Jira for Atlassian Cloud.

## Skills for AI Agents

This repository includes AI agent skills in the `.copilot/skills/` directory:

- `.copilot/skills/github/SKILL.md` - GitHub CLI operations
- `.copilot/skills/jira/SKILL.md` - Jira issue management
- `.copilot/skills/confluence/SKILL.md` - Confluence content management
- `.copilot/skills/docker-cli-skills/SKILL.md` - Run CLI tools through Docker container

Copy these to your AI agent's skills directory to enable CLI tool usage.

## Usage Examples

### GitHub CLI

```bash
# List repositories
gh repo list myorg --limit 20

# Create issue
gh issue create --title "Bug fix" --body "Description"

# View PR
gh pr view 123

# Clone repository
gh repo clone owner/repo
```

### Jira CLI

```bash
# List issues
jira issue list -a$(jira me)

# Create issue
jira issue create -tBug -s"Critical bug" -b"Description" --no-input

# View issue
jira issue view PROJ-123

# Add comment
jira issue comment add PROJ-123 "Update on progress"
```

### Confluence CLI

```bash
# List spaces
confluence spaces

# Search pages
confluence search "search term"

# Read a page
confluence read <pageId>

# Create page
confluence create "Page Title" SPACEKEY --body "Content here"

# Update page
confluence update <pageId> --body "Updated content"
```

## Development

### Rebuild Container

```bash
docker-compose build --no-cache
```

### Update CLI Tools

Rebuild the container to get latest versions.

## Troubleshooting

### 403 Forbidden Errors (Jira/Confluence)

If you see `403 Forbidden` when running Jira or Confluence commands, your API token needs additional permissions:

**For Jira:**
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Create a new API token (or delete and recreate existing one)
3. Ensure your Atlassian account has access to the Jira project
4. Update `JIRA_API_TOKEN` in `.env` file
5. Restart container: `docker compose restart`

**For Confluence:**
1. Use the same Atlassian API token as Jira (they share permissions)
2. Ensure your account has read/write access to Confluence spaces
3. Update `CONFLUENCE_API_TOKEN` in `.env` file
4. Restart container: `docker compose restart`

**Note:** Authentication with `jira me` working but list operations failing indicates the token is valid but lacks data access permissions. Contact your Atlassian admin if you need elevated permissions.

### Authentication Errors

1. Verify credentials in `.env` file
2. Check token permissions/scopes
3. Ensure URLs don't have trailing slashes
4. For Jira: Confirm `JIRA_API_URL` matches your instance (e.g., `https://yourcompany.atlassian.net`)
5. For Confluence: Confirm `CONFLUENCE_URL` matches your instance

### Command Not Found

Rebuild container:
```bash
docker-compose build
```

### Network Issues

Check Docker network settings and proxy configuration.

## Links

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Jira CLI GitHub](https://github.com/ankitpokhrel/jira-cli)
- [Confluence CLI GitHub](https://github.com/pchuri/confluence-cli)
