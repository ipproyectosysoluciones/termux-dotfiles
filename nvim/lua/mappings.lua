-- Mapeos personalizados de teclas
-- Extiende los mapeos por defecto de NvChad

require "nvchad.mappings"

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================
-- Mapeos generales
-- ============================================

-- Modo comando
map("n", ";", ":", { desc = "Entrar en modo comando" })

-- Escape rápido en modo inserción
map("i", "jk", "<ESC>", { desc = "Salir de modo inserción" })

-- Mover líneas en modo normal
map("n", "<A-j>", "<Esc>:m .+1<CR>==", { desc = "Mover línea abajo" })
map("n", "<A-k>", "<Esc>:m .-2<CR>==", { desc = "Mover línea arriba" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==", { desc = "Mover línea abajo" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==", { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })

-- Moverse entre buffers
map("n", "<S-h>", "<C-w>h", { desc = "Ir al split izquierdo" })
map("n", "<S-l>", "<C-w>l", { desc = "Ir al split derecho" })
map("n", "<S-j>", "<C-w>j", { desc = "Ir al split inferior" })
map("n", "<S-k>", "<C-w>k", { desc = "Ir al split superior" })

-- ============================================
-- Formateo y herramientas
-- ============================================

-- Formatear con Prettier (conform.nvim)
map("n", "<leader>fm", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Formatear con Prettier" })

-- Formatear script Bash con shfmt
map("n", "<leader>fs", ":%!shfmt<CR>", { desc = "Formatear Bash con shfmt" })

-- Formatear SQL con psqlformat
map("n", "<leader>fq", ":w<CR>:%!psqlformat --spaces=2 %<CR>", { desc = "Formatear SQL" })

-- ============================================
-- Navegación y búsqueda
-- ============================================

-- Navegar entre buffers
map("n", "<S-l>", ":bnext<CR>", { desc = "Siguiente buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Buffer anterior" })

-- Buscar archivos con Telescope (si está disponible)
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Buscar archivos" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Buscar texto" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buscar buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Buscar ayuda" })

-- ============================================
-- Ventanas y splits
-- ============================================

-- Crear splits
map("n", "<leader>sv", "<C-w>v", { desc = "Dividir verticalmente" })
map("n", "<leader>sh", "<C-w>s", { desc = "Dividir horizontalmente" })

-- Cerrar splits
map("n", "<leader>sq", ":close<CR>", { desc = "Cerrar split" })
map("n", "<leader>so", ":only<CR>", { desc = "Cerrar otros splits" })

-- ============================================
-- Diagnósticos y LSP
-- ============================================

-- Navegar entre diagnósticos
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnóstico anterior" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnóstico siguiente" })

-- Mostrar diagnósticos en floating window
-- T3.4: <leader>e moved to NvimTreeToggle (file tree is invoked 5-10x
-- more often than the diagnostic float). Diagnostic float moves to
-- <leader>de (fits the existing <leader>d* diagnostic prefix group).
map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Mostrar diagnóstico" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree (nvim-tree)" })

-- T3.3: toggleterm — bottom split with $SHELL access
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Mostrar línea de diagnósticos
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Lista de diagnósticos" })

-- ============================================
-- Portapapeles
-- ============================================

-- Copiar todo el archivo al portapapeles
map("n", "<leader>y", ":%yank<CR>", { desc = "Copiar todo al portapapeles" })

-- ============================================
-- Utilidades
-- ============================================

-- Recargar configuración
map("n", "<leader>sr", ":source $MYVIMRC<CR>", { desc = "Recargar configuración" })

-- Limpiar resaltado de búsqueda
map("n", "<leader>ch", ":nohlsearch<CR>", { desc = "Limpiar resaltado" })

-- Toggle wrap
map("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle wrap" })

-- Toggle números relativos
map("n", "<leader>tn", ":set relativenumber!<CR>", { desc = "Toggle números relativos" })

-- ============================================
-- IA y asistentes
-- ============================================

-- T2.3 — CodeCompanion in-editor (cmd-triggered; lazy-loaded)

map("n", "<leader>aa", "<cmd>CodeCompanionChat<CR>", { desc = "AI: CodeCompanion chat" })
map("v", "<leader>aa", "<cmd>CodeCompanionChat<CR>", { desc = "AI: CodeCompanion chat (visual)" })
map("n", "<leader>ai", "<cmd>CodeCompanion<CR>", { desc = "AI: CodeCompanion inline" })
map("v", "<leader>ai", "<cmd>CodeCompanion<CR>", { desc = "AI: CodeCompanion inline (visual)" })
map("n", "<leader>at", "<cmd>CodeCompanionChat -t<CR>", { desc = "AI: CodeCompanion toggle chat" })
map("n", "<leader>am", "<cmd>CodeCompanionActions<CR>", { desc = "AI: CodeCompanion actions" })
map("n", "<leader>as", "<cmd>CodeCompanionChat -s<CR>", { desc = "AI: CodeCompanion switch adapter" })

-- T2.4 / T2.5 — Terminal-spawn CLI splits reusing scripts/ai/providers/*.sh
--
-- Each binding opens a horizontal split and runs the named provider
-- script via vim.fn.termopen. Env vars follow the design.md contract:
--   AI_WORKSPACE = cwd
--   AI_PROJECT   = AI_PROJECT or "default"
--   AI_AGENT     = AI_AGENT   or "generic-agent"
--   AI_SKILL     = AI_SKILL   or "generic-skill"
--
-- Mistral lives at <leader>gm (NOT <leader>am — that is CodeCompanion's
-- actions). The T1.2 collision is resolved here per design.md.

local DOTFILES = vim.env.DOTFILES or vim.fn.expand("~/dotfiles")

local function ai_split(provider, script_rel)
  return function()
    local script = DOTFILES .. "/scripts/ai/providers/" .. script_rel
    vim.cmd("split")
    local job = vim.fn.termopen({
      "bash",
      vim.fn.fnamemodify(script, ":p"),
    }, {
      env = vim.tbl_extend("force", vim.fn.environ(), {
        AI_WORKSPACE = vim.fn.getcwd(),
        AI_PROJECT = vim.env.AI_PROJECT or "default",
        AI_AGENT = vim.env.AI_AGENT or "generic-agent",
        AI_SKILL = vim.env.AI_SKILL or "generic-skill",
      }),
    })
    if job == 0 then
      vim.notify(
        "[ai] " .. provider .. " CLI missing — split opened but shell returned 0",
        vim.log.levels.WARN
      )
    end
  end
end

map("n", "<leader>ag", ai_split("gemini", "gemini.sh"), { desc = "AI: gemini CLI split" })
map("n", "<leader>ac", ai_split("claude", "claude.sh"), { desc = "AI: claude CLI split" })
map("n", "<leader>ao", ai_split("opencode", "opencode.sh"), { desc = "AI: opencode CLI split" })
map("n", "<leader>gm", ai_split("mistral", "mistral.sh"), { desc = "AI: mistral CLI split" })
map("n", "<leader>gg", ai_split("gentle", "gentle.sh"), { desc = "AI: gentle CLI split" })

-- ============================================
-- Devtools MEAN/MERN (Phase 3)
-- ============================================

-- T3.5: vim-dadbod — database UI (Mongo, Postgres, MySQL, SQLite, etc.)
map("n", "<leader>db", "<cmd>DBUIToggle<CR>", { desc = "Database UI (vim-dadbod)" })
