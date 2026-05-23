#!/data/data/com.termux/files/usr/bin/bash

########################################
# TERMUX
########################################

TERMUX_HOME="/data/data/com.termux/files/home"

########################################
# DEBIAN
########################################

DEBIAN_HOME="/home/dev"

########################################
# TERMUX -> DEBIAN
########################################

to_debian_path() {

    local path="${1:-}"

    echo "$path" \
        | sed "s|$TERMUX_HOME|/termux|"
}

########################################
# DEBIAN -> TERMUX
########################################

to_termux_path() {

    local path="${1:-}"

    echo "$path" \
        | sed "s|^/termux|$TERMUX_HOME|"
}

########################################
# PROVIDER PATH
########################################

provider_project_path() {

    local provider="${1:-}"
    local path="${2:-}"

    case "$provider" in

        opencode|claude|gemini)
            to_debian_path "$path"
            ;;

        *)
            echo "$path"
            ;;
    esac
}

