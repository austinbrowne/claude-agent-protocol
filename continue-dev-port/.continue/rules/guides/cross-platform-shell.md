---
name: Cross-Platform Shell Reference
description: Shell command translation for cross-platform terminal operations -- bash vs PowerShell vs cmd. Load when running terminal commands.
alwaysApply: false
---

# Cross-Platform Shell Reference

Detect the user's OS and shell before running terminal commands.

## Command Translation

| Operation | bash/zsh (macOS/Linux) | PowerShell (Windows) |
|-----------|----------------------|---------------------|
| List files | `ls -la` | `Get-ChildItem` or `ls` |
| Find files | `find . -name "*.ts"` | `Get-ChildItem -Recurse -Filter "*.ts"` |
| Search content | `grep -r "pattern" .` | `Select-String -Path . -Pattern "pattern" -Recurse` |
| Set env var | `export FOO=bar` | `$env:FOO = "bar"` |
| Chain commands | `cmd1 && cmd2` | `cmd1; if ($?) { cmd2 }` |
| Redirect | `cmd > file 2>&1` | `cmd *> file` |
| Path separator | `/` | `\` (or `/` in most contexts) |
| Remove file | `rm -f file` | `Remove-Item file -Force` |
| Remove directory | `rm -rf dir` | `Remove-Item dir -Recurse -Force` |
| Create directory | `mkdir -p dir/sub` | `New-Item -ItemType Directory -Path dir/sub -Force` |
| Copy file | `cp src dest` | `Copy-Item src dest` |
| Move/rename | `mv old new` | `Move-Item old new` |
| Current directory | `pwd` | `Get-Location` or `pwd` |
| Print/echo | `echo "text"` | `Write-Output "text"` or `echo "text"` |
| Cat file | `cat file` | `Get-Content file` or `cat file` |
| Heredoc | `cat <<'EOF'\n...\nEOF` | `@"\n...\n"@` |

## Platform-Neutral Commands (Work Everywhere)

These commands work identically across platforms -- prefer them:

- `git` -- all git operations
- `npm`, `npx`, `yarn`, `pnpm` -- Node.js package management
- `node` -- Node.js execution
- `python`, `python3` -- Python execution
- `pip`, `pip3` -- Python packages
- `cargo` -- Rust toolchain
- `docker`, `docker-compose` -- Container operations
- `gh` -- GitHub CLI (or `glab` for GitLab)

## Detection

Before running shell-specific commands, check the environment:

- If the user's terminal shows `PS C:\>` or mentions PowerShell -> use PowerShell syntax
- If the terminal shows `$` or `%` prompt -> use bash/zsh syntax
- When uncertain, ask the user which shell they're using
- Default to platform-neutral commands when possible

## Common Gotchas

| Gotcha | bash/zsh | PowerShell |
|--------|---------|------------|
| String interpolation | `"Hello $NAME"` | `"Hello $env:NAME"` |
| Single vs double quotes | Single = literal, double = interpolated | Same behavior |
| Null check | `[ -z "$VAR" ]` | `[string]::IsNullOrEmpty($var)` |
| File existence | `[ -f "file" ]` | `Test-Path "file"` |
| Process substitution | `<(command)` | Not available -- use temp files |
| Here-string | `<<'EOF'` | `@'...'@` (single-quote = literal) |
