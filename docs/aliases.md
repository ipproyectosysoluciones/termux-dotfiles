# Aliases Guide

## Overview

Aliases are command shortcuts used to simplify repetitive terminal operations.

The alias configuration is stored in:

```text
~/dotfiles/zsh/aliases.zsh
```

Symbolic link:

```text
~/.config/zsh/aliases.zsh
```

Purpose:

- Faster workflows
- Shorter commands
- Better mobile terminal usage
- Reduced typing
- Cleaner command history

---

# Reload Aliases

After modifying aliases:

```bash
source ~/.zshrc
```

Or:

```bash
exec zsh
```

---

# List All Aliases

Show all active aliases:

```bash
alias
```

Search specific alias:

```bash
alias gs
```

---

# File Navigation Aliases

## ll

```bash
ll
```

Equivalent:

```bash
eza -lah --icons
```

Purpose:

- Detailed directory listing
- Icons support
- Better readability

---

## ls

```bash
ls
```

Equivalent:

```bash
lsd
```

Purpose:

- Improved directory listing
- Better colors
- Icons support

---

# Git Aliases

Git aliases reduce repetitive typing.

---

## gs

```bash
gs
```

Equivalent:

```bash
git status
```

Purpose:

- Quick repository status

---

## ga

```bash
ga
```

Equivalent:

```bash
git add .
```

Purpose:

- Stage all changes

---

## gc

Usage:

```bash
gc "commit message"
```

Equivalent:

```bash
git commit -m "commit message"
```

Purpose:

- Faster commits

---

## gp

```bash
gp
```

Equivalent:

```bash
git push
```

Purpose:

- Push changes to remote repository

---

## gpl

```bash
gpl
```

Equivalent:

```bash
git pull
```

Purpose:

- Pull latest changes

---

# System Aliases

---

## update

```bash
update
```

Equivalent:

```bash
pkg update && pkg upgrade -y
```

Purpose:

- Update Termux packages

---

## df

```bash
df
```

Equivalent:

```bash
df -h
```

Purpose:

- Human-readable disk usage

---

# File Viewing Aliases

---

## cat

```bash
cat file.txt
```

Equivalent:

```bash
bat --theme=Dracula --style=plain --paging=never file.txt
```

Purpose:

- Syntax highlighting
- Better readability
- Cleaner file previews

---

# Debian Aliases

---

## debian

```bash
debian
```

Equivalent:

```bash
proot-distro login debian
```

Purpose:

- Start Debian container quickly

---

## deb

```bash
deb
```

Equivalent:

```bash
proot-distro login debian --bind /data/data/com.termux/files/home:/termux --user dev
```

Purpose:

- Start Debian with mounted Termux home
- Shared workspace access

---

# Go Aliases

---

## engram

```bash
engram
```

Equivalent:

```bash
$HOME/go/bin/engram
```

Purpose:

- Execute local Go binary quickly

---

# Why Aliases Matter on Mobile

On Android keyboards:

- Typing is slower
- CTRL combinations may fail
- Long commands are uncomfortable

Aliases reduce friction significantly.

Example:

Instead of:

```bash
git commit -m "update config"
```

Use:

```bash
gc "update config"
```

---

# Alias Best Practices

Recommended rules:

- Keep aliases short
- Use memorable names
- Avoid overriding critical commands unnecessarily
- Document custom aliases

---

# Alias Naming Strategy

Current convention:

| Prefix | Purpose |
|---|---|
| g | git |
| d | debian |
| l | listing |
| u | updates |

---

# Adding New Aliases

Edit aliases file:

```bash
nvim ~/.config/zsh/aliases.zsh
```

Add alias:

```zsh
alias k='kubectl'
```

Reload shell:

```bash
source ~/.zshrc
```

---

# Recommended Future Aliases

## Kubernetes

```zsh
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
```

---

## Docker

```zsh
alias dps='docker ps'
alias dcu='docker compose up'
alias dcd='docker compose down'
```

---

## Neovim

```zsh
alias v='nvim'
```

---

## Tmux

```zsh
alias ta='tmux attach'
alias tls='tmux ls'
```

---

# Troubleshooting

## Alias Not Working

Verify alias exists:

```bash
alias alias_name
```

Example:

```bash
alias gs
```

---

## Reload Configuration

```bash
source ~/.zshrc
```

---

## Verify Alias File

```bash
ls ~/.config/zsh
```

---

# Useful Commands

## Open Alias File

```bash
nvim ~/.config/zsh/aliases.zsh
```

---

## Search Aliases

```bash
alias | grep git
```

---

## Remove Alias Temporarily

```bash
unalias alias_name
```

Example:

```bash
unalias ls
```

---

# Notes

Aliases improve productivity significantly when working from:

- Mobile devices
- Small keyboards
- SSH sessions
- Remote terminals
- DevOps environments

This setup prioritizes:

- Speed
- Reduced typing
- Better readability
- Faster navigation
- Faster Git workflows
