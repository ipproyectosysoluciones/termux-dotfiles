#!/data/data/com.termux/files/usr/bin/bash

session_name() {
    basename "$1"
}

session_exists() {
    tmux has-session -t "$1" 2>/dev/null
}

