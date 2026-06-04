---
name: mern-stack
description: "Trigger: mern stack, MERN full-stack, React Express MongoDB, React JWT auth, React Vite. MERN (MongoDB, Express, React, Node.js) full-stack patterns for project scaffolding, React auth context with JWT, protected routes, Vite proxy setup, and refresh token flow."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# MERN Stack Skill

> Comprehensive patterns for MERN (MongoDB, Express, React, Node.js) full-stack development.

## Trigger Words

`mern stack`, `MERN full-stack`, `React Express MongoDB`, `React JWT auth`, `React Vite`, `React auth context`, `MERN project`, `React proxy`, `React CORS`

## References

- `react-19` — React 19 patterns with Server Components
- `vite` — Vite build tool configuration
- `node-express-api` — Express.js REST API patterns
- `mongoose-schema` — MongoDB/Mongoose schema patterns
- `typescript` — TypeScript best practices

## Project Structure

### MERN Full-Stack Layout

```
my-mern-app/
├── backend/                    # Express API
│   ├── src/
│   │   ├── config/
│   │   │   └── config.ts
│   │   ├── controllers/
│   │   │   ├── auth.controller.ts
│   │   │   └── user.controller.ts
│   │   ├── middleware/
│   │   │   ├── authenticate.ts
│   │   │   └── authorize.ts
│   │   ├── models/
│   │   │   ├── user.model.ts
│   │   │   └── product.model.ts
│   │   ├── routes/
│   │   │   ├── auth.routes.ts
│   │   │   └── user.routes.ts
│   │   ├── services/
│   │   │   └── auth.service.ts
│   │   └── app.ts
│   ├── package.json
│   └── tsconfig.json
├── frontend/                    # React SPA (Vite)
│   ├── src/
│   │   ├── api/               # API client
│   │   │   ├── axios.ts
│   │   │   └── endpoints.ts
│   │   ├── components/         # Shared components
│   │   ├── context/           # React context
│   │   │   └── AuthContext.tsx
│   │   ├── hooks/             # Custom hooks
│   │   │   └── useAuth.ts
│   │   ├── pages/             # Page components
│   │   │   ├── Login.tsx
│   │   │   └── Dashboard.tsx
│   │   ├── routes/            # Route definitions
│   │   │   └── ProtectedRoute.tsx
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── vite.config.ts
│   ├── index.html
│   └── package.json
├── shared/                     # Shared TypeScript types
│   └── types/
│       ├── user.type.ts
│       └── auth.type.ts
└── docker-compose.yml
```

### Vite New Project

```bash
# Create React + TypeScript project with Vite
npm create vite@latest frontend -- --template react-ts

# Install dependencies
cd frontend
npm install axios react-router-dom

# Install dev dependencies
npm install -D vitest @testing-library/react @testing-library/user-event
```

## React Auth Context

### Auth Context Provider

```tsx
// frontend/src/context/AuthContext.tsx
import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import axios from 'axios';

interface User {
  id: string;
  email: string;
  name: string;
  role: string;
}

interface AuthState {
  user: User | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

interface AuthContextType extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const ACCESS_TOKEN_KEY = 'access_token';
const REFRESH_TOKEN_KEY = 'refresh_token';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    accessToken: null,
    isAuthenticated: false,
    isLoading: true
  });

  useEffect(() => {
    // Initialize auth state from localStorage
    const token = localStorage.getItem(ACCESS_TOKEN_KEY);
    const refresh = localStorage.getItem(REFRESH_TOKEN_KEY);

    if (token && refresh) {
      const user = decodeToken(token);
      setState({
        user,
        accessToken: token,
        isAuthenticated: true,
        isLoading: false
      });
    } else {
      setState(prev => ({ ...prev, isLoading: false }));
    }
  }, []);

  const login = async (email: string, password: string) => {
    const response = await axios.post('/api/auth/login', { email, password });
    const { accessToken, refreshToken, user } = response.data;

    localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);

    setState({
      user,
      accessToken,
      isAuthenticated: true,
      isLoading: false
    });
  };

  const logout = () => {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    setState({
      user: null,
      accessToken: null,
      isAuthenticated: false,
      isLoading: false
    });
  };

  const refreshToken = async () => {
    const refresh = localStorage.getItem(REFRESH_TOKEN_KEY);
    if (!refresh) {
      logout();
      return;
    }

    try {
      const response = await axios.post('/api/auth/refresh', { refreshToken: refresh });
      const { accessToken, refreshToken: newRefresh, user } = response.data;

      localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
      localStorage.setItem(REFRESH_TOKEN_KEY, newRefresh);

      setState({
        user,
        accessToken,
        isAuthenticated: true,
        isLoading: false
      });
    } catch (error) {
      logout();
    }
  };

  return (
    <AuthContext.Provider value={{ ...state, login, logout, refreshToken }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// Token decode helper
function decodeToken(token: string): User {
  const payload = token.split('.')[1];
  return JSON.parse(atob(payload));
}
```

### useAuth Hook

```tsx
// frontend/src/hooks/useAuth.ts
import { useContext } from 'react';
import { AuthContext } from '../context/AuthContext';

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// Alternative: custom hook with loading state
export function useAuthState() {
  const { user, isAuthenticated, isLoading } = useAuth();

  return {
    user,
    isAuthenticated,
    isLoading,
    isGuest: !isAuthenticated && !isLoading
  };
}
```

## Axios API Client

### Axios Instance with Interceptors

```typescript
// frontend/src/api/axios.ts
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || '/api';

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request interceptor: add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor: handle 401 and token refresh
let isRefreshing = false;
let refreshPromise: Promise<string> | null = null;

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        // Wait for refresh to complete
        try {
          const newToken = await refreshPromise;
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
          return api(originalRequest);
        } catch (refreshError) {
          return Promise.reject(refreshError);
        }
      }

      originalRequest._retry = true;
      isRefreshing = true;

      refreshPromise = (async () => {
        const refreshToken = localStorage.getItem('refresh_token');
        const response = await axios.post(`${API_URL}/auth/refresh`, { refreshToken });

        const { accessToken, refreshToken: newRefresh } = response.data;
        localStorage.setItem('access_token', accessToken);
        localStorage.setItem('refresh_token', newRefresh);

        return accessToken;
      })();

      try {
        const newToken = await refreshPromise;
        originalRequest.headers.Authorization = `Bearer ${newToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        localStorage.removeItem('access_token');
        localStorage.removeItem('refresh_token');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
        refreshPromise = null;
      }
    }

    return Promise.reject(error);
  }
);
```

### API Endpoints

```typescript
// frontend/src/api/endpoints.ts
import { api } from './axios';

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    name: string;
    role: string;
  };
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: string;
}

export const authApi = {
  login: (email: string, password: string) =>
    api.post<LoginResponse>('/auth/login', { email, password }),

  refresh: () => {
    const refreshToken = localStorage.getItem('refresh_token');
    return api.post<LoginResponse>('/auth/refresh', { refreshToken });
  },

  getProfile: () =>
    api.get<User>('/auth/profile'),

  logout: () =>
    api.post('/auth/logout')
};

export const userApi = {
  getAll: () => api.get<User[]>('/users'),

  getById: (id: string) => api.get<User>(`/users/${id}`),

  create: (data: Partial<User>) => api.post<User>('/users', data),

  update: (id: string, data: Partial<User>) => api.put<User>(`/users/${id}`, data),

  delete: (id: string) => api.delete(`/users/${id}`)
};
```

## Protected Routes

### Protected Route Component

```tsx
// frontend/src/routes/ProtectedRoute.tsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

interface ProtectedRouteProps {
  children: React.ReactNode;
  allowedRoles?: string[];
}

export function ProtectedRoute({ children, allowedRoles }: ProtectedRouteProps) {
  const { isAuthenticated, isLoading, user } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (allowedRoles && user && !allowedRoles.includes(user.role)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return <>{children}</>;
}

// Usage in router
/*
<Route path="/dashboard" element={
  <ProtectedRoute>
    <Dashboard />
  </ProtectedRoute>
} />

<Route path="/admin" element={
  <ProtectedRoute allowedRoles={['admin']}>
    <AdminPanel />
  </ProtectedRoute>
} />
*/
```

### Login Page

```tsx
// frontend/src/pages/Login.tsx
import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const from = (location.state as { from?: Location })?.from?.pathname || '/dashboard';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      await login(email, password);
      navigate(from, { replace: true });
    } catch (err) {
      setError('Invalid email or password');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="max-w-md w-full space-y-8 p-8 bg-white rounded-lg shadow-md">
        <h2 className="text-3xl font-bold text-center">Sign in</h2>

        {error && (
          <div className="bg-red-50 text-red-600 p-3 rounded">{error}</div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700">
              Email
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              required
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700">
              Password
            </label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              required
            />
          </div>

          <button
            type="submit"
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary hover:bg-primary-dark"
          >
            Sign in
          </button>
        </form>
      </div>
    </div>
  );
}
```

## Vite Proxy Configuration

### Vite Config

```typescript
// frontend/vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
        secure: false
      },
      '/auth': {
        target: 'http://localhost:3001',
        changeOrigin: true,
        secure: false
      }
    }
  },
  build: {
    sourcemap: true
  }
});
```

### Environment Variables

```typescript
// frontend/.env
VITE_API_URL=/api

// frontend/.env.production
VITE_API_URL=https://api.myapp.com
```

## Express API Integration

### Auth Controller (same pattern as MEAN, reference node-express-api)

```typescript
// backend/src/controllers/auth.controller.ts
// Pattern identical to MEAN - see node-express-api skill
// Uses same asyncHandler, authenticate middleware
```

### Auth Routes

```typescript
// backend/src/routes/auth.routes.ts
import { Router } from 'express';
import { login, refreshToken, getProfile } from '../controllers/auth.controller';
import { authenticate } from '../middleware/authenticate';

const router = Router();

router.post('/login', login);
router.post('/refresh', refreshToken);
router.get('/profile', authenticate, getProfile);

export default router;
```

## Auth Flow

### Login Sequence

```
1. User submits login form (email, password)
   ↓
2. React AuthContext.login() → axios POST /auth/login
   ↓
3. Express validates, returns { accessToken, refreshToken, user }
   ↓
4. React stores tokens in localStorage
   ↓
5. AuthContext state updates (isAuthenticated: true)
   ↓
6. Navigate to dashboard or original destination
```

### Token Refresh Sequence

```
1. API call returns 401 (token expired)
   ↓
2. Axios interceptor catches, checks if refresh in progress
   ↓
3. If not refreshing: call refresh endpoint with refreshToken
   ↓
4. Express validates refresh token, issues new access + refresh
   ↓
5. React stores new tokens, retries original request
   ↓
6. If refresh fails: clear tokens, redirect to login
```

## Integration Checklist

- [ ] Vite project with React 19 and TypeScript
- [ ] AuthContext with login, logout, refresh methods
- [ ] Axios instance with auth interceptor and 401 handling
- [ ] ProtectedRoute component wrapping private pages
- [ ] Vite proxy configuration for dev server
- [ ] Environment variables for API URL
- [ ] Shared types between frontend and backend
- [ ] Docker compose for MongoDB + services
- [ ] Vitest tests for auth flow
- [ ] Playwright E2E tests for login/logout