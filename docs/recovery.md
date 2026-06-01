recovery.md

# Recovery

## Objetivo

Este documento explica cómo recuperar completamente el entorno de desarrollo basado en:

- Termux
- Zsh
- tmux
- Neovim
- Dotfiles
- Plugins
- Symlinks
- SSH
- GitHub CLI

---

# Escenarios de recuperación

## Casos comunes

- nuevo dispositivo Android
- reinstalación de Termux
- corrupción de configuraciones
- pérdida de symlinks
- plugins dañados
- tmux roto
- zsh lento o inconsistente
- pérdida de sesión
- restauración rápida de entorno

---

# Requisitos mínimos

## Instalar Termux

Usar únicamente:

- F-Droid
- GitHub oficial

No usar Google Play.

---

# Actualizar sistema

```bash id="v6a9t2"
pkg update && pkg upgrade -y


---

Instalar Git

pkg install git -y


---

Acceso al almacenamiento

termux-setup-storage


---

Clonar dotfiles

Repositorio

git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git


---

Entrar al repositorio

cd ~/termux-dotfiles


---

Estructura esperada

termux-dotfiles/
├── docs
├── scripts
├── termux
├── tmux
├── zsh
└── nvim


---

Instalación automática

Script principal

bash scripts/install.sh

Este script:

instala paquetes

instala plugins

crea symlinks

configura entorno

recarga configuraciones



---

Instalación manual

Paquetes base

pkg install -y \
git \
curl \
wget \
zsh \
tmux \
neovim \
openssh \
ripgrep \
fd \
fzf \
eza \
bat \
lsd \
nodejs \
python \
golang


---

Restaurar symlinks

Script

bash scripts/core/symlinks.sh


---

Verificar symlinks

Zsh

readlink ~/.config/zsh

Resultado esperado:

/data/data/com.termux/files/home/dotfiles/zsh


---

tmux

readlink ~/.config/tmux


---

Termux

readlink ~/.config/termux


---

Restaurar plugins Zsh

Directorio esperado

~/.zsh-plugins


---

Plugins requeridos

powerlevel10k
zsh-autosuggestions
zsh-syntax-highlighting
zsh-defer
fzf-tab
zsh-completions


---

Instalar plugins automáticamente

bash scripts/nvim/plugins.sh


---

Restaurar TPM

Instalar TPM

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


---

Recargar tmux

tmux source-file ~/.tmux.conf


---

Instalar plugins tmux

~/.tmux/plugins/tpm/scripts/install_plugins.sh


---

Verificar plugins tmux

eza -la ~/.tmux/plugins

Resultado esperado:

tpm
tmux-sensible
tmux-resurrect
tmux-continuum


---

Restaurar sesión tmux

Manualmente

tmux attach -t main


---

Restauración automática

Con tmux-continuum:

las sesiones se restauran automáticamente

los paneles vuelven a abrirse

las ventanas se recuperan



---

Restaurar Zsh

Recargar configuración

source ~/.zshrc


---

Reiniciar shell

exec zsh


---

Problema: warning Powerlevel10k

Síntoma

Console output during zsh initialization detected


---

Solución

Agregar al inicio de ~/.zshrc:

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


---

Problema: compdef no encontrado

Síntoma

compdef: function not found


---

Solución

Verificar:

autoload -Uz compinit
compinit

Debe ejecutarse antes de plugins.


---

Problema: tmux plugins no cargan

Verificar

tmux show-options -g | grep @plugin


---

Revisar final de ~/.tmux.conf

Debe existir:

run '~/.tmux/plugins/tpm/tpm'


---

Problema: ssh-agent pide password constantemente

Verificar claves cargadas

ssh-add -l


---

Cargar clave manualmente

ssh-add ~/.ssh/id_ed25519


---

Problema: symlinks rotos

Detectar

ls -l ~/.config


---

Recrear

bash scripts/core/symlinks.sh


---

Problema: tmux no cambia ventanas

Revisar prefix

tmux list-keys | grep prefix


---

Prefix configurado

CTRL + A


---

Problema: Termux lento

Posibles causas

demasiados plugins

historial excesivo

procesos zombies

plugins tmux dañados

Android limitando procesos



---

Optimización Android

Desactivar ahorro de batería

Ruta general:

Ajustes → Apps → Termux → Batería → Sin restricciones


---

Backup manual

Crear backup configs

mkdir -p ~/dotfiles_backup


---

Copiar configuraciones

cp -r ~/.config/zsh ~/dotfiles_backup/
cp -r ~/.config/tmux ~/dotfiles_backup/
cp -r ~/.config/termux ~/dotfiles_backup/


---

Backup Git

Guardar cambios

git add .
git commit -m "backup configs"
git push


---

Recuperación total rápida

Flujo completo

pkg update && pkg upgrade -y

pkg install git -y

git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git

cd termux-dotfiles

bash scripts/install.sh


---

Validaciones finales

Zsh

echo $SHELL


---

tmux

tmux ls


---

GitHub CLI

gh auth status


---

SSH

ssh-add -l


---

Symlinks

readlink ~/.config/zsh


---

Objetivo final

Poder restaurar completamente el entorno en pocos minutos desde cualquier dispositivo Android usando únicamente:

Git

Termux

dotfiles

scripts automatizados

