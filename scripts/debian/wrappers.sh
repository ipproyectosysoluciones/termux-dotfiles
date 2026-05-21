#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

PREFIX_BIN="$HOME/.local/bin"

mkdir -p "$PREFIX_BIN"

create_wrapper() {

  local name="$1"

  cat > "$PREFIX_BIN/$name" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

########################################
# INSIDE DEBIAN
########################################

if [[ -f /etc/debian_version ]]; then
    exec $name "\$@"
fi

########################################
# TERMUX -> DEBIAN
########################################

exec proot-distro login debian \
    --bind \$HOME:/termux \
    --user dev -- \
    env PATH="/home/dev/.opencode/bin:/home/dev/.local/share/pnpm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    $name "\$@"
EOF

  chmod +x "$PREFIX_BIN/$name"

  echo "[wrapper] installed: $name"
}

########################################
# AI
########################################

create_wrapper gemini
create_wrapper claude
create_wrapper opencode
create_wrapper gentle-ai

########################################
# NODE
########################################

create_wrapper node
create_wrapper npm
create_wrapper pnpm

########################################
# KUBERNETES
########################################

create_wrapper kubectl
create_wrapper helm

echo
echo "[wrapper] all wrappers installed"

