#!/data/data/com.termux/files/usr/bin/bash

set -e

clear

echo "========================================="
echo " DEBIAN DEVOPS INSTALLER"
echo "========================================="
echo

########################################
# VALIDAR DEBIAN
########################################

echo "[+] Verificando Debian..."

if ! proot-distro login debian -- true 2>/dev/null; then
  echo "[ERROR] Debian no está instalado o no inicia correctamente"
  exit 1
fi

########################################
# CREAR SCRIPT INTERNO
########################################

echo "[+] Creando script interno Debian..."

cat <<'EOF' > ~/debian-devops-install.sh
#!/bin/bash

set -euo pipefail

apt update && apt upgrade -y

########################################
# DEPENDENCIAS
########################################

apt install -y \
  curl \
  wget \
  git \
  sudo \
  nano \
  vim \
  zsh \
  tmux \
  unzip \
  zip \
  ca-certificates \
  gnupg \
  lsb-release \
  build-essential \
  ripgrep \
  fd-find \
  fzf \
  bat \
  btop \
  tree

########################################
# NODEJS
########################################

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

########################################
# PNPM
########################################

npm install -g pnpm

########################################
# GEMINI CLI
########################################

npm install -g @google/gemini-cli

########################################
# CLAUDE CODE
########################################

npm install -g @anthropic-ai/claude-code

########################################
# OPENCODE AI
########################################

# npm install -g opencode-ai

########################################
# DOCKER CLI
########################################

curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce-cli

########################################
# KUBECTL
########################################

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

########################################
# HELM
########################################

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

########################################
# ALIASES
########################################

cat <<'EOL' >> ~/.zshrc

alias k='kubectl'
alias d='docker'
alias dc='docker compose'
alias cls='clear'
alias gem='gemini'
alias cc='claude'
alias oc='opencode'

EOL

########################################
# FINAL
########################################

echo

echo "========================================="
echo " INSTALACION COMPLETADA"
echo "========================================="
echo

echo "Comandos disponibles:"
echo

echo "gemini"
echo "claude"
echo "opencode"
echo "kubectl"
echo "docker"
echo "helm"
echo "pnpm"
echo

EOF

chmod +x ~/debian-devops-install.sh

########################################
# COPIAR A DEBIAN
########################################

cp ~/debian-devops-install.sh \
~/../usr/var/lib/proot-distro/installed-rootfs/debian/root/

########################################
# EJECUTAR EN DEBIAN
########################################

echo "[+] Ejecutando instalación dentro de Debian..."

proot-distro login debian -- bash /root/debian-devops-install.sh

########################################
# WRAPPERS CORE-TERMUX
########################################

echo "[+] Creando wrappers Core-Termux..."

cat <<'EOF' > $PREFIX/bin/gemini
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- gemini "$@"
EOF

cat <<'EOF' > $PREFIX/bin/claude
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- claude "$@"
EOF

# cat <<'EOF' > $PREFIX/bin/opencode
# #!/data/data/com.termux/files/usr/bin/bash
# proot-distro login debian -- opencode "$@"
# EOF

cat <<'EOF' > $PREFIX/bin/docker
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- docker "$@"
EOF

cat <<'EOF' > $PREFIX/bin/kubectl
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- kubectl "$@"
EOF

cat <<'EOF' > $PREFIX/bin/helm
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- helm "$@"
EOF

cat <<'EOF' > $PREFIX/bin/pnpm
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login debian -- pnpm "$@"
EOF

chmod +x $PREFIX/bin/gemini
chmod +x $PREFIX/bin/claude
# chmod +x $PREFIX/bin/opencode
chmod +x $PREFIX/bin/docker
chmod +x $PREFIX/bin/kubectl
chmod +x $PREFIX/bin/helm
chmod +x $PREFIX/bin/pnpm

########################################
# FINAL
########################################

echo

echo "========================================="
echo " SETUP COMPLETADO"
echo "========================================="
echo

echo "Ahora puedes usar desde Termux:"
echo

echo "gemini"
echo "claude"
# echo "opencode"
echo "docker"
echo "kubectl"
echo "helm"
echo "pnpm"
echo
