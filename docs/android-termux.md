android-termux.md

# Android + Termux

## Objetivo

Este entorno convierte Android + Termux en una estación de desarrollo portátil orientada a:

- Desarrollo Fullstack
- DevOps
- Kubernetes
- Docker tooling
- Git/GitHub
- Automatización
- Neovim
- tmux
- Zsh
- Desarrollo remoto

---

# Requisitos mínimos

## Android recomendado

- Android 10+
- 4 GB RAM mínimo
- 6 GB RAM recomendado
- 128 GB almacenamiento recomendado

---

# Instalación recomendada de Termux

## Fuente oficial

Instalar desde:

- F-Droid
- GitHub oficial

No usar la versión de Google Play.

---

# Paquetes base

Actualizar Termux:

```bash id="y34rx6"
pkg update && pkg upgrade -y

Instalar paquetes esenciales:

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

Acceso al almacenamiento

Permitir acceso a archivos Android:

termux-setup-storage

Esto crea:

~/storage


---

Estructura recomendada

~/Projects
~/dotfiles
~/go
~/bin


---

Configuración del shell

Cambiar shell por defecto

chsh -s zsh


---

Arquitectura de configuración

Configuración modular

~/.config/zsh
~/.config/tmux
~/.config/termux
~/.config/nvim


---

Dotfiles

Repositorio central

~/dotfiles

Objetivos:

respaldo

portabilidad

automatización

reinstalación rápida



---

Symlinks

Las configuraciones reales viven dentro de:

~/dotfiles

Y se conectan mediante enlaces simbólicos.

Ejemplo:

ln -s ~/dotfiles/zsh ~/.config/zsh


---

Zsh

Plugins instalados

powerlevel10k
zsh-autosuggestions
zsh-syntax-highlighting
fzf-tab
zsh-defer


---

Powerlevel10k

Instant Prompt

Usado para:

inicio rápido

carga visual fluida

menor latencia



---

tmux

Multiplexor principal

Funciones:

múltiples ventanas

paneles

persistencia

restauración de sesiones

trabajo remoto



---

TPM

Administrador de plugins tmux.

Ubicación:

~/.tmux/plugins/tpm


---

Plugins tmux

tmux-sensible

Mejores configuraciones por defecto.


---

tmux-resurrect

Guarda sesiones tmux.


---

tmux-continuum

Restaura sesiones automáticamente.


---

Navegación rápida

zoxide

Aprende rutas frecuentes automáticamente.

Ejemplo:

z dotfiles


---

Debian dentro de Termux

proot-distro

Permite ejecutar Debian sin root.

Instalación:

pkg install proot-distro


---

Instalar Debian

proot-distro install debian


---

Entrar

proot-distro login debian


---

Integración SSH

ssh-agent automático

El entorno:

inicia ssh-agent

reutiliza sesiones

mantiene claves activas



---

Seguridad SSH

Archivos ignorados en Git:

*.pem
*.key
*.pub
.env
.env.*


---

GitHub CLI

Verificar sesión

gh auth status


---

Crear repositorio

gh repo create


---

Neovim

Editor principal

Configurado para:

desarrollo moderno

LSP

Treesitter

Git

terminal workflow



---

Extra Keys Termux

Archivo

~/.config/termux/termux.properties


---

Recargar configuración

termux-reload-settings


---

Rendimiento

Recomendaciones

usar zsh-defer

usar Powerlevel10k instant prompt

evitar plugins innecesarios

mantener historial limpio

evitar procesos pesados permanentes



---

Limitaciones Android

Restricciones comunes

Android puede:

cerrar procesos en segundo plano

limitar memoria

suspender Termux

matar procesos largos



---

Recomendaciones Android

Desactivar optimización de batería

Ruta general:

Ajustes → Apps → Termux → Batería → Sin restricciones


---

Teclados recomendados

Compatibles con terminal

Hacker's Keyboard

Unexpected Keyboard

Gboard con fila numérica



---

Buenas prácticas

usar tmux siempre

mantener dotfiles sincronizados

hacer backup frecuente

evitar editar configs fuera del repositorio

usar ramas Git para pruebas



---

Flujo recomendado

Inicio diario

Abrir Termux
→ tmux
→ zsh
→ proyectos
→ git
→ desarrollo


---

Recuperación completa

Clonar dotfiles

git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git


---

Ejecutar instalación

bash scripts/install.sh


---

Objetivo del entorno

Tener un sistema:

reproducible

portátil

modular

rápido

mantenible

profesional

funcional desde Android

