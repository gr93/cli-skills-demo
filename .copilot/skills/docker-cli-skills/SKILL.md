---
name: docker-cli-skills
description: Use when running CLI tools like jira, confluence, or other command-line utilities. Executes all CLI commands through the Docker container 'dev-cli-tools' instead of running them directly on the host system.
---

# Docker CLI Skills

## When to Use

**ALWAYS use this approach when:**
- Running `jira` commands
- Running `confluence` commands
- Running `gh` commands
- Running any CLI tool that should execute in a containerized environment
- The user has a `dev-cli-tools` container running

**Do NOT use when:**
- Running Docker commands themselves (`docker ps`, `docker exec`, etc.)
- Running system commands that need host access
- The container is not available (fall back to direct execution)

---

## Container Check

**Before using any CLI command, verify the container is running:**

```powershell
docker ps --filter "name=dev-cli-tools" --filter "status=running"
```

**If container is not running:**
1. Check if it exists but is stopped: `docker ps -a --filter "name=dev-cli-tools"`
2. Start it if stopped: `docker start dev-cli-tools`
3. If it doesn't exist, inform the user and suggest creating it

---

## Command Execution Pattern

**Base pattern for all CLI commands:**

```powershell
docker exec dev-cli-tools <command> <arguments>
```

**Interactive commands (if needed):**

```powershell
docker exec -it dev-cli-tools <command> <arguments>
```

---

## Jira Commands via Container

Instead of running `jira` directly, wrap it with `docker exec`:

| Direct Command | Container Command |
|----------------|-------------------|
| `jira issue view PROJ-123` | `docker exec dev-cli-tools jira issue view PROJ-123` |
| `jira issue list -a$(jira me)` | `docker exec dev-cli-tools jira issue list -a$(docker exec dev-cli-tools jira me)` |
| `jira issue create -tTask -s"Summary"` | `docker exec dev-cli-tools jira issue create -tTask -s"Summary"` |
| `jira sprint list --state active` | `docker exec dev-cli-tools jira sprint list --state active` |
| `jira me` | `docker exec dev-cli-tools jira me` |

**Nested command substitution:**

When a command uses command substitution like `$(jira me)`, wrap the inner command too:

```powershell
# Instead of: jira issue list -a$(jira me)
docker exec dev-cli-tools sh -c 'jira issue list -a$(jira me)'
```

Or run the inner command separately first:

```powershell
$user = docker exec dev-cli-tools jira me
docker exec dev-cli-tools jira issue list -a$user
```

---

## Confluence Commands via Container

Instead of running `confluence` directly, wrap it with `docker exec`:

| Direct Command | Container Command |
|----------------|-------------------|
| `confluence page view <pageId>` | `docker exec dev-cli-tools confluence page view <pageId>` |
| `confluence page search "query"` | `docker exec dev-cli-tools confluence page search "query"` |
| `confluence page create --space KEY --title "Title"` | `docker exec dev-cli-tools confluence page create --space KEY --title "Title"` |
| `confluence space list` | `docker exec dev-cli-tools confluence space list` |

---

## Multi-line Commands and Complex Input

**For commands with multi-line input or complex quoting:**

```powershell
# Option 1: Use here-strings (PowerShell)
$content = @"
Multi-line content here
Can span multiple lines
"@
docker exec dev-cli-tools confluence page create --space KEY --title "Title" --body $content

# Option 2: Write to a temp file in container
docker exec dev-cli-tools sh -c "echo 'content' > /tmp/input.txt"
docker exec dev-cli-tools jira issue create -tTask -s"Summary" -b"$(cat /tmp/input.txt)"
```

---

## Environment Variables

**Pass environment variables to container commands:**

```powershell
docker exec -e JIRA_API_TOKEN=$env:JIRA_API_TOKEN dev-cli-tools jira me
```

**Or use variables already set in the container** (preferred if configured):

```sh
# Variables should be configured when starting the container
docker exec dev-cli-tools jira me
```

---

## File Operations

**If CLI tools need to access files:**

1. **Copy files into container:**
   ```powershell
   docker cp local-file.txt dev-cli-tools:/tmp/
   docker exec dev-cli-tools confluence page create --space KEY --body-file /tmp/local-file.txt
   ```

2. **Copy output from container:**
   ```powershell
   docker exec dev-cli-tools confluence page view 12345 --output json > output.json
   ```

3. **Use mounted volumes** (if container was started with volume mounts):
   ```powershell
   # Assuming /workspace is mounted in container
   docker exec dev-cli-tools jira issue create -tTask -s"Summary" -b"$(cat /workspace/description.txt)"
   ```

---

## Error Handling

**Container not found:**
```
Error: No such container: dev-cli-tools
→ Inform user to start or create the container
```

**Command not found in container:**
```
Error: executable file not found in $PATH
→ The CLI tool may not be installed in the container
→ Check with: docker exec dev-cli-tools which jira
```

**Permission denied:**
```
→ May need to run with different user: docker exec -u root dev-cli-tools <command>
```

---

## Troubleshooting

**Check what's installed in the container:**
```powershell
docker exec dev-cli-tools which jira
docker exec dev-cli-tools which confluence
docker exec dev-cli-tools ls /usr/local/bin
```

**Verify container configuration:**
```powershell
docker inspect dev-cli-tools
```

**Check container logs:**
```powershell
docker logs dev-cli-tools
```

---

## Examples

**Complete workflow for viewing a Jira issue:**

```powershell
# 1. Check container is running
docker ps --filter "name=dev-cli-tools" --filter "status=running"

# 2. Execute the command
docker exec dev-cli-tools jira issue view PROJ-123
```

**Complete workflow for searching Confluence:**

```powershell
# 1. Check container is running
docker ps --filter "name=dev-cli-tools" --filter "status=running"

# 2. Execute search
docker exec dev-cli-tools confluence page search "deployment guide"

# 3. View specific page from results
docker exec dev-cli-tools confluence page view 12345
```

---

## Integration with Other Skills

When the **jira** or **confluence** skills are loaded:
1. First load this docker-cli-skills skill
2. Apply the `docker exec dev-cli-tools` wrapper to all CLI commands
3. Follow the normal workflow from those skills, but with containerized execution

**Priority:** This skill takes precedence over direct CLI execution in jira/confluence skills.
