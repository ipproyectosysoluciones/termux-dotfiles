# Tmux Guide

## Overview

Tmux is a terminal multiplexer.

It allows:

- Multiple terminal windows
- Multiple panes
- Persistent sessions
- Session recovery
- Detached background sessions

This setup is optimized for:

- Android + Termux
- Mobile keyboards
- DevOps workflows
- Long-running development sessions

---

# Configuration File

Main configuration:

```text
~/.tmux.conf
```

Real configuration path:

```text
~/dotfiles/tmux/tmux.conf
```

Symbolic link:

```text
~/.tmux.conf -> ~/dotfiles/tmux/tmux.conf
```

---

# Prefix Key

Default tmux prefix:

```text
CTRL + B
```

Custom prefix used in this setup:

```text
CTRL + A
```

Example:

```text
CTRL + A then c
```

Creates a new window.

---

# Starting Tmux

## Start New Session

```bash
tmux
```

---

## Start Named Session

```bash
tmux new -s main
```

---

## Attach Existing Session

```bash
tmux attach -t main
```

---

## List Sessions

```bash
tmux ls
```

---

# Windows

A window behaves like a separate terminal tab.

---

## Create Window

```text
PREFIX + c
```

Example:

```text
CTRL + A then c
```

---

## Next Window

```text
PREFIX + n
```

---

## Previous Window

```text
PREFIX + p
```

---

## Switch by Number

```text
PREFIX + 1
PREFIX + 2
PREFIX + 3
```

---

## Rename Window

```text
PREFIX + ,
```

---

## Kill Window

```text
PREFIX + &
```

---

# Panes

Panes split a single terminal window.

---

## Vertical Split

```text
PREFIX + -
```

---

## Horizontal Split

```text
PREFIX + \
```

---

## Move Between Panes

```text
PREFIX + h
PREFIX + j
PREFIX + k
PREFIX + l
```

Direction mapping:

| Key | Direction |
|---|---|
| h | left |
| j | down |
| k | up |
| l | right |

---

## Resize Panes

```text
PREFIX + Shift + H
PREFIX + Shift + J
PREFIX + Shift + K
PREFIX + Shift + L
```

---

## Close Pane

Inside pane:

```bash
exit
```

Or:

```text
PREFIX + x
```

---

# Session Management

---

## Detach Session

```text
PREFIX + d
```

Tmux continues running in background.

---

## Reattach Session

```bash
tmux attach
```

---

## Kill Session

```bash
tmux kill-session -t main
```

---

# Copy Mode

Tmux supports terminal text selection.

---

## Enter Copy Mode

```text
PREFIX + [
```

---

## Navigation

Use:

```text
h j k l
```

Or arrow keys.

---

## Start Selection

```text
v
```

---

## Copy Selection

```text
y
```

---

## Exit Copy Mode

```text
q
```

---

# Reload Configuration

After editing tmux.conf:

```bash
tmux source-file ~/.tmux.conf
```

Or inside tmux:

```text
PREFIX + r
```

---

# Tmux Plugins

Plugin manager:

```text
TPM
```

Repository:

```text
~/.tmux/plugins/tpm
```

---

# Installed Plugins

## tmux-sensible

Provides sane defaults.

---

## tmux-resurrect

Saves and restores tmux sessions.

---

## tmux-continuum

Automatic tmux session persistence.

---

# Install Plugins

Inside tmux:

```text
PREFIX + Shift + I
```

Equivalent:

```text
CTRL + A then Shift + I
```

---

# Update Plugins

Inside tmux:

```text
PREFIX + U
```

---

# Remove Plugins

Inside tmux:

```text
PREFIX + ALT + u
```

---

# Restore Sessions

Manual restore:

```text
PREFIX + CTRL + r
```

---

# Plugin Installation Troubleshooting

If TPM is missing:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Reload config:

```bash
tmux source-file ~/.tmux.conf
```

Install plugins:

```bash
~/.tmux/plugins/tpm/scripts/install_plugins.sh
```

---

# Mobile Keyboard Recommendations

Recommended extra keys:

```text
CTRL
ALT
ESC
TAB
/
-
|
UP
DOWN
LEFT
RIGHT
```

---

# Useful Commands

## Show Current Sessions

```bash
tmux ls
```

---

## Show Windows

```bash
tmux list-windows
```

---

## Show Panes

```bash
tmux list-panes
```

---

## Check Loaded Plugins

```bash
tmux show-options -g | grep @plugin
```

---

# Recommended Workflow

Suggested layout:

| Window | Purpose |
|---|---|
| 1 | shell |
| 2 | neovim |
| 3 | git |
| 4 | docker |
| 5 | kubernetes |

---

# Android Notes

Tmux on Android behaves differently from desktop Linux.

Some keyboards may not correctly send:

- CTRL combinations
- ALT combinations
- Function keys

Recommended keyboards:

- Hacker's Keyboard
- Unexpected Keyboard

---

# Common Problems

## Cannot switch windows

Verify prefix:

```bash
tmux list-keys | grep prefix
```

---

## Nested tmux warning

Message:

```text
sessions should be nested with care
```

Solution:

Detach first:

```text
PREFIX + d
```

---

## Plugins not loading

Verify TPM exists:

```bash
ls ~/.tmux/plugins
```

Reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

---

# Useful Files

## Main Config

```text
~/dotfiles/tmux/tmux.conf
```

---

## Plugin Directory

```text
~/.tmux/plugins
```

---

## Resurrect Saves

```text
~/.tmux/resurrect
```

---

# Recommended Habit

Always work inside tmux.

Benefits:

- Persistent sessions
- Session recovery
- Faster multitasking
- Better mobile workflow
- Safer long-running processes
