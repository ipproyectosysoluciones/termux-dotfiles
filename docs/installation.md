# Installation Guide

## Overview

This repository contains:

- Zsh configuration
- Tmux configuration
- Termux configuration
- Neovim configuration
- Utility scripts
- Plugin bootstrap automation
- Symlink management

The environment is designed for:

- Android + Termux
- Development with:
  - Node.js
  - Go
  - Git
  - Docker
  - Kubernetes
  - Neovim
  - Tmux

---

# Requirements

## Android

Recommended:

- Android 10+
- Physical keyboard support recommended

---

# Install Termux

Install:

- Termux
- Termux:API

Recommended source:

- F-Droid

Avoid outdated Play Store versions.

---

# Initial Termux Setup

Update packages:

```bash
pkg update && pkg upgrade -y
```

Install Git:

```bash
pkg install git -y
```

Install curl:

```bash
pkg install curl -y
```

Grant storage access:

```bash
termux-setup-storage
```

---

# Clone Repository

Clone dotfiles repository:

```bash
git clone https://github.com/bladimir/Termux-AI-Astaroth.git ~/dotfiles
```

Enter repository:

```bash
cd ~/dotfiles
```

---

# Run Installer

Give execution permissions:

```bash
chmod +x scripts/*.sh
```

Run main installer:

```bash
./scripts/install.sh
```

The installer will:

- Install packages
- Create symbolic links
- Install tmux plugins
- Configure Zsh
- Configure Neovim
- Configure Termux
- Prepare development environment

---

# Restart Environment

Close Termux completely.

Open again.

Then reload shell:

```bash
exec zsh
```

---

# Verify Installation

## Verify Zsh

```bash
echo $SHELL
```

Expected:

```text
/data/data/com.termux/files/usr/bin/zsh
```

---

## Verify Tmux

```bash
tmux ls
```

---

## Verify Neovim

```bash
nvim
```

---

## Verify Git

```bash
git --version
```

---

## Verify Node.js

```bash
node -v
```

---

## Verify Go

```bash
go version
```

---

# SSH Configuration

Generate SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Start ssh-agent:

```bash
eval "$(ssh-agent -s)"
```

Add key:

```bash
ssh-add ~/.ssh/id_ed25519
```

Show public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add the key to GitHub.

---

# Repository Structure

```text
dotfiles/
├── docs
├── scripts
├── termux
├── tmux
└── zsh
```

---

# Useful Commands

## Reload Zsh

```bash
source ~/.zshrc
```

---

## Reload Tmux

```bash
tmux source-file ~/.tmux.conf
```

---

## Reload Termux Settings

```bash
termux-reload-settings
```

---

# AI Tools

## Install AI Provider Tools

This repository includes AI integration tools for development assistance.

### Using the AI Bootstrap Script

To install AI tools and provider configurations:

```bash
bash ~/dotfiles/scripts/debian/bootstrap/ai.sh
```

This script installs:
- gentle-ai CLI for task assistance
- Engram CLI for memory and context management
- AI provider configurations (Google Gemini, OpenCode, Mistral)
- Python dependencies for AI tooling

### Launch the AI Workspace

After running the bootstrap script, launch the AI workspace using the `ai-menu` command:

```bash
ai-menu
```

This opens the interactive launcher with options for NeoVim, OpenCode, Gentle AI, Engram, Full Workspace, and Sessions.

For tmux popup mode (requires tmux running):

```bash
ai-menu
# Then use Prefix + A in tmux, or type 'aip' directly
```

Keyboard shortcut in tmux: `Prefix + A`

---

### Verify AI Tools Installation

After running the bootstrap script:

```bash
gentle-ai --version
engram --version
```

### Available AI Providers

The system supports multiple AI providers with automatic fallback:

| Provider | Environment Variable | Purpose |
|----------|---------------------|---------|
| Gemini | GEMINI_API_KEY | Research and architecture tasks |
| OpenCode | OPENCODE_API_KEY | Coding assistance |
| Mistral | MISTRAL_API_KEY | General purpose AI |
| Gentle (fallback) | None required | Local fallback |

### Configuration

AI provider keys should be stored in a `.env` file in the project root:

```text
GEMINI_API_KEY=your_gemini_key_here
OPENCODE_API_KEY=your_opencode_key_here
MISTRAL_API_KEY=your_mistral_key_here
```

---

# Common Problems

## Permission denied

Fix:

```bash
chmod +x scripts/*.sh
```

---

## Tmux plugins not loading

Install TPM plugins manually:

```bash
~/.tmux/plugins/tpm/scripts/install_plugins.sh
```

---

## SSH key asks passphrase repeatedly

Verify ssh-agent:

```bash
ssh-add -l
```

---

# Backup

Create backup:

```bash
cp -r ~/.config ~/config_backup
```

Backup dotfiles:

```bash
cp -r ~/dotfiles ~/dotfiles_backup
```

---

# Update Dotfiles

Enter repository:

```bash
cd ~/dotfiles
```

Pull changes:

```bash
git pull
```

Reload environment:

```bash
exec zsh
```

---

# Recommended Workflow

- Use `tmux` for sessions
- Use `zoxide` for navigation
- Use `Neovim` for editing
- Store projects inside:

```text
~/Projects
```

---

# Notes

This setup is optimized for:

- Mobile development
- SSH workflows
- Git workflows
- DevOps tooling
- Kubernetes workflows
- Terminal-first productivity
