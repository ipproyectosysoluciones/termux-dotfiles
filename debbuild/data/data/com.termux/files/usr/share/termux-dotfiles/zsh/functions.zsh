#########################################
# GIT
#########################################

gc() {
    if [[ -z "$*" ]]; then
        echo "Usage: gc \"mensaje\""
        return 1
    fi

    git commit -m "$*"
}

#########################################
# PROJECTS
#########################################

mkproject() {
    if [ -z "$1" ]; then
        echo "Usage: mkproject <project-name>"
        return 1
    fi

    [[ -d "$PROJECTS_DIR/$1" ]] || mkdir -p "$PROJECTS_DIR/$1"

    cd "$PROJECTS_DIR/$1"
}

mkdev() {
    if [ -z "$1" ]; then
        echo "Usage: mkdev <project-name>"
        return 1
    fi

    [[ -d "$PROJECTS_DIR/$1" ]] || mkdir -p "$PROJECTS_DIR/$1"

    cd "$PROJECTS_DIR/$1"

    [[ -d backend ]] || mkdir -p backend frontend docker docs scripts

    [[ -f README.md ]] || touch README.md .gitignore

    [[ -d .git ]] || git init
}

#########################################
# TMUX PROJECT
#########################################

dev() {
    if [ -z "$1" ]; then
        echo "Usage: dev <project>"
        return 1
    fi

    [[ -d "$PROJECTS_DIR/$1" ]] || mkdir -p "$PROJECTS_DIR/$1"

    cd "$PROJECTS_DIR/$1"

    tmux new-session -A -s "$1"
}

#########################################
# DEBIAN
#########################################

ai-deb() {
    proot-distro login debian --shared-tmp
}
