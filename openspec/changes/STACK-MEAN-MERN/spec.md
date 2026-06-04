---
change: STACK-MEAN-MERN
status: draft
---

# SDD Spec: STACK-MEAN-MERN

## Context

Add first-class skill and agent support for MEAN (MongoDB, Express, Angular, Node.js) and MERN (MongoDB, Express, React, Node.js) stack development to the Termux-AI-Astaroth workstation. Shared skills (node-express-api, mongoose-schema) prevent duplication between the two stacks.

---

## Deliverable 1: node-express-api Skill

### Requirements

- Express.js routing patterns with proper HTTP verb mapping
- Middleware composition (error handling, auth, validation, logging)
- REST API standards compliance (status codes, JSON responses, pagination)
- Environment configuration via dotenv with NODE_ENV awareness
- JWT authentication middleware patterns
- CRUD operation patterns for resources
- Error handling with async wrapper utilities
- Request validation patterns (Zod/Joi integration)
- CORS and security headers middleware
- Rate limiting patterns

### Scenarios

#### Scenario: Basic REST endpoint creation
- GIVEN a developer needs to create a resource endpoint
- WHEN they reference this skill
- THEN they get routing patterns with proper HTTP verbs (GET, POST, PUT, DELETE)
- AND status code conventions (200, 201, 400, 404, 500)
- AND JSON response format standards

#### Scenario: Middleware composition
- GIVEN an Express application needs middleware stack
- WHEN they apply this skill
- THEN they can compose error-handling, auth, validation, and logging middleware
- AND understand middleware ordering for proper flow

#### Scenario: JWT auth integration
- GIVEN an API needs authentication
- WHEN they use this skill
- THEN they get JWT verification middleware patterns
- AND token extraction and user attachment to request
- AND protected route guards

#### Scenario: Error handling
- GIVEN async route handlers need consistent error responses
- WHEN they use this skill
- THEN they get async wrapper (express-async-errors pattern)
- AND centralized error handling middleware
- AND proper error serialization for API responses

#### Scenario: Environment configuration
- GIVEN configuration needs environment-specific values
- WHEN they apply this skill
- THEN they get dotenv patterns with NODE_ENV checks
- AND configuration validation at startup
- AND secrets management guidance

### Constraints

- **strict_tdd**: bats tests MUST verify skill trigger matching
- All skills reference existing skills rather than duplicating (typescript, api-design-principles)
- Skill format follows skill-creator pattern with YAML frontmatter
- Token budget: target 180–450 tokens, max 700

### Acceptance Criteria

- [ ] Skill created at `~/.config/opencode/skills/node-express-api/SKILL.md`
- [ ] Frontmatter includes name, description, license, metadata
- [ ] description contains trigger words: "express", "express.js", "api", "middleware", "routing"
- [ ] References `typescript` skill for TypeScript patterns
- [ ] References `api-design-principles` for REST standards
- [ ] bats tests exist at `tests/skills/node-express-api.bats`
- [ ] Tests verify trigger matching for key scenarios

### Test Scenarios

```bash
@test "node-express-api skill triggers on 'express api'"
@test "node-express-api skill triggers on 'express routing'"
@test "node-express-api skill triggers on 'express middleware'"
@test "node-express-api references typescript skill"
@test "node-express-api references api-design-principles"
```

---

## Deliverable 2: mongoose-schema Skill

### Requirements

- Mongoose schema design with proper type definitions
- Validation schemas (built-in and custom validators)
- Mongoose hooks (pre/post save, validation, remove)
- Index strategies (compound, text, 2dsphere)
- Aggregation pipeline patterns
- Population and reference handling
- Discriminator patterns for polymorphic schemas
- timestamps and versionKey configuration
- Soft delete patterns (deletedAt)
- Migration strategies for schema changes

### Scenarios

#### Scenario: Basic schema creation
- GIVEN a developer needs to define a Mongoose model
- WHEN they reference this skill
- THEN they get schema definition patterns with proper types
- AND timestamps configuration
- AND index strategies for query optimization

#### Scenario: Validation patterns
- GIVEN a schema needs field validation
- WHEN they apply this skill
- THEN they get built-in validators (required, enum, match)
- AND custom validator functions
- AND validation error handling

#### Scenario: Hooks and middleware
- GIVEN business logic needs to run on save/update
- WHEN they use this skill
- THEN they get pre/post hook patterns
- AND schema-level methods for business logic
- AND document middleware composition

#### Scenario: Complex relationships
- GIVEN models with references need population
- WHEN they apply this skill
- THEN they get populate() patterns
- AND ref population with select filtering
- AND virtual populate for denormalized relationships

#### Scenario: Aggregation pipelines
- GIVEN analytics or reporting needs complex queries
- WHEN they use this skill
- THEN they get aggregation pipeline stages
- AND $lookup for joins
- AND $group and $facet for analytics

### Constraints

- **strict_tdd**: bats tests MUST verify skill trigger matching
- References `database-schema-design` for generic DB principles
- Focuses on MongoDB-specific patterns (not generic SQL)
- Skill format follows skill-creator pattern with YAML frontmatter

### Acceptance Criteria

- [ ] Skill created at `~/.config/opencode/skills/mongoose-schema/SKILL.md`
- [ ] Frontmatter includes name, description, license, metadata
- [ ] description contains trigger words: "mongoose", "mongodb", "schema", "validation"
- [ ] References `database-schema-design` for general DB principles
- [ ] bats tests exist at `tests/skills/mongoose-schema.bats`
- [ ] Tests verify trigger matching for key scenarios

### Test Scenarios

```bash
@test "mongoose-schema skill triggers on 'mongoose schema'"
@test "mongoose-schema skill triggers on 'mongodb model'"
@test "mongoose-schema skill triggers on 'mongoose validation'"
@test "mongoose-schema references database-schema-design"
```

---

## Deliverable 3: mean-stack Skill

### Requirements

- MEAN project scaffolding (Angular + Express + MongoDB + Node)
- Express API structure with Angular HttpClient integration patterns
- JWT auth flow between Angular and Express
- CORS configuration for Angular dev server proxy
- Shared TypeScript models/interfaces between frontend and backend
- Project structure conventions (feature-based, modular)
- Environment configuration for development and production
- Angular service patterns connecting to Express REST API
- Error handling with HTTP interceptors
- File upload patterns with Multer

### Scenarios

#### Scenario: Project scaffolding
- GIVEN a developer wants to create a MEAN application
- WHEN they reference this skill
- THEN they get folder structure for Angular frontend and Express backend
- AND shared models directory pattern
- AND monorepo structure or separate repo guidance

#### Scenario: Angular-Express integration
- GIVEN Angular frontend needs to communicate with Express backend
- WHEN they apply this skill
- THEN they get HttpClient service patterns
- AND HTTP interceptor for JWT attachment
- AND error handling with catchError

#### Scenario: JWT authentication flow
- GIVEN MEAN stack needs auth
- WHEN they use this skill
- THEN they get login endpoint patterns (Express)
- AND Angular auth service with token storage
- AND route guards in Angular
- AND refresh token handling

#### Scenario: CORS and proxy configuration
- GIVEN Angular dev server needs to proxy API requests
- WHEN they apply this skill
- THEN they get proxy.conf.json patterns
- AND Express CORS configuration for production
- AND credential passthrough settings

### Constraints

- **strict_tdd**: bats tests MUST verify skill trigger matching
- References `scope-rule-architect-angular` for Angular patterns (NOT duplicating)
- References `node-express-api` for Express patterns (NOT duplicating)
- References `mongoose-schema` for MongoDB patterns (NOT duplicating)
- References `typescript` for shared type patterns
- Skill format follows skill-creator pattern with YAML frontmatter

### Acceptance Criteria

- [ ] Skill created at `~/.config/opencode/skills/mean-stack/SKILL.md`
- [ ] Frontmatter includes name, description, license, metadata
- [ ] description contains trigger words: "mean", "mean stack", "angular express"
- [ ] References `scope-rule-architect-angular` skill
- [ ] References `node-express-api` skill
- [ ] References `mongoose-schema` skill
- [ ] bats tests exist at `tests/skills/mean-stack.bats`
- [ ] Tests verify trigger matching for key scenarios

### Test Scenarios

```bash
@test "mean-stack skill triggers on 'mean stack'"
@test "mean-stack skill triggers on 'angular express api'"
@test "mean-stack skill triggers on 'mean project scaffolding'"
@test "mean-stack references angular skill"
@test "mean-stack references node-express-api skill"
@test "mean-stack references mongoose-schema skill"
```

---

## Deliverable 4: mern-stack Skill

### Requirements

- MERN project scaffolding (React + Express + MongoDB + Node)
- Express API structure with React fetch/axios integration patterns
- JWT auth flow between React and Express
- CORS configuration for Vite dev server proxy
- Shared TypeScript models/interfaces between frontend and backend
- Project structure conventions (feature-based, App Router for Next.js or SPA)
- Vite configuration for API proxy
- React Query / SWR patterns for data fetching
- Error handling with error boundaries
- File upload patterns with Multer

### Scenarios

#### Scenario: Project scaffolding
- GIVEN a developer wants to create a MERN application
- WHEN they reference this skill
- THEN they get folder structure for React frontend and Express backend
- AND shared models directory pattern
- AND Vite/Next.js configuration patterns

#### Scenario: React-Express integration
- GIVEN React frontend needs to communicate with Express backend
- WHEN they apply this skill
- THEN they get fetch/axios patterns for API calls
- AND auth header attachment patterns
- AND error handling with try/catch

#### Scenario: JWT authentication flow
- GIVEN MERN stack needs auth
- WHEN they use this skill
- THEN they get login endpoint patterns (Express)
- AND React auth context with token storage
- AND protected route patterns
- AND refresh token handling

#### Scenario: Vite proxy configuration
- GIVEN Vite dev server needs to proxy API requests
- WHEN they apply this skill
- THEN they get vite.config.ts proxy patterns
- AND Express CORS configuration for production
- AND credential passthrough settings

### Constraints

- **strict_tdd**: bats tests MUST verify skill trigger matching
- References `react-19` for React patterns (NOT duplicating)
- References `node-express-api` for Express patterns (NOT duplicating)
- References `mongoose-schema` for MongoDB patterns (NOT duplicating)
- References `typescript` for shared type patterns
- References `vite` for Vite configuration patterns
- Skill format follows skill-creator pattern with YAML frontmatter

### Acceptance Criteria

- [ ] Skill created at `~/.config/opencode/skills/mern-stack/SKILL.md`
- [ ] Frontmatter includes name, description, license, metadata
- [ ] description contains trigger words: "mern", "mern stack", "react express"
- [ ] References `react-19` skill
- [ ] References `node-express-api` skill
- [ ] References `mongoose-schema` skill
- [ ] References `vite` skill
- [ ] bats tests exist at `tests/skills/mern-stack.bats`
- [ ] Tests verify trigger matching for key scenarios

### Test Scenarios

```bash
@test "mern-stack skill triggers on 'mern stack'"
@test "mern-stack skill triggers on 'react express api'"
@test "mern-stack skill triggers on 'mern project scaffolding'"
@test "mern-stack references react-19 skill"
@test "mern-stack references node-express-api skill"
@test "mern-stack references mongoose-schema skill"
@test "mern-stack references vite skill"
```

---

## Deliverable 5: mean-developer Agent

### Requirements

- MEAN stack specialist agent definition
- Role description for full-stack MEAN development
- Skill references: `node-express-api`, `mongoose-schema`, `mean-stack`, `scope-rule-architect-angular`, `typescript`
- Scope: MEAN stack frontend (Angular) and backend (Express + MongoDB)
- Boundary: NOT MERN (React), NOT NestJS, NOT SQL databases
- Agent prompt structure following project conventions

### Scenarios

#### Scenario: MEAN project initialization
- GIVEN user wants to create a MEAN application
- WHEN they invoke mean-developer agent
- THEN agent loads `mean-stack` skill and scaffolding patterns
- AND can guide project structure setup

#### Scenario: Angular-Express integration task
- GIVEN user needs help with Angular service calling Express API
- WHEN they use mean-developer agent
- THEN agent references `node-express-api` and `scope-rule-architect-angular`
- AND provides integration patterns

#### Scenario: MongoDB schema design
- GIVEN user needs Mongoose schema for a new feature
- WHEN they use mean-developer agent
- THEN agent loads `mongoose-schema` skill
- AND provides schema patterns with validation

### Constraints

- **strict_tdd**: bats tests MUST verify agent trigger matching
- Agent definition follows project conventions (refer to existing .claude/agents structure if present)
- Skill references are explicit, not implicit
- Agent scope is bounded to MEAN (not MERN or other stacks)

### Acceptance Criteria

- [ ] Agent created at `.claude/agents/mean-developer.md` (or appropriate location)
- [ ] Frontmatter or header includes agent name, role, skills list
- [ ] References `mean-stack`, `node-express-api`, `mongoose-schema`, `scope-rule-architect-angular`, `typescript` skills
- [ ] bats tests exist at `tests/agents/mean-developer.bats`
- [ ] Tests verify agent triggers on "mean developer", "mean stack developer"
- [ ] Skill registry updated with mean-developer agent entry

### Test Scenarios

```bash
@test "mean-developer agent triggers on 'mean developer'"
@test "mean-developer agent triggers on 'mean stack developer'"
@test "mean-developer agent references mean-stack skill"
@test "mean-developer agent references node-express-api skill"
@test "mean-developer agent references mongoose-schema skill"
```

---

## Deliverable 6: mern-developer Agent

### Requirements

- MERN stack specialist agent definition
- Role description for full-stack MERN development
- Skill references: `node-express-api`, `mongoose-schema`, `mern-stack`, `react-19`, `typescript`, `vite`
- Scope: MERN stack frontend (React) and backend (Express + MongoDB)
- Boundary: NOT MEAN (Angular), NOT NestJS, NOT SQL databases
- Agent prompt structure following project conventions

### Scenarios

#### Scenario: MERN project initialization
- GIVEN user wants to create a MERN application
- WHEN they invoke mern-developer agent
- THEN agent loads `mern-stack` skill and scaffolding patterns
- AND can guide project structure setup with Vite

#### Scenario: React-Express integration task
- GIVEN user needs help with React component calling Express API
- WHEN they use mern-developer agent
- THEN agent references `node-express-api` and `react-19`
- AND provides integration patterns with React Query

#### Scenario: MongoDB schema design
- GIVEN user needs Mongoose schema for a new feature
- WHEN they use mern-developer agent
- THEN agent loads `mongoose-schema` skill
- AND provides schema patterns with validation

### Constraints

- **strict_tdd**: bats tests MUST verify agent trigger matching
- Agent definition follows project conventions
- Skill references are explicit, not implicit
- Agent scope is bounded to MERN (not MEAN or other stacks)

### Acceptance Criteria

- [ ] Agent created at `.claude/agents/mern-developer.md` (or appropriate location)
- [ ] Frontmatter or header includes agent name, role, skills list
- [ ] References `mern-stack`, `node-express-api`, `mongoose-schema`, `react-19`, `typescript`, `vite` skills
- [ ] bats tests exist at `tests/agents/mern-developer.bats`
- [ ] Tests verify agent triggers on "mern developer", "mern stack developer"
- [ ] Skill registry updated with mern-developer agent entry

### Test Scenarios

```bash
@test "mern-developer agent triggers on 'mern developer'"
@test "mern-developer agent triggers on 'mern stack developer'"
@test "mern-developer agent references mern-stack skill"
@test "mern-developer agent references node-express-api skill"
@test "mern-developer agent references mongoose-schema skill"
```

---

## Implementation Order (Work Units)

1. **node-express-api** — Shared Express.js patterns (Phase 1, no frontend dependency)
2. **mongoose-schema** — Shared MongoDB/Mongoose patterns (Phase 1, no frontend dependency)
3. **mean-stack** — MEAN scaffolding (Phase 2, depends on Phase 1)
4. **mern-stack** — MERN scaffolding (Phase 2, depends on Phase 1)
5. **mean-developer** — MEAN agent (Phase 3, depends on Phase 1-2)
6. **mern-developer** — MERN agent (Phase 3, depends on Phase 1-2)

---

## Files to Modify/Create

| File | Action | Description |
|------|--------|-------------|
| `~/.config/opencode/skills/node-express-api/SKILL.md` | Create | Express.js patterns skill |
| `~/.config/opencode/skills/mongoose-schema/SKILL.md` | Create | MongoDB/Mongoose patterns skill |
| `~/.config/opencode/skills/mean-stack/SKILL.md` | Create | MEAN scaffolding skill |
| `~/.config/opencode/skills/mern-stack/SKILL.md` | Create | MERN scaffolding skill |
| `.claude/agents/mean-developer.md` | Create | MEAN specialist agent |
| `.claude/agents/mern-developer.md` | Create | MERN specialist agent |
| `tests/skills/node-express-api.bats` | Create | Skill trigger tests |
| `tests/skills/mongoose-schema.bats` | Create | Skill trigger tests |
| `tests/skills/mean-stack.bats` | Create | Skill trigger tests |
| `tests/skills/mern-stack.bats` | Create | Skill trigger tests |
| `tests/agents/mean-developer.bats` | Create | Agent trigger tests |
| `tests/agents/mern-developer.bats` | Create | Agent trigger tests |
| `.atl/skill-registry.md` | Modify | Index new skills and agents |

---

## Rollback Plan

1. Remove skill directories from `~/.config/opencode/skills/` (node-express-api, mongoose-schema, mean-stack, mern-stack)
2. Remove agent files from `.claude/agents/` (mean-developer.md, mern-developer.md)
3. Remove test files from `tests/skills/` and `tests/agents/`
4. Regenerate `.atl/skill-registry.md` (`gentle-ai skill-registry refresh --force`)
5. No database migrations or runtime state affected — pure skill/agent addition

---

## References

Existing skills to reference (NOT duplicate):
- `scope-rule-architect-angular` — Angular 20+ patterns
- `react-19` — React 19 patterns
- `database-schema-design` — Generic DB schema principles
- `typescript` — TypeScript patterns
- `api-design-principles` — REST API standards
- `vite` — Vite build configuration
- `skill-creator` — SKILL.md creation methodology