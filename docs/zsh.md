# Zsh Guide

## Overview

Zsh is the main shell used in this environment.

This setup provides:

- Improved terminal navigation
- Better autocompletion
- Syntax highlighting
- Autosuggestions
- Git shortcuts
- Faster workflows
- Better mobile terminal experience

The configuration is optimized for:

- Android + Termux
- DevOps workflows
- Git workflows
- Neovim workflows
- Tmux workflows

---

# Configuration Structure

Main file:

```text
~/.zshrc
```

Real configuration location:

```text
~/dotfiles/zsh
```

Configuration is modularized.

---

# Zsh Configuration Files

| File | Purpose |
|---|---|
| exports.zsh | environment variables |
| history.zsh | shell history configuration |
| plugins.zsh | plugin loading |
| aliases.zsh | command aliases |
| functions.zsh | custom shell functions |
| ssh.zsh | ssh-agent configuration |
| tmux.zsh | tmux auto-start |
| p10k.zsh | Powerlevel10k prompt |
| zshrc | main loader |

---

# Reload Zsh

After changing configuration:

```bash
source ~/.zshrc
```

Or restart shell:

```bash
exec zsh
```

---

# Verify Active Shell

```bash
echo $SHELL
```

Expected:

```text
/data/data/com.termux/files/usr/bin/zsh
```

---

# Powerlevel10k

Prompt theme:

```text
Powerlevel10k
```

Features:

- Git status
- Execution time
- Current directory
- Exit codes
- Tmux awareness
- Kubernetes context support

---

# Instant Prompt

Enabled for faster startup.

Configuration:

```zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
```

Purpose:

- Faster shell startup
- Reduced prompt flickering

---

# History Configuration

History file:

```text
~/.zsh_history
```

Important options:

```zsh
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt histignorealldups
```

Behavior:

- Shared history across terminals
- Immediate history saving
- Duplicate reduction

---

# Plugins

Plugins are stored in:

```text
~/.zsh-plugins
```

---

# Installed Plugins

## zsh-autosuggestions

Shows suggestions from history.

Example:

```text
git status
```

Press:

```text
RIGHT ARROW
```

To accept suggestion.

---

## zsh-syntax-highlighting

Highlights commands while typing.

Color meaning:

| Color | Meaning |
|---|---|
| green | valid command |
| red | invalid command |

---

## zsh-defer

Loads plugins asynchronously.

Purpose:

- Faster shell startup

---

## fzf-tab

Improved fuzzy tab completion.

Example:

```bash
cd <TAB>
```

---

## zsh-completions

Additional command completions.

---

# Plugin Loading

Plugins are loaded from:

```text
plugins.zsh
```

---

# Alias System

Aliases are stored in:

```text
aliases.zsh
```

---

# Common Aliases

## File Navigation

```bash
ll
```

Equivalent:

```bash
eza -lah --icons
```

---
