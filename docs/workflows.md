workflows.md

# Workflows

## Filosofía del entorno

El entorno está diseñado para:

- Desarrollo rápido desde Termux
- Gestión centralizada mediante dotfiles
- Flujo reproducible
- Automatización de tareas repetitivas
- Trabajo móvil con Android
- Compatibilidad con Linux y servidores remotos

---

# Flujo diario de trabajo

## Abrir Termux

Al iniciar:

- Zsh carga automáticamente
- Powerlevel10k inicializa el prompt
- ssh-agent se inicia automáticamente
- tmux intenta abrir la sesión `main`

---

# Flujo de proyectos

## Crear proyecto simple

```bash
mkproject api-test

Resultado:

~/Projects/api-test


---

Crear proyecto fullstack

mkdev ecommerce-app

Estructura generada:

backend/
frontend/
docker/
docs/
scripts/
README.md
.gitignore

Además:

Inicializa Git automáticamente

Abre la carpeta lista para trabajar



---

Abrir entorno tmux de proyecto

dev ecommerce-app

Esto:

crea el proyecto si no existe

entra al directorio

abre sesión tmux con el nombre del proyecto



---

Flujo Git

Estado

gs


---

Agregar cambios

ga


---

Commit rápido

gc "se agrega configuracion tmux"


---

Push

gp


---

Pull

gpl


---

Flujo Debian

Entrar a Debian

debian

o:

deb


---

Modo AI / desarrollo aislado

ai

Usa:

proot-distro login debian --shared-tmp

Ideal para:

Python

IA

Docker tooling

Kubernetes CLI

compilación aislada



---

Flujo de navegación

zoxide

Aprende rutas frecuentes automáticamente.

Ejemplo:

z dotfiles

o:

z Projects


---

Flujo tmux

Nueva ventana

PREFIX + c


---

Cambiar ventanas

PREFIX + n
PREFIX + p


---

Dividir panel vertical

PREFIX + -


---

Dividir panel horizontal

PREFIX + \


---

Recargar tmux

PREFIX + r


---

Flujo Neovim

Abrir archivo

nvim archivo.txt


---

Abrir configuración

nvim ~/.config/nvim


---

Flujo de actualización

Actualizar paquetes Termux

update


---

Actualizar plugins tmux

~/.tmux/plugins/tpm/bin/update_plugins all


---

Actualizar dotfiles

cd ~/dotfiles

gpl


---

Flujo de respaldo

Guardar sesión tmux

PREFIX + Ctrl-s


---

Restaurar sesión tmux

PREFIX + Ctrl-r


---

Flujo dotfiles

Estado del repositorio

cd ~/dotfiles

git status


---

Subir cambios

ga

gc "descripcion"

gp


---

Flujo de recuperación rápida

Reinstalar symlinks

~/dotfiles/scripts/core/symlinks.sh


---

Reinstalar plugins

~/dotfiles/scripts/nvim/plugins.sh


---

Reinstalar paquetes

~/dotfiles/scripts/core/packages.sh


---

Instalación completa

~/dotfiles/scripts/install.sh


---

Buenas prácticas

Mantener configuraciones dentro de ~/dotfiles

Nunca editar configs fuera del repositorio

Hacer commit frecuente

Separar cambios grandes por commits

Usar ramas para pruebas

Mantener .gitignore actualizado



---

Estructura recomendada

~/dotfiles
├── docs
├── scripts
├── termux
├── tmux
├── zsh
└── nvim


---

Recuperación en nuevo dispositivo

Clonar repositorio

git clone https://github.com/ipproyectosysoluciones/termux-dotfiles.git


---

Entrar al proyecto

cd termux-dotfiles


---

Ejecutar instalación

bash scripts/install.sh


---

Objetivo final

Tener un entorno:

reproducible

portable

rápido

modular

mantenible

preparado para desarrollo profesional desde Android

