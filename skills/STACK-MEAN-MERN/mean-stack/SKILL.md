---
name: mean-stack
description: "Trigger: mean stack, MEAN full-stack, Angular Express MongoDB, Angular JWT auth, Angular HttpClient. MEAN (MongoDB, Express, Angular, Node.js) full-stack patterns for project scaffolding, Angular HttpClient with JWT interceptor, auth guards, refresh token flow, CORS configuration, and proxy setup."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# MEAN Stack Skill

> Comprehensive patterns for MEAN (MongoDB, Express, Angular, Node.js) full-stack development.

## Trigger Words

`mean stack`, `MEAN full-stack`, `Angular Express MongoDB`, `Angular JWT auth`, `Angular HttpClient`, `Angular auth guard`, `MEAN project`, `Angular proxy`, `Angular CORS`

## References

- `scope-rule-architect-angular` — Angular architecture with standalone components and signals
- `node-express-api` — Express.js REST API patterns
- `mongoose-schema` — MongoDB/Mongoose schema patterns
- `typescript` — TypeScript best practices

## Project Structure

### MEAN Full-Stack Layout

```
my-mean-app/
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
├── frontend/                    # Angular SPA
│   ├── src/
│   │   ├── app/
│   │   │   ├── core/           # Singleton services
│   │   │   │   ├── auth/
│   │   │   │   │   ├── auth.service.ts
│   │   │   │   │   ├── auth.interceptor.ts
│   │   │   │   │   ├── auth.guard.ts
│   │   │   │   │   └── auth.models.ts
│   │   │   │   └── api/
│   │   │   │       └── api.service.ts
│   │   │   ├── shared/         # Shared components
│   │   │   ├── features/       # Feature modules
│   │   │   │   └── auth/
│   │   │   │       ├── login/
│   │   │   │       └── dashboard/
│   │   │   └── app.config.ts
│   │   ├── proxy.conf.json
│   │   └── environments/
│   ├── angular.json
│   └── package.json
├── shared/                     # Shared TypeScript types
│   └── types/
│       ├── user.type.ts
│       └── auth.type.ts
└── docker-compose.yml
```

### Angular CLI New Project

```bash
# Create Angular project with routing and SCSS
ng new frontend --routing --style=scss --skip-tests

# Generate feature module
ng generate module features/auth --route auth --module app

# Generate service with interceptor
ng generate service core/auth/auth
ng generate interceptor core/auth/jwt-interceptor
```

## Angular HttpClient + JWT Interceptor

### Auth Service

```typescript
// frontend/src/app/core/auth/auth.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { BehaviorSubject, Observable, tap, catchError, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    name: string;
    role: string;
  };
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private router = inject(Router);

  private accessTokenKey = 'access_token';
  private refreshTokenKey = 'refresh_token';

  private authStateSubject = new BehaviorSubject<AuthResponse | null>(this.loadTokens());
  public authState$ = this.authStateSubject.asObservable();

  private loadTokens(): AuthResponse | null {
    const token = localStorage.getItem(this.accessTokenKey);
    const refresh = localStorage.getItem(this.refreshTokenKey);
    if (token && refresh) {
      return { accessToken: token, refreshToken: refresh, user: this.decodeToken(token) };
    }
    return null;
  }

  login(credentials: LoginCredentials): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${environment.apiUrl}/auth/login`, credentials).pipe(
      tap(response => {
        this.storeTokens(response);
        this.authStateSubject.next(response);
      }),
      catchError(error => {
        console.error('Login failed:', error);
        return throwError(() => error);
      })
    );
  }

  logout(): void {
    localStorage.removeItem(this.accessTokenKey);
    localStorage.removeItem(this.refreshTokenKey);
    this.authStateSubject.next(null);
    this.router.navigate(['/auth/login']);
  }

  getAccessToken(): string | null {
    return localStorage.getItem(this.accessTokenKey);
  }

  refreshToken(): Observable<AuthResponse> {
    const refresh = localStorage.getItem(this.refreshTokenKey);
    return this.http.post<AuthResponse>(`${environment.apiUrl}/auth/refresh`, { refreshToken: refresh }).pipe(
      tap(response => {
        this.storeTokens(response);
        this.authStateSubject.next(response);
      })
    );
  }

  private storeTokens(response: AuthResponse): void {
    localStorage.setItem(this.accessTokenKey, response.accessToken);
    localStorage.setItem(this.refreshTokenKey, response.refreshToken);
  }

  private decodeToken(token: string): AuthResponse['user'] {
    const payload = token.split('.')[1];
    return JSON.parse(atob(payload));
  }

  isAuthenticated(): boolean {
    return !!this.getAccessToken();
  }
}
```

### JWT Interceptor

```typescript
// frontend/src/app/core/auth/jwt-interceptor.ts
import { inject } from '@angular/core';
import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError, BehaviorSubject } from 'rxjs';
import { catchError, filter, take, switchMap } from 'rxjs/operators';
import { AuthService } from './auth.service';

export class JwtInterceptor implements HttpInterceptor {
  private authService = inject(AuthService);
  private isRefreshing = false;
  private refreshTokenSubject = new BehaviorSubject<string | null>(null);

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Skip auth for login/refresh endpoints
    if (this.isAuthEndpoint(request.url)) {
      return next.handle(request);
    }

    const token = this.authService.getAccessToken();
    if (token) {
      request = this.addToken(request, token);
    }

    return next.handle(request).pipe(
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401 && !this.isAuthEndpoint(request.url)) {
          return this.handle401Error(request, next);
        }
        return throwError(() => error);
      })
    );
  }

  private addToken(request: HttpRequest<unknown>, token: string): HttpRequest<unknown> {
    return request.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }

  private isAuthEndpoint(url: string): boolean {
    return url.includes('/auth/login') || url.includes('/auth/refresh');
  }

  private handle401Error(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    if (!this.isRefreshing) {
      this.isRefreshing = true;
      this.refreshTokenSubject.next(null);

      return this.authService.refreshToken().pipe(
        switchMap((response: AuthResponse) => {
          this.isRefreshing = false;
          this.refreshTokenSubject.next(response.accessToken);
          return next.handle(this.addToken(request, response.accessToken));
        }),
        catchError(error => {
          this.isRefreshing = false;
          this.authService.logout();
          return throwError(() => error);
        })
      );
    }

    return this.refreshTokenSubject.pipe(
      filter(token => token !== null),
      take(1),
      switchMap(token => next.handle(this.addToken(request, token!)))
    );
  }
}
```

### Auth Guard

```typescript
// frontend/src/app/core/auth/auth.guard.ts
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  router.navigate(['/auth/login'], { queryParams: { returnUrl: state.url } });
  return false;
};

export const roleGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const requiredRoles = route.data['roles'] as string[];
  const user = authService.getCurrentUser();

  if (user && requiredRoles.includes(user.role)) {
    return true;
  }

  router.navigate(['/unauthorized']);
  return false;
};
```

### HTTP Provider Setup

```typescript
// frontend/src/app/app.config.ts
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { routes } from './app.routes';
import { JwtInterceptor } from './core/auth/jwt-interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(
      withInterceptors([JwtInterceptor])
    )
  ]
};
```

## Express API Integration

### Auth Controller

```typescript
// backend/src/controllers/auth.controller.ts
import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import { asyncHandler } from '../middleware/async-handler';
import { AuthRequest } from '../middleware/authenticate';

const authService = new AuthService();

export const login = asyncHandler(async (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ error: 'Email and password are required' });
    return;
  }

  const result = await authService.login(email, password);

  res.status(200).json({
    accessToken: result.accessToken,
    refreshToken: result.refreshToken,
    user: result.user
  });
});

export const refreshToken = asyncHandler(async (req: Request, res: Response) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    res.status(400).json({ error: 'Refresh token is required' });
    return;
  }

  const result = await authService.refresh(refreshToken);

  res.status(200).json({
    accessToken: result.accessToken,
    refreshToken: result.refreshToken,
    user: result.user
  });
});

export const getProfile = asyncHandler(async (req: AuthRequest, res: Response) => {
  const user = await authService.getProfile(req.user!.id);

  if (!user) {
    res.status(404).json({ error: 'User not found' });
    return;
  }

  res.status(200).json({ data: user });
});
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
2. Angular AuthService.login() → POST /auth/login
   ↓
3. Express AuthController.login() validates credentials
   ↓
4. Generate JWT access token (15m) + refresh token (7d)
   ↓
5. Return { accessToken, refreshToken, user }
   ↓
6. Angular stores tokens in localStorage
   ↓
7. AuthStateSubject emits new state
   ↓
8. UI updates to show authenticated state
```

### Token Refresh Sequence

```
1. API call returns 401 (token expired)
   ↓
2. JwtInterceptor catches error, checks if refresh in progress
   ↓
3. If not refreshing: call AuthService.refreshToken()
   ↓
4. AuthService → POST /auth/refresh with refreshToken
   ↓
5. Express validates refresh token, issues new access token
   ↓
6. Angular stores new tokens, retries original request
   ↓
7. If refresh fails: logout and redirect to login
```

## CORS Configuration

### Express CORS Setup

```typescript
// backend/src/app.ts
import cors from 'cors';

const app = express();

// CORS configuration for Angular dev server
app.use(cors({
  origin: ['http://localhost:4200', 'http://localhost:4201'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Handle preflight requests
app.options('*', cors());
```

### Angular Proxy Configuration

```json
// frontend/proxy.conf.json
{
  "/api": {
    "target": "http://localhost:3000",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug"
  },
  "/auth": {
    "target": "http://localhost:3000",
    "secure": false,
    "changeOrigin": true
  }
}
```

### Angular JSON Dev Server Config

```json
// angular.json (dev server proxy)
{
  "architect": {
    "serve": {
      "options": {
        "proxyConfig": "src/proxy.conf.json"
      }
    }
  }
}
```

### Production CORS Headers

```typescript
// For production, set explicit origin
const ALLOWED_ORIGINS = [
  'https://myapp.com',
  'https://www.myapp.com'
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin || ALLOWED_ORIGINS.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
```

## Environment Configuration

### Angular Environment

```typescript
// frontend/src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: '/api',
  refreshTokenUrl: '/auth/refresh'
};

// frontend/src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.myapp.com',
  refreshTokenUrl: 'https://api.myapp.com/auth/refresh'
};
```

### Backend Environment

```typescript
// backend/src/config/config.ts
import dotenv from 'dotenv';
dotenv.config();

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  database: {
    url: process.env.MONGODB_URL || 'mongodb://localhost:27017/meanapp'
  },
  jwt: {
    secret: process.env.JWT_SECRET!,
    accessExpiresIn: '15m',
    refreshExpiresIn: '7d'
  },
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:4200',
    credentials: true
  }
};
```

## Integration Checklist

- [ ] Angular project with standalone components (no NgModules)
- [ ] AuthService with login, logout, refresh methods
- [ ] JwtInterceptor that adds Bearer token and handles 401
- [ ] AuthGuard protecting routes
- [ ] Proxy configuration for dev server
- [ ] Express CORS configured for Angular origin
- [ ] Environment files for API URL configuration
- [ ] Shared types between frontend and backend
- [ ] Docker compose for MongoDB + services