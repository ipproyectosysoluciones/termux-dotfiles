# Homebrew Tap - Guía de Instalación

## Prerequisites

- Debian proot instalado en Android 11+
- Homebrew instalado dentro de Debian proot
- Acceso a internet para descargar paquetes

## Instalación

### 1. Agregar el tap

```bash
brew tap ipproyectosysoluciones/termux-dotfiles
```

### 2. Instalar el paquete

```bash
brew install termux-dotfiles
```

### 3. Ejecutar el script de configuración

Después de la instalación, ejecuta el script de configuración para crear los symlinks:

```bash
termux-dotfiles-setup
```

Este comando:
- Detecta la ruta del Cellar de Homebrew
- Crea el directorio `$HOME/.config/termux-dotfiles/`
- Crea symlinks para: `zsh`, `tmux`, `nvim`, `scripts`, `termux`, `docs`

### 4. Recargar el shell

```bash
exec zsh
```

## Actualización

Para actualizar a una nueva versión:

```bash
brew update
brew upgrade termux-dotfiles
```

Después de actualizar, vuelve a ejecutar el script de configuración:

```bash
termux-dotfiles-setup --force
```

## Desinstalación

### 1. Desinstalar el paquete

```bash
brew uninstall termux-dotfiles
```

### 2. Eliminar el tap (opcional)

```bash
brew untap ipproyectosysoluciones/termux-dotfiles
```

### 3. Eliminar los symlinks

```bash
rm -rf ~/.config/termux-dotfiles
```

## Opciones del Script de Configuración

| Opción | Descripción |
|--------|-------------|
| `--dry-run` | Muestra qué se crearía sin hacer cambios |
| `--force` | Reemplaza symlinks existentes |
| `--help` | Muestra la ayuda |

### Ejemplos

```bash
# Ver qué se crearía (sin modificar nada)
termux-dotfiles-setup --dry-run

# Forzar re-creación de todos los symlinks
termux-dotfiles-setup --force

# Mostrar ayuda
termux-dotfiles-setup --help
```

## Solución de Problemas

### "Cellar path not found"

Asegúrate de que Homebrew esté correctamente instalado:

```bash
brew --prefix
```

Si el comando falla, reinstala Homebrew en Debian proot.

### "brew install" falla con error de permisos

En proot, algunos directorios pueden tener restricciones. Prueba:

```bash
sudo brew install termux-dotfiles
```

O verifica los permisos de tu directorio Home.

### Los symlinks no se crean

Verifica que el paquete esté instalado:

```bash
brew list --versions termux-dotfiles
```

Si el paquete está instalado pero los symlinks fallan, ejecuta:

```bash
termux-dotfiles-setup --force
```

## Comparativa con Otros Métodos de Instalación

| Método | Plataforma | Comando | Actualización |
|--------|-----------|---------|---------------|
| curl | Termux nativo | `curl -fsSL ... \| bash` | Manual (git pull) |
| .deb | Termux con pkg | `pkg install termux-dotfiles` | `pkg upgrade` |
| brew tap | Debian proot | `brew tap && brew install` | `brew update && brew upgrade` |

## Arquitectura

El formula de Homebrew instala los dotfiles en el Cellar de Homebrew:

```
$(brew --prefix)/Cellar/termux-dotfiles/{version}/
```

El script de configuración (`termux-dotfiles-setup`) crea symlinks en:

```
$HOME/.config/termux-dotfiles/ -> $(brew --prefix)/Cellar/termux-dotfiles/{version}/
```

Esto permite que los archivos de configuración (zsh, tmux, nvim) estén disponibles en `$HOME/.config/` mientras el paquete permanece aislado en el Cellar.

## Más Información

- [Installation Guide](installation.md) - Guía de instalación general
- [Shell Runtime](shell-runtime.md) - Configuración de zsh
- [tmux Workflows](tmux-workflows.md) - Configuración de tmux