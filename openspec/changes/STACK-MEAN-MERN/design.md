# Design: STACK-MEAN-MERN

**Target runtime**: Termux + proot-distro Debian en **dispositivo remoto** (`ssh phone-ai -p 8022`)
**NO** modificar configuración local del equipo de desarrollo.

---

## Architecture Decisions

### Decision: Separar shared vs stack-specific skills

**Choice**: node-express-api y mongoose-schema son skills compartidos framework-agnostic; mean-stack y mern-stack son composites que los referencian.

**Rationale**: Un dev trabajando en MEAN o MERN obtiene los mismos patrones Express — solo cambia la integración frontend.

### Decision: Skills existentes referenciados, no duplicados

**Choice**: mean-stack referencia `scope-rule-architect-angular`; mern-stack referencia `react-19` y `vite`.

**Rationale**: Single source of truth. Actualizaciones a skills existentes propagan automáticamente.

### Decision: Agentes OpenCode como subagents, no standalone

**Choice**: mean-developer y mern-developer se definen en `opencode.json` del remoto como `mode: subagent`, cargando skills vía `skill` tool.

**Rationale**: Coincide con el patrón existente de OpenCode (sdd-apply, sdd-verify, jd-fix-agent, etc.).

### Decision: Scaffolding via scripts del repo, no skills

**Choice**: Los scripts generadores de proyectos (`scripts/ai/new-mean.sh`, `scripts/ai/new-mern.sh`) viven en el repo y se sincronizan vía git pull en el remoto.

**Rationale**: El scaffolding es una acción concreta (crear archivos, instalar deps), no una guía conceptual. Los skills guían al AI *durante* el desarrollo del proyecto ya creado.

### Decision: Tests de proyecto se generan dentro del proyecto scaffolded

**Choice**: Cada proyecto MEAN/MERN generado incluye su propia infraestructura de tests (unit, integration, e2e), husky y conventional commits.

**Rationale**: Cada proyecto es autónomo. El dotfiles repo solo测试 los scripts de scaffolding y los skills.

---

## File Layout

### En el repo (se sincroniza vía git al remoto)

```
scripts/ai/
├── templates/
│   ├── mean/                     # MEAN scaffolding template
│   │   ├── backend/
│   │   │   ├── package.json
│   │   │   ├── tsconfig.json
│   │   │   └── src/
│   │   ├── frontend/
│   │   │   └── (Angular project via ng new flags)
│   │   └── shared/
│   │       └── types/
│   └── mern/                     # MERN scaffolding template
│       ├── backend/
│       │   ├── package.json
│       │   ├── tsconfig.json
│       │   └── src/
│       ├── frontend/
│       │   └── (React+Vite via create-vite flags)
│       └── shared/
│           └── types/
├── new-mean.sh                   # CLI: genera proyecto MEAN
├── new-mern.sh                   # CLI: genera proyecto MERN
└── menu.sh                       # Actualizado con entrada "New Project"

tests/
├── skills/                       # Test de skills (en el repo)
│   ├── node-express-api.bats
│   ├── mongoose-schema.bats
│   ├── mean-stack.bats
│   └── mern-stack.bats
└── scaffolding/                  # Tests de scaffolding (en el repo)
    ├── new-mean.bats
    └── new-mern.bats
```

### En el remoto (solo existe en phone-ai)

```
~/.config/opencode/skills/
├── node-express-api/
│   └── SKILL.md
├── mongoose-schema/
│   └── SKILL.md
├── mean-stack/
│   └── SKILL.md
└── mern-stack/
    └── SKILL.md

~/.config/opencode/opencode.json   # Agregar agent entries
```

---

## Per-Deliverable Design

### 1. node-express-api Skill (~200 lines)
**Ubicación**: `~/.config/opencode/skills/node-express-api/SKILL.md` (en remoto)
**Focus**: Express.js patterns independent of frontend choice.
**Secciones**:
1. Router pattern (express.Router)
2. Middleware chain (error handler, auth, validation, CORS, rate-limit)
3. REST conventions (status codes, JSON, pagination, filtering)
4. JWT auth middleware skeleton
5. Async wrapper (express-async-errors)
6. Env config (dotenv + validation)
**References**: typescript, api-design-principles

### 2. mongoose-schema Skill (~150 lines)
**Ubicación**: `~/.config/opencode/skills/mongoose-schema/SKILL.md` (en remoto)
**Focus**: MongoDB/Mongoose patterns.
**Secciones**:
1. Schema definition (types, timestamps, versionKey)
2. Validation (built-in, custom)
3. Indexes (compound, text, 2dsphere)
4. Hooks (pre/post save, remove)
5. Query patterns (pagination, population, aggregation)
6. Soft delete pattern
**References**: database-schema-design

### 3. mean-stack Skill (~250 lines)
**Ubicación**: `~/.config/opencode/skills/mean-stack/SKILL.md` (en remoto)
**Focus**: MEAN scaffolding + Angular-Express integration.
**Secciones**:
1. Project structure (Angular + Express + shared models)
2. Angular HttpClient + JWT interceptor
3. Express API integration (from node-express-api)
4. Auth flow (login → Angular auth service → guards → refresh)
5. CORS + proxy config (proxy.conf.json)
**References**: scope-rule-architect-angular, node-express-api, mongoose-schema, typescript

### 4. mern-stack Skill (~250 lines)
**Ubicación**: `~/.config/opencode/skills/mern-stack/SKILL.md` (en remoto)
**Focus**: MERN scaffolding + React-Express integration.
**Secciones**:
1. Project structure (React/Vite + Express + shared models)
2. fetch/axios patterns + auth headers
3. Express API integration (from node-express-api)
4. Auth flow (login → React context → protected routes → refresh)
5. Vite proxy config
**References**: react-19, vite, node-express-api, mongoose-schema, typescript

### 5. mean-developer Agent (OpenCode subagent)
**Ubicación**: `~/.config/opencode/opencode.json` → `agent.mean-developer` (en remoto)
**Mode**: `subagent`, **Hidden**: `true`
**Loads skills via**: `skill` tool reference in prompt
**Skills**: node-express-api, mongoose-schema, mean-stack, scope-rule-architect-angular, typescript
**Role**: MEAN full-stack specialist
**Scope**: IN → MEAN project setup, Angular-Express integration, Mongoose schemas
           OUT → React (use mern-developer), NestJS, SQL

### 6. mern-developer Agent (OpenCode subagent)
**Ubicación**: `~/.config/opencode/opencode.json` → `agent.mern-developer` (en remoto)
**Mode**: `subagent`, **Hidden**: `true`
**Skills**: node-express-api, mongoose-schema, mern-stack, react-19, vite, typescript
**Role**: MERN full-stack specialist
**Scope**: IN → MERN project setup, React-Express integration, Mongoose schemas
           OUT → Angular (use mean-developer), NestJS, SQL

### 7. new-mean.sh Script (~300 lines)
**Ubicación**: `scripts/ai/new-mean.sh` (en repo)
**Qué hace**: Scaffolding interactivo de proyecto MEAN.
**Flujo**:
1. Pregunta nombre del proyecto
2. Pregunta alcance: full-stack | frontend-only | backend-only
3. Pregunta Docker: yes/no
4. Crea estructura de directorios:
   ```
   {project}/
   ├── backend/
   │   ├── src/
   │   │   ├── controllers/
   │   │   ├── models/
   │   │   ├── routes/
   │   │   ├── middleware/
   │   │   ├── config/
   │   │   └── index.ts
   │   ├── tests/
   │   │   ├── unit/
   │   │   ├── integration/
   │   │   └── e2e/
   │   ├── package.json
   │   ├── tsconfig.json
   │   ├── jest.config.ts
   │   ├── Dockerfile (if yes)
   │   └── .env.example
   ├── frontend/ (if full-stack or frontend-only)
   │   ├── src/
   │   │   ├── app/
   │   │   ├── components/
   │   │   ├── services/
   │   │   ├── guards/
   │   │   └── interceptors/
   │   ├── tests/
   │   │   ├── unit/
   │   │   ├── integration/
   │   │   └── e2e/
   │   ├── package.json
   │   ├── tsconfig.json
   │   ├── Dockerfile (if yes)
   │   └── proxy.conf.json
   ├── docker-compose.yml (if yes)
   ├── .husky/
   │   ├── pre-commit (lint-staged)
   │   ├── commit-msg (commitlint)
   │   └── pre-push (test)
   ├── commitlint.config.ts
   ├── .gitignore
   └── README.md
   ```
5. Inicializa git + husky
6. Instala dependencias (npm install en cada subproyecto)
7. Crea commit inicial con conventional commit

### 8. new-mern.sh Script (~300 lines)
**Ubicación**: `scripts/ai/new-mern.sh` (en repo)
**Mismo flujo que new-mean.sh** pero con:
- Frontend React + Vite + Vitest
- React Testing Library + Playwright para tests
- Misma estructura de backend (comparte patrones)

### 9. Menu Integration (~20 lines)
**Ubicación**: `scripts/ai/menu.sh` (en repo)
**Cambio**: Agregar entrada "New Project" con submenú:
```
"New Project"
  ├── MEAN Full Stack
  ├── MERN Full Stack
  ├── MEAN Frontend Only
  ├── MERN Frontend Only
  ├── MEAN Backend Only
  └── MERN Backend Only
```

### 10. Proyecto scaffolded: estructura de tests

Cada proyecto generado incluye:

| Tipo | Backend | Frontend |
|------|---------|----------|
| Unit | Jest + Supertest | Vitest + Testing Library |
| Integration | Jest + MongoDB memory server | Vitest + MSW |
| E2E | — | Playwright |
| Coverage | jest --coverage | vitest --coverage |

**Husky hooks**:
- `pre-commit`: lint-staged (eslint + prettier)
- `commit-msg`: commitlint (conventional commits)
- `pre-push`: npm test

---

## Testing Strategy (strict_tdd)

### Tests en el repo (se ejecutan en remoto vía SSH)

**Skills tests** (`tests/skills/`):
```bash
ssh phone-ai -p 8022 bats ~/dotfiles/tests/skills/{skill}.bats
```
Verifican: archivo existe, frontmatter válido, trigger words, cross-references.

**Scaffolding tests** (`tests/scaffolding/`):
```bash
ssh phone-ai -p 8022 bats ~/dotfiles/tests/scaffolding/{script}.bats
```
Verifican: script ejecutable, menú actualizado, estructura generada.

### Tests dentro del proyecto scaffolded
Se generan con el proyecto y corren con `npm test` dentro del proyecto.

---

## Cross-Cutting Concerns

| Concern | Approach |
|---------|----------|
| Target platform | Solo Termux + proot-distro Debian en remoto |
| OpenCode agents | `mode: subagent`, `hidden: true`, definidos en `opencode.json` del remoto |
| Skills instalación | `scp` o `git sync` al remoto, en `~/.config/opencode/skills/` |
| Overlap skills existentes | Referencias explícitas, no duplicación |
| strict_tdd | Bats tests en repo para skills y scaffolding |
| Review budget | Cada script ~300 lines, skills ~200-250, agents ~50 |
| Rollback scaffolding | `rm -rf {project}` + reinstall deps |

---

## Phasing

### Fase 1: Shared Skills (aplicar en remoto)
- Crear `node-express-api/SKILL.md`
- Crear `mongoose-schema/SKILL.md`
- Tests en `tests/skills/`
- Instalar en remoto

### Fase 2: Stack Skills + Agents (aplicar en remoto)
- Crear `mean-stack/SKILL.md`
- Crear `mern-stack/SKILL.md`
- Definir `mean-developer` y `mern-developer` en `opencode.json`
- Tests en `tests/skills/`
- Instalar en remoto

### Fase 3: Scaffolding + Menu (repo, sync a remoto)
- Crear `scripts/ai/new-mean.sh`
- Crear `scripts/ai/new-mern.sh`
- Actualizar `scripts/ai/menu.sh`
- Tests en `tests/scaffolding/`
- Push + pull en remoto
