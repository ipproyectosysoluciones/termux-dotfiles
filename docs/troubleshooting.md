# Troubleshooting / Solución de Problemas

## ES

### Problema: Drift en lazy-lock.json (T4.8 deferral)

**Síntoma**: Al hacer `:Lazy sync` o `:Lazy! sync`, lazy.nvim reporta que hay plugins desactualizados y ofrece actualizar los pins.

**Causa**: Cuando PR #4 se mergeó, los nuevos plugins (octo.nvim, auto-session, lazydev.nvim, nvim-treesitter-textobjects) fueron agregados al lockfile con SHAs placeholder porque el sync automático requiere network access en ese momento.

**Solución**:

```bash
# Opción 1: Sync manual (requiere network)
nvim --headless +'Lazy! sync' +q

# Opción 2: Si tenés bats tests y querés verificar
bats tests/nvim/nvim_boot.bats

# El lockfile de producción se actualiza solo cuando hacés :Lazy sync
```

---

### Problema: Bats tests fallan en local

**Síntoma**: `bats --recursive tests/nvim/` muestra fallos en tests que deberían pasar.

**Causa común**: El test `mappings.lua` requiere `nvchad.mappings` que es un módulo instalado por el usuario (no vendored). En headless, el módulo no está disponible.

**Solución**:

```bash
# Usar el workaround del mock para tests headless
nvim --headless \
  --cmd "lua package.preload['nvchad.mappings'] = function() return {} end" \
  +'lua require("mappings")' \
  -c 'q!' 2>&1
```

Los tests en `tests/nvim/user_init.bats` ya usan este workaround. Si agregás nuevos tests que carguen mappings, seguí el mismo patrón.

---

### Problema: LSP no inicia

**Síntoma**: `:LspInfo` muestra "No active LSP" o los servers no conectan.

**Causa común**: Mason no instaló los servers porque la primera invocación de `:MasonInstallAll` falló o no se ejecutó.

**Solución**:

```bash
# 1. Verificar que Mason está disponible
nvim +Mason

# 2. Ejecutar instalación de servers
nvim --headless +'MasonInstallAll' +q

# 3. Verificar installation
nvim +Mason +'lua print(vim.inspect(require("mason-registry").get_installed_package_names()))' +q
```

Los servers asegurados en `ensure_installed`: `angularls`, `ts_ls`, `lua_ls`, `vimls`, `bashls`, `jsonls`, `html`, `cssls`, `emmet_ls`, `tailwindcss`, `eslint`, `biome` (si `BIOME_ENABLED=1`).

---

### Problema: API key no reconocida por CodeCompanion

**Síntoma**: CodeCompanion carga pero no responde o dice "No API key found".

**Causa**: La variable de entorno no está exportada en la sesión de Neovim.

**Solución**:

```bash
# Verificar que la variable existe en el entorno de Neovim
nvim --headless -c 'lua print(vim.env.GEMINI_API_KEY or "NOT SET")' -c 'q!'

# Si dice NOT SET, agregarla a ~/.bashrc o equivalente
export GEMINI_API_KEY="tu-key"
source ~/.bashrc

# Reiniciar Neovim
```

---

### Problema: `gh` no está en PATH (octo.nvim)

**Síntoma**: `<leader>op` muestra warn "[octo] gh CLI not on PATH — install gh or set PATH".

**Causa**: octo.nvim usa `has_octo()` que verifica `vim.fn.executable("gh") == 1`. Si `gh` no está instalado o no está en PATH, el plugin está deshabilitado.

**Solución**:

```bash
# Opción 1: Instalar gh
apt install gh

# Opción 2: Si ya está instalado, verificar PATH
which gh

# Opción 3: Agregar al PATH temporalmente
export PATH="$PATH:/ruta/a/gh"
```

octo.nvim funciona sin `gh` — solo las funciones de GitHub (PR list, issue list, review) están deshabilitadas. El resto de Neovim sigue funcionando normalmente.

---

### Problema: Mason install falla por network

**Síntoma**: `:MasonInstallAll` o `:MasonInstall <pkg>` falla con timeout o connection error.

**Causa**: No hay accesso a la red desde proot-debian en Termux.

**Solución**:

```bash
# Opción 1: Instalar packages manualmente y deshabilitar Mason auto-install
# En nvim/lua/plugins/lsp/init.lua, comentar ensure_installed temporalmente

# Opción 2: Usar el mirror de Brew si está disponible
# Los packages de Mason también están en Brew
brew install golang  # ejemplo

# Opción 3: Tests que requieren network se skippean automáticamente
# Los tests en tests/nvim/ usan `nc -z 8.8.8.8 53` como precheck
bats tests/nvim/mason_lsp.bats
# → skipped si no hay network
```

---

### Problema: lazy-lock.json tiene pins desactualizados después de sync

**Síntoma**: Después de `:Lazy! sync`, el lockfile tiene commits diferentes a los que había antes.

**Causa**: Normal. `:Lazy! sync` resuelve los SHAs más recientes de cada plugin (si hay actualizaciones menores). Los pins "correctos" son los que tenías antes del sync.

**Solución**:

```bash
# Si querés mantener los pins anteriores (recomendado para estabilidad)
git checkout nvim/lazy-lock.json

# Si querés aceptar los nuevos pins
git add nvim/lazy-lock.json
git commit -m "chore(nvim): update lazy-lock.json pins"
```

---

## EN

### Problem: lazy-lock.json drift (T4.8 deferral)

**Symptom**: Running `:Lazy sync` or `:Lazy! sync` reports that plugins are outdated and offers to update pins.

**Cause**: When PR #4 merged, new plugins (octo.nvim, auto-session, lazydev.nvim, nvim-treesitter-textobjects) were added to the lockfile with placeholder SHAs because the auto-sync requires network access at that moment.

**Solution**:

```bash
# Option 1: Manual sync (requires network)
nvim --headless +'Lazy! sync' +q

# Option 2: If you have bats tests and want to verify
bats tests/nvim/nvim_boot.bats

# Production lockfile updates automatically when you do :Lazy sync
```

---

### Problem: Bats tests fail locally

**Symptom**: `bats --recursive tests/nvim/` shows failures in tests that should pass.

**Common cause**: The `mappings.lua` test requires `nvchad.mappings` which is a user-installed module (not vendored). In headless mode, the module is not available.

**Solution**:

```bash
# Use the mock workaround for headless tests
nvim --headless \
  --cmd "lua package.preload['nvchad.mappings'] = function() return {} end" \
  +'lua require("mappings")' \
  -c 'q!' 2>&1
```

Tests in `tests/nvim/user_init.bats` already use this workaround. If you add new tests that load mappings, follow the same pattern.

---

### Problem: LSP doesn't start

**Symptom**: `:LspInfo` shows "No active LSP" or servers don't connect.

**Common cause**: Mason didn't install servers because the first `:MasonInstallAll` invocation failed or wasn't run.

**Solution**:

```bash
# 1. Verify Mason is available
nvim +Mason

# 2. Run server installation
nvim --headless +'MasonInstallAll' +q

# 3. Verify installation
nvim +Mason +'lua print(vim.inspect(require("mason-registry").get_installed_package_names()))' +q
```

Servers in `ensure_installed`: `angularls`, `ts_ls`, `lua_ls`, `vimls`, `bashls`, `jsonls`, `html`, `cssls`, `emmet_ls`, `tailwindcss`, `eslint`, `biome` (if `BIOME_ENABLED=1`).

---

### Problem: API key not recognized by CodeCompanion

**Symptom**: CodeCompanion loads but doesn't respond or says "No API key found".

**Cause**: The environment variable is not exported in the Neovim session.

**Solution**:

```bash
# Verify the variable exists in Neovim's environment
nvim --headless -c 'lua print(vim.env.GEMINI_API_KEY or "NOT SET")' -c 'q!'

# If it says NOT SET, add it to ~/.bashrc or equivalent
export GEMINI_API_KEY="your-key"
source ~/.bashrc

# Restart Neovim
```

---

### Problem: `gh` not on PATH (octo.nvim)

**Symptom**: `<leader>op` shows warn "[octo] gh CLI not on PATH — install gh or set PATH".

**Cause**: octo.nvim uses `has_octo()` which checks `vim.fn.executable("gh") == 1`. If `gh` is not installed or not on PATH, the plugin is disabled.

**Solution**:

```bash
# Option 1: Install gh
apt install gh

# Option 2: If already installed, verify PATH
which gh

# Option 3: Add to PATH temporarily
export PATH="$PATH:/path/to/gh"
```

octo.nvim works without `gh` — only GitHub functions (PR list, issue list, review) are disabled. The rest of Neovim continues to work normally.

---

### Problem: Mason install fails due to network

**Symptom**: `:MasonInstallAll` or `:MasonInstall <pkg>` fails with timeout or connection error.

**Cause**: No network access from proot-debian in Termux.

**Solution**:

```bash
# Option 1: Install packages manually and disable Mason auto-install temporarily
# In nvim/lua/plugins/lsp/init.lua, comment out ensure_installed temporarily

# Option 2: Use Brew mirror if available
brew install golang  # example

# Option 3: Tests that require network are skipped automatically
# Tests in tests/nvim/ use `nc -z 8.8.8.8 53` as precheck
bats tests/nvim/mason_lsp.bats
# → skipped if no network
```

---

### Problem: lazy-lock.json has outdated pins after sync

**Symptom**: After `:Lazy! sync`, the lockfile has different commits than before.

**Cause**: Normal. `:Lazy! sync` resolves the latest SHAs for each plugin (if there are minor updates). The "correct" pins are the ones you had before the sync.

**Solution**:

```bash
# If you want to keep the previous pins (recommended for stability)
git checkout nvim/lazy-lock.json

# If you want to accept the new pins
git add nvim/lazy-lock.json
git commit -m "chore(nvim): update lazy-lock.json pins"
```