#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail

PREFIX_BIN="$PREFIX/bin"

create_wrapper() {
  local name="$1"

  cat > "$PREFIX_BIN/$name" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- $name "\$@"
EOF

  chmod +x "$PREFIX_BIN/$name"

  echo "[wrapper] installed: $name"
}

########################################
# AI
########################################

create_wrapper gemini
create_wrapper claude

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

