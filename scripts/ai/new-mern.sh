#!/data/data/com.termux/files/usr/bin/bash

# =============================================================================
# new-mern.sh - MERN Stack Scaffolding Script
# =============================================================================
# Creates a new MERN (MongoDB, Express, React, Node.js) project with:
# - Backend: Express + TypeScript + Jest + Supertest
# - Frontend: React + Vite + Vitest + Playwright
# - DevOps: Docker, Husky, Commitlint, lint-staged
# - Git initialized with conventional commits
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load UI helpers if available
if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
fi

# =============================================================================
# DETECT INTERACTIVE TOOL (gum vs fallback)
# =============================================================================

detect_input_tool() {
    if command -v gum > /dev/null 2>&1; then
        echo "gum"
    else
        echo "read"
    fi
}

detect_choose_tool() {
    if command -v gum > /dev/null 2>&1; then
        echo "gum"
    else
        echo "select"
    fi
}

# =============================================================================
# COLORS (for fallback when gum unavailable)
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# PARSE ARGUMENTS (optional flags for automation)
# =============================================================================

parse_args() {
    PROJECT_NAME="${PROJECT_NAME:-}"
    SCOPE="${SCOPE:-full-stack}"
    WITH_DOCKER="${WITH_DOCKER:-false}"
    AUTO_MODE="${AUTO_MODE:-false}"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --scope)
                SCOPE="$2"
                shift 2
                ;;
            --docker)
                WITH_DOCKER="$2"
                shift 2
                ;;
            --auto)
                AUTO_MODE="true"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# ASK PROJECT NAME
# =============================================================================

ask_project_name() {
    local INPUT_TOOL=$(detect_input_tool)

    if [ -n "$PROJECT_NAME" ]; then
        log_info "Using provided project name: $PROJECT_NAME"
        return 0
    fi

    if [ "$INPUT_TOOL" = "gum" ]; then
        echo "Enter project name:"
        PROJECT_NAME=$(gum input --placeholder "my-mern-project" --value "$PROJECT_NAME")
    else
        read -p "Enter project name: " PROJECT_NAME
    fi

    if [ -z "$PROJECT_NAME" ]; then
        log_error "Project name cannot be empty"
        exit 1
    fi

    # Sanitize project name (lowercase, no spaces)
    PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -d '[:punct:]')
}

# =============================================================================
# ASK SCOPE
# =============================================================================

ask_scope() {
    local CHOOSE_TOOL=$(detect_choose_tool)

    if [ "$AUTO_MODE" = "true" ]; then
        log_info "Auto mode: using scope $SCOPE"
        return 0
    fi

    if [ "$CHOOSE_TOOL" = "gum" ]; then
        SCOPE=$(gum choose "full-stack" "frontend-only" "backend-only" --header "Select project scope")
    else
        echo "Select project scope:"
        select opt in "full-stack" "frontend-only" "backend-only"; do
            SCOPE="$opt"
            break
        done
    fi

    log_info "Selected scope: $SCOPE"
}

# =============================================================================
# ASK DOCKER
# =============================================================================

ask_docker() {
    local INPUT_TOOL=$(detect_input_tool)

    if [ "$AUTO_MODE" = "true" ]; then
        log_info "Auto mode: docker=$WITH_DOCKER"
        return 0
    fi

    if [ "$INPUT_TOOL" = "gum" ]; then
        if gum confirm "Include Docker support?"; then
            WITH_DOCKER="true"
        else
            WITH_DOCKER="false"
        fi
    else
        read -p "Include Docker support? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            WITH_DOCKER="true"
        else
            WITH_DOCKER="false"
        fi
    fi

    log_info "Docker support: $WITH_DOCKER"
}

# =============================================================================
# VALIDATE SCOPE
# =============================================================================

validate_scope() {
    case "$SCOPE" in
        full-stack|frontend-only|backend-only)
            return 0
            ;;
        *)
            log_error "Invalid scope: $SCOPE"
            log_error "Valid options: full-stack, frontend-only, backend-only"
            exit 1
            ;;
    esac
}

# =============================================================================
# CREATE DIRECTORY STRUCTURE
# =============================================================================

create_directories() {
    log_info "Creating directory structure..."

    mkdir -p "$PROJECT_DIR/backend/src/controllers"
    mkdir -p "$PROJECT_DIR/backend/src/models"
    mkdir -p "$PROJECT_DIR/backend/src/routes"
    mkdir -p "$PROJECT_DIR/backend/src/middleware"
    mkdir -p "$PROJECT_DIR/backend/src/config"
    mkdir -p "$PROJECT_DIR/backend/tests/unit"
    mkdir -p "$PROJECT_DIR/backend/tests/integration"

    if [ "$SCOPE" != "backend-only" ]; then
        mkdir -p "$PROJECT_DIR/frontend/src/app"
        mkdir -p "$PROJECT_DIR/frontend/src/components"
        mkdir -p "$PROJECT_DIR/frontend/src/services"
        mkdir -p "$PROJECT_DIR/frontend/src/hooks"
        mkdir -p "$PROJECT_DIR/frontend/src/types"
        mkdir -p "$PROJECT_DIR/frontend/tests/unit"
        mkdir -p "$PROJECT_DIR/frontend/tests/e2e"
    fi

    mkdir -p "$PROJECT_DIR/.husky"

    log_success "Directory structure created"
}

# =============================================================================
# CREATE BACKEND PACKAGE.JSON
# =============================================================================

create_backend_package_json() {
    log_info "Creating backend/package.json..."

    cat > "$PROJECT_DIR/backend/package.json" << 'EOF'
{
  "name": "PROJECT_NAME-backend",
  "version": "1.0.0",
  "description": "MERN stack backend",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "devDependencies": {
    "typescript": "^5.4.0",
    "tsx": "^4.7.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.2",
    "@types/jest": "^29.5.12",
    "@types/node": "^20.11.0",
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "supertest": "^7.0.0",
    "@types/supertest": "^6.0.2",
    "eslint": "^9.0.0",
    "prettier": "^3.2.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.2.0",
    "@commitlint/cli": "^19.0.0",
    "@commitlint/config-conventional": "^19.0.0"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.4.0",
    "mongoose": "^8.2.0",
    "jsonwebtoken": "^9.0.2",
    "express-async-errors": "^3.1.1"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
EOF

    # Replace PROJECT_NAME placeholder
    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/backend/package.json"
}

# =============================================================================
# CREATE BACKEND TSCONFIG.JSON
# =============================================================================

create_backend_tsconfig() {
    log_info "Creating backend/tsconfig.json..."

    cat > "$PROJECT_DIR/backend/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF
}

# =============================================================================
# CREATE BACKEND JEST CONFIG
# =============================================================================

create_backend_jest_config() {
    log_info "Creating backend/jest.config.ts..."

    cat > "$PROJECT_DIR/backend/jest.config.ts" << 'EOF'
import type { Config } from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/*.test.ts'],
  collectCoverageFrom: ['src/**/*.ts', '!src/**/*.d.ts'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};

export default config;
EOF
}

# =============================================================================
# CREATE BACKEND INDEX.TS
# =============================================================================

create_backend_index() {
    log_info "Creating backend/src/index.ts..."

    cat > "$PROJECT_DIR/backend/src/index.ts" << 'EOF'
import express from 'express';
import cors from 'cors';
import { config } from 'dotenv';
import 'express-async-errors';

config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes will be added here

// Error handler
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
EOF
}

# =============================================================================
# CREATE BACKEND .ENV.EXAMPLE
# =============================================================================

create_backend_env_example() {
    log_info "Creating backend/.env.example..."

    cat > "$PROJECT_DIR/backend/.env.example" << 'EOF'
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/PROJECT_NAME
JWT_SECRET=your-secret-key-here
EOF

    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/backend/.env.example"
}

# =============================================================================
# CREATE FRONTEND PACKAGE.JSON (MERN - React + Vite)
# =============================================================================

create_frontend_package_json() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/package.json..."

    cat > "$PROJECT_DIR/frontend/package.json" << 'EOF'
{
  "name": "PROJECT_NAME-frontend",
  "version": "1.0.0",
  "description": "MERN stack frontend (React + Vite)",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:watch": "vitest",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "react-router-dom": "^6.22.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.4.0",
    "vite": "^5.2.0",
    "vitest": "^1.4.0",
    "jsdom": "^24.0.0",
    "@testing-library/react": "^14.2.0",
    "@testing-library/jest-dom": "^6.4.0",
    "@playwright/test": "^1.42.0",
    "eslint": "^9.0.0",
    "prettier": "^3.2.0",
    "husky": "^9.0.0",
    "lint-staged": "^15.2.0",
    "@commitlint/cli": "^19.0.0",
    "@commitlint/config-conventional": "^19.0.0"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
EOF

    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/frontend/package.json"
}

# =============================================================================
# CREATE FRONTEND VITE CONFIG
# =============================================================================

create_frontend_vite_config() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/vite.config.ts..."

    cat > "$PROJECT_DIR/frontend/vite.config.ts" << 'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
      },
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },
});
EOF
}

# =============================================================================
# CREATE FRONTEND PROXY CONFIG
# =============================================================================

create_frontend_proxy_config() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/proxy.conf.json..."

    cat > "$PROJECT_DIR/frontend/proxy.conf.json" << 'EOF'
{
  "/api": {
    "target": "http://localhost:3000",
    "secure": false,
    "changeOrigin": true
  }
}
EOF
}

# =============================================================================
# CREATE FRONTEND TYPESCRIPT CONFIG
# =============================================================================

create_frontend_tsconfig() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/tsconfig.json..."

    cat > "$PROJECT_DIR/frontend/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF
}

# =============================================================================
# CREATE FRONTEND INDEX.HTML
# =============================================================================

create_frontend_index_html() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/index.html..."

    cat > "$PROJECT_DIR/frontend/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>MERN App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF
}

# =============================================================================
# CREATE FRONTEND MAIN.TSX
# =============================================================================

create_frontend_main() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/src/main.tsx..."

    mkdir -p "$PROJECT_DIR/frontend/src"

    cat > "$PROJECT_DIR/frontend/src/main.tsx" << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF
}

# =============================================================================
# CREATE FRONTEND APP.TSX
# =============================================================================

create_frontend_app() {
    if [ "$SCOPE" = "backend-only" ]; then
        return 0
    fi

    log_info "Creating frontend/src/App.tsx..."

    cat > "$PROJECT_DIR/frontend/src/App.tsx" << 'EOF'
function App() {
  return (
    <div className="App">
      <header>
        <h1>MERN Stack App</h1>
      </header>
      <main>
        <p>Welcome to your new MERN stack application.</p>
      </main>
    </div>
  );
}

export default App;
EOF
}

# =============================================================================
# SETUP HUSKY
# =============================================================================

setup_husky() {
    log_info "Setting up Husky git hooks..."

    # Create pre-commit hook
    cat > "$PROJECT_DIR/.husky/pre-commit" << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
EOF

    # Create commit-msg hook
    cat > "$PROJECT_DIR/.husky/commit-msg" << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx --no -- commitlint --edit $1
EOF

    # Create pre-push hook
    cat > "$PROJECT_DIR/.husky/pre-push" << 'EOF'
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npm test
EOF

    chmod +x "$PROJECT_DIR/.husky/pre-commit"
    chmod +x "$PROJECT_DIR/.husky/commit-msg"
    chmod +x "$PROJECT_DIR/.husky/pre-push"

    log_success "Husky hooks configured"
}

# =============================================================================
# SETUP COMMITLINT
# =============================================================================

setup_commitlint() {
    log_info "Setting up commitlint..."

    cat > "$PROJECT_DIR/commitlint.config.cjs" << 'EOF'
module.exports = {
  extends: ['@commitlint/config-conventional']
};
EOF

    log_success "Commitlint configured"
}

# =============================================================================
# CREATE DOCKERFILE
# =============================================================================

create_dockerfile() {
    if [ "$WITH_DOCKER" != "true" ]; then
        return 0
    fi

    log_info "Creating Dockerfile..."

    cat > "$PROJECT_DIR/backend/Dockerfile" << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/index.js"]
EOF
}

# =============================================================================
# CREATE DOCKER-COMPOSE
# =============================================================================

create_docker_compose() {
    if [ "$WITH_DOCKER" != "true" ]; then
        return 0
    fi

    log_info "Creating docker-compose.yml..."

    cat > "$PROJECT_DIR/docker-compose.yml" << 'EOF'
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/PROJECT_NAME
    depends_on:
      - mongo
  mongo:
    image: mongo:7
    volumes:
      - mongo_data:/data/db
volumes:
  mongo_data:
EOF

    sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_DIR/docker-compose.yml"
}

# =============================================================================
# CREATE .GITIGNORE
# =============================================================================

create_gitignore() {
    log_info "Creating .gitignore..."

    cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Build
dist/
build/
out/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Test
coverage/
.nyc_output/

# Playwright
test-results/
playwright-report/

# Misc
*.tgz
.cache/
EOF
}

# =============================================================================
# CREATE README
# =============================================================================

create_readme() {
    log_info "Creating README.md..."

    cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT_NAME

MERN Stack project created with new-mern.sh scaffolder.

## Stack

- **Backend**: Node.js + Express + TypeScript + MongoDB (Mongoose)
- **Frontend**: React 18 + Vite + Vitest + Playwright
- **Testing**: Jest (backend), Vitest (frontend unit), Playwright (frontend e2e)
- **DevOps**: Docker, Husky, Commitlint

## Getting Started

### Backend

\`\`\`bash
cd $PROJECT_DIR/backend
npm install
npm run dev
\`\`\`

### Frontend

\`\`\`bash
cd $PROJECT_DIR/frontend
npm install
npm run dev
\`\`\`

### Docker

\`\`\`bash
docker-compose up -d
\`\`\`

## Testing

### Backend
\`\`\`bash
npm test
\`\`\`

### Frontend Unit
\`\`\`bash
npm run test
\`\`\`

### Frontend E2E
\`\`\`bash
npm run test:e2e
\`\`\`

## Conventional Commits

This project uses conventional commits. Run \`git commit\` and follow the format:

- \`feat:\` for new features
- \`fix:\` for bug fixes
- \`docs:\` for documentation
- \`style:\` for formatting
- \`refactor:\` for refactoring
- \`test:\` for tests
- \`chore:\` for maintenance

## Git Hooks

Hooks are managed by Husky:
- **pre-commit**: Runs lint-staged
- **commit-msg**: Validates conventional commit format
- **pre-push**: Runs tests

## License

MIT
EOF
}

# =============================================================================
# INITIALIZE GIT
# =============================================================================

init_git() {
    log_info "Initializing git repository..."

    cd "$PROJECT_DIR"
    git init
    git add .
    git commit -m "feat: initial project scaffold

- MERN stack project structure
- Backend: Express + TypeScript + Jest
- Frontend: React + Vite + Vitest + Playwright
- Husky git hooks configured
- Commitlint with conventional commits
- Docker support included"

    log_success "Git initialized with initial commit"
}

# =============================================================================
# INSTALL DEPENDENCIES
# =============================================================================

install_dependencies() {
    log_info "Installing backend dependencies..."
    cd "$PROJECT_DIR/backend"
    npm install

    if [ "$SCOPE" != "backend-only" ]; then
        log_info "Installing frontend dependencies..."
        cd "$PROJECT_DIR/frontend"
        npm install
    fi

    log_success "Dependencies installed"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    parse_args "$@"

    echo ""
    echo "=============================================="
    echo "  MERN Stack Project Scaffolder"
    echo "=============================================="
    echo ""

    ask_project_name
    ask_scope
    ask_docker
    validate_scope

    # Resolve project directory
    PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
    PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"
    mkdir -p "$PROJECT_DIR"

    echo ""
    log_info "Creating $PROJECT_NAME in $PROJECT_DIR"
    log_info "Scope: $SCOPE, docker: $WITH_DOCKER"
    echo ""

    create_directories
    create_backend_package_json
    create_backend_tsconfig
    create_backend_jest_config
    create_backend_index
    create_backend_env_example

    if [ "$SCOPE" != "backend-only" ]; then
        create_frontend_package_json
        create_frontend_vite_config
        create_frontend_proxy_config
        create_frontend_tsconfig
        create_frontend_index_html
        create_frontend_main
        create_frontend_app
    fi

    setup_husky
    setup_commitlint
    create_dockerfile
    create_docker_compose
    create_gitignore
    create_readme

    echo ""
    log_success "Project scaffolded successfully!"
    echo ""

    init_git

    echo ""
    echo "=============================================="
    echo "  Next Steps"
    echo "=============================================="
    echo ""
    echo "1. cd $PROJECT_DIR"
    echo "2. Review and customize the generated files"
    echo "3. Update backend/.env with your MongoDB URI"
    echo "4. For frontend, install deps: cd frontend && npm install"
    echo ""
    echo "Happy coding!"
    echo "=============================================="
    echo ""
}

main "$@"
