# Debian Runtime

This document describes the Debian runtime environment configuration for the termux-dotfiles setup.

## Overview

The Debian runtime is provided via `proot-distro` and allows running a full Debian environment within Termux on Android. This enables access to a complete Linux development environment with native build tools and packages.

## Runtime Structure

```
proot-distro debian
├── ~/.local/bin/          # User binaries (wrappers, scripts)
├── ~/.local/share/        # Shared data
└── /usr/local/            # Debian system packages
```

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `EDITOR` | `nvim` | Default text editor |
| `VISUAL` | `nvim` | Visual editor |
| `PATH` | `$HOME/.local/bin:$HOME/bin:$PATH` | Binary search path |

## Scripts

### doctor.sh

Health check script that verifies:
- `proot-distro` is installed
- Required binaries (bash, zsh, git, curl, nvim) are available
- `$HOME/dotfiles` directory exists
- Config directories (`.config/zsh`, `.config/nvim`, `.tmux`) exist

Usage:
```bash
bash scripts/debian/doctor.sh
```

### runtime.sh

Environment initialization script that:
- Configures PATH to include `.local/bin`
- Sets default editor variables
- Creates `.local` directories if missing
- Loads dotfiles environment from `$HOME/dotfiles/scripts/core/env.sh`

Usage:
```bash
source scripts/debian/runtime.sh
```

## Packages

Core packages installed in Debian:

| Package | Purpose |
|---------|---------|
| `build-essential` | Compiler toolchain |
| `git` | Version control |
| `curl` | HTTP client |
| `wget` | File downloads |
| `zsh` | Shell |
| `neovim` | Text editor |
| `python3` | Python runtime |
| `golang` | Go compiler |

## Usage

### Enter Debian

```bash
debian    # or: proot-distro login debian
```

### With shared Termux home

```bash
deb    # mounts Termux home at /termux
```

### Run diagnostics

```bash
bash scripts/debian/doctor.sh
```

### Initialize runtime

```bash
source scripts/debian/runtime.sh
```

## Troubleshooting

### proot-distro not found

Install proot-distro in Termux:
```bash
pkg install proot-distro
```

### Slow performance

- Use `deb` alias for shared home (faster file access)
- Avoid running GUI applications
- Limit background processes

### Missing dependencies

Run doctor.sh to identify missing packages, then install manually in Debian:
```bash
apt install <package-name>
```

## Docker Workflow

The `docker.sh` launcher provides unified access to Docker via proot-distro Debian.

### How It Works

1. **Proot-distro first**: Checks if `proot-distro login debian` is available
2. **Docker inside Debian**: Routes to docker binary installed inside Debian
3. **Fallback**: If no docker inside Debian, checks for native Termux docker
4. **Error**: If neither exists, displays installation instructions

### Daemon Limitation

Docker daemon cannot run inside proot-distro (`cgroup` limitation). The CLI works for all non-daemon operations:

| Operation | Without daemon | With remote context |
|-----------|---------------|-------------------|
| `docker build` | ✅ | ✅ |
| `docker pull` / `push` | ✅ | ✅ |
| `docker info` | ✅ | ✅ |
| `docker ps` / `run` / `exec` | ❌ | ✅ |
| `docker compose` | ⚠️ build only | ✅ |

### Remote Docker Context (for containers)

To run containers, connect to a remote Docker host:

```bash
docker context create remote \
  --docker host=tcp://<HOST>:2375
docker context use remote
docker ps  # now works remotely
```

The launcher shows daemon status and available contexts on entry.

### Usage

```bash
# From AI Workspace menu → Docker, or:
docker
```

### Bind Mount

The `--bind $HOME:/termux` flag mounts your Termux home directory into the Debian environment at `/termux`, allowing access to project files.

### User Mode

Uses `--user dev` to run docker commands as the `dev` user within Debian, avoiding root permissions issues.