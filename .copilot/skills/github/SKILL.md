---
description: >
  **INTEGRATION SKILL** — Execute GitHub CLI commands for repository management, issue tracking, pull requests, releases, and GitHub Actions workflows. USE FOR: creating/managing repos, opening/closing issues/PRs, checking CI status, managing releases, viewing repo information, automating GitHub workflows. DO NOT USE FOR: Git operations that should use git commands directly (commit, push, pull), managing local files (use file operations), or tasks unrelated to GitHub platform features. INVOKES: run_in_terminal for gh commands.
---

# GitHub CLI Skill

This skill enables AI agents to interact with GitHub using the official GitHub CLI (`gh`).

## Prerequisites

- Docker container running with GitHub CLI
- Start container: `docker compose -f c:/Users/Gopal/Documents/skills-demo/docker-compose.yml up -d`
- Authentication configured via `GH_TOKEN` environment variable in .env file
- Execute commands via: `docker compose -f c:/Users/Gopal/Documents/skills-demo/docker-compose.yml exec cli gh <command>`

Reference the docker-cli-skills SKILL.md for tips on using this CLI from an AI agent.

## Common Operations

### Repository Management

**List repositories**
```bash
gh repo list [owner] --limit 20 --visibility public|private|all
```

**Create repository**
```bash
gh repo create [name] --public|--private --description "Description" --clone
```

**View repository**
```bash
gh repo view [owner/repo] --web
```

**Clone repository**
```bash
gh repo clone owner/repo
```

**Delete repository**
```bash
gh repo delete owner/repo --confirm
```

### Issue Management

**List issues**
```bash
gh issue list --repo owner/repo --state open|closed|all --assignee @me
```

**Create issue**
```bash
gh issue create --title "Title" --body "Description" --label bug,enhancement --assignee username
```

**View issue**
```bash
gh issue view 123 --repo owner/repo --comments
```

**Close issue**
```bash
gh issue close 123 --comment "Closing reason"
```

**Reopen issue**
```bash
gh issue reopen 123
```

### Pull Request Management

**List pull requests**
```bash
gh pr list --repo owner/repo --state open|closed|merged --author @me
```

**Create pull request**
```bash
gh pr create --title "Title" --body "Description" --base main --head feature-branch
```

**View pull request**
```bash
gh pr view 123 --comments
```

**Checkout PR locally**
```bash
gh pr checkout 123
```

**Merge pull request**
```bash
gh pr merge 123 --merge|--squash|--rebase --delete-branch
```

**Review pull request**
```bash
gh pr review 123 --approve|--request-changes|--comment --body "Review comments"
```

### GitHub Actions

**List workflows**
```bash
gh workflow list --repo owner/repo
```

**View workflow runs**
```bash
gh run list --workflow=workflow.yml --limit 10
```

**View specific run**
```bash
gh run view 123456789
```

**Watch run (real-time)**
```bash
gh run watch 123456789
```

**Rerun workflow**
```bash
gh run rerun 123456789
```

**Trigger workflow**
```bash
gh workflow run workflow.yml --ref branch-name
```

### Releases

**List releases**
```bash
gh release list --repo owner/repo --limit 10
```

**Create release**
```bash
gh release create v1.0.0 --title "Release v1.0.0" --notes "Release notes" file1.zip file2.tar.gz
```

**View release**
```bash
gh release view v1.0.0
```

**Download release assets**
```bash
gh release download v1.0.0 --pattern "*.zip"
```

### Gists

**Create gist**
```bash
gh gist create file.txt --public|--secret --description "Description"
```

**List gists**
```bash
gh gist list --limit 10
```

**View gist**
```bash
gh gist view gist-id
```

### Search

**Search repositories**
```bash
gh search repos "query" --language python --stars ">1000" --limit 20
```

**Search issues**
```bash
gh search issues "query" --repo owner/repo --state open --label bug
```

**Search PRs**
```bash
gh search prs "query" --repo owner/repo --state open --author username
```

## API Access

**Make custom API requests**
```bash
gh api /repos/owner/repo/issues --method POST --field title="Title" --field body="Description"
```

**Paginated API requests**
```bash
gh api --paginate /repos/owner/repo/issues
```

## Authentication

**Check authentication status**
```bash
gh auth status
```

**Login interactively**
```bash
gh auth login
```

**Login with token**
```bash
export GH_TOKEN=ghp_yourtoken
gh auth status
```

## Output Formats

**JSON output**
```bash
gh repo list --json name,description,url --limit 5
```

**JQ filtering**
```bash
gh repo list --json name,stargazerCount | jq '.[] | select(.stargazerCount > 100)'
```

**Template output**
```bash
gh pr list --json number,title,author --template '{{range .}}{{.number}} - {{.title}} by {{.author.login}}{{"\n"}}{{end}}'
```

## Tips for AI Agents

1. **Always specify repository** with `--repo owner/repo` when not in a git directory
2. **Use JSON output** for parsing: `--json field1,field2`
3. **Check authentication** before operations: `gh auth status`
4. **Handle pagination** for large result sets: use `--limit` or `--paginate`
5. **Dry run when possible** to preview changes before execution
6. **Use `--help`** to discover available options: `gh <command> --help`

## Error Handling

**Common errors:**
- `HTTP 401`: Authentication failed - check `GH_TOKEN`
- `HTTP 403`: Rate limit exceeded or insufficient permissions
- `HTTP 404`: Repository or resource not found
- `not found`: Command might need full `owner/repo` specification

**Debug mode:**
```bash
GH_DEBUG=1 gh <command>
```

## Environment Variables

- `GH_TOKEN`: Personal access token for authentication
- `GH_REPO`: Default repository (owner/repo format)
- `GH_HOST`: GitHub Enterprise Server hostname
- `GH_EDITOR`: Editor for interactive commands

## Integration Example

When user asks: "Show me the open issues assigned to me in the main repo"

Execute:
```bash
gh issue list --repo owner/repo --assignee @me --state open --json number,title,labels
```

Parse JSON output and present formatted results to user.

## Documentation

Full documentation: https://cli.github.com/manual/
