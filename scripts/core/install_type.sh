#!/data/data/com.termux/files/usr/bin/bash

# Install type detection for Termux dotfiles
# Detects whether dotfiles were installed via Termux package or curl installer

# Allow path overrides for testing
TERMX_DATA_PATH="${TERMX_DATA_PATH:-/data/data/com.termux/files/usr}"
MOCK_HOME="${MOCK_HOME:-$HOME}"

detect_install_type() {
    # Check for Termux package installation
    local pkg_version_file="${TERMX_DATA_PATH}/share/termux-dotfiles/VERSION"
    if [[ -f "$pkg_version_file" ]]; then
        echo "package"
        return 0
    fi

    # Check for curl/git clone installation
    local curl_version_file="${MOCK_HOME}/dotfiles/VERSION"
    if [[ -f "$curl_version_file" ]]; then
        echo "curl"
        return 0
    fi

    echo "unknown"
    return 0
}

get_local_version() {
    local install_type
    install_type="$(detect_install_type)"

    case "$install_type" in
        package)
            local pkg_version_file="${TERMX_DATA_PATH}/share/termux-dotfiles/VERSION"
            if [[ -f "$pkg_version_file" ]]; then
                cat "$pkg_version_file"
            fi
            ;;
        curl)
            local curl_version_file="${MOCK_HOME}/dotfiles/VERSION"
            if [[ -f "$curl_version_file" ]]; then
                cat "$curl_version_file"
            fi
            ;;
        *)
            # Unknown install type - return empty
            ;;
    esac
}