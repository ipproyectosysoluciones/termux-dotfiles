---
name: node-express-api
description: "Trigger: express api, express middleware, REST API, JWT auth, Node.js API. Comprehensive Express.js patterns for building robust Node.js REST APIs with TypeScript, middleware chains, router patterns, JWT authentication, async error handling, and environment configuration."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Node Express API Skill

> Comprehensive patterns for building production-ready Express.js REST APIs with TypeScript.

## Trigger Words

`express api`, `express middleware`, `REST API`, `JWT auth`, `Node.js API`, `Express router`, `Express server`, `api endpoint`

## References

- `typescript` — TypeScript best practices for API type safety
- `api-design-principles` — REST API design conventions

## Router Pattern

### Basic Router Setup

```typescript
import { Router, Request, Response, NextFunction } from 'express';

const router = Router();

// Typed route handler
router.get('/users', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const users = await UserService.findAll();
    res.json({ data: users, count: users.length });
  } catch (error) {
    next(error);
  }
});
```

### Router with Params

```typescript
router.get('/users/:id', validateUserId, async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const user = await UserService.findById(id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json({ data: user });
});
```

### Nested Routers

```typescript
// users.routes.ts
const router = Router({ mergeParams: true });

router.get('/:userId/posts', async (req, res) => {
  const { userId } = req.params;
  const posts = await PostService.findByUser(userId);
  res.json({ data: posts });
});

// In main app
app.use('/api/v1/users', usersRouter);
```

## Middleware Chain

### Middleware Composition

```typescript
// Order matters - applied sequentially
app.use(
  cors(),                    // 1. CORS headers
  helmet(),                  // 2. Security headers
  compression(),            // 3. Response compression
  express.json(),           // 4. Body parsing
  requestLogger(),          // 5. Logging
  rateLimit({               // 6. Rate limiting
    windowMs: 15 * 60 * 1000,
    max: 100
  }),
);
```

### Custom Middleware

```typescript
// Validation middleware
function validateUserId(req: Request, res: Response, next: NextFunction) {
  const { id } = req.params;
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ error: 'Invalid user ID format' });
  }
  next();
}

// Request timing middleware
function requestTimer(req: Request, res: Response, next: NextFunction) {
  req.startTime = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - req.startTime;
    logger.info(`${req.method} ${req.path} ${res.statusCode} ${duration}ms`);
  });
  next();
}
```

### Error Handler Middleware

```typescript
// Must have 4 arguments to be treated as error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  logger.error(err.stack);
  const status = err instanceof HttpError ? err.status : 500;
  res.status(status).json({
    error: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});
```

## REST Conventions

### HTTP Method Semantics

| Method | Purpose | Idempotent | Body |
|--------|---------|------------|------|
| GET | Retrieve resource(s) | Yes | No |
| POST | Create new resource | No | Yes |
| PUT | Replace resource entirely | Yes | Yes |
| PATCH | Partial update | No | Yes |
| DELETE | Remove resource | Yes | No |

### Status Codes

```typescript
// Success
200 OK           // Standard success
201 Created       // Resource created
204 No Content    // Success with no response body (delete)

// Client Errors
400 Bad Request   // Invalid input
401 Unauthorized  // Not authenticated
403 Forbidden     // Authenticated but not authorized
404 Not Found     // Resource doesn't exist
409 Conflict      // Duplicate resource
422 Unprocessable // Validation failed

// Server Errors
500 Internal Error // Unexpected failure
503 Unavailable    // Service down
```

### Standard Response Format

```typescript
// Success
res.status(200).json({
  data: payload,
  meta: {
    timestamp: new Date().toISOString(),
    version: '1.0'
  }
});

// Collection with pagination
res.status(200).json({
  data: items,
  meta: {
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit)
  }
});

// Error
res.status(400).json({
  error: {
    code: 'VALIDATION_ERROR',
    message: 'Invalid input',
    details: validationErrors
  }
});
```

## JWT Authentication

### JWT Middleware

```typescript
import jwt from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret';

function authenticate(req: AuthRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid authorization header' });
  }

  const token = authHeader.slice(7);
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as AuthRequest['user'];
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}

function authorize(...roles: string[]) {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthenticated' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
}

// Usage
router.post('/admin', authenticate, authorize('admin'), handler);
```

### Token Generation

```typescript
function generateTokens(user: User): { accessToken: string; refreshToken: string } {
  const accessToken = jwt.sign(
    { id: user._id, email: user.email, role: user.role },
    JWT_SECRET,
    { expiresIn: '15m' }
  );

  const refreshToken = jwt.sign(
    { id: user._id },
    JWT_SECRET,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
}
```

## Async Wrapper

### Async Error Handler

```typescript
// Wrap async route handlers to catch errors and pass to next()
const asyncHandler = (fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) =>
  (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };

// Usage - eliminates try/catch in every handler
router.get('/users/:id', asyncHandler(async (req, res) => {
  const user = await UserService.findById(req.params.id);
  if (!user) {
    // Throwing a known error type
    const error = new HttpError(404, 'User not found');
    throw error;
  }
  res.json({ data: user });
}));

class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'HttpError';
  }
}
```

### Async Utility Patterns

```typescript
// Parallel execution with error collection
async function fetchUserData(userId: string) {
  const [user, posts, followers] = await Promise.all([
    User.findById(userId),
    Post.find({ author: userId }).limit(10),
    Follower.countDocuments({ userId })
  ]);
  return { user, posts, followers };
}

// Retry with backoff
async function withRetry<T>(
  fn: () => Promise<T>,
  retries = 3,
  delay = 1000
): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    if (retries === 0) throw error;
    await new Promise(resolve => setTimeout(resolve, delay));
    return withRetry(fn, retries - 1, delay * 2);
  }
}
```

## Environment Configuration

### Config Pattern

```typescript
// config/index.ts
import dotenv from 'dotenv';
dotenv.config();

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  database: {
    url: process.env.MONGODB_URL || 'mongodb://localhost:27017/myapp',
    options: {
      useNewUrlParser: true,
      useUnifiedTopology: true
    }
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret',
    expiresIn: '15m'
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '900000', 10),
    max: parseInt(process.env.RATE_LIMIT_MAX || '100', 10)
  }
} as const;
```

### Environment Validation

```typescript
// validate-env.ts
import z from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  MONGODB_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('15m')
});

function validateEnv() {
  const result = envSchema.safeParse(process.env);
  if (!result.success) {
    console.error('Invalid environment variables:');
    result.error.errors.forEach(e => console.error(`  ${e.path}: ${e.message}`));
    process.exit(1);
  }
  return result.data;
}

export const env = validateEnv();
```

### Development vs Production

```typescript
// Conditional middleware
if (config.env === 'development') {
  app.use(morgan('dev'));
  app.use((req: Request, res: Response, next: NextFunction) => {
    // Detailed error logging
    console.error(err.stack);
    next();
  });
} else {
  app.use(morgan('combined'));
}

// Security settings
if (config.env === 'production') {
  app.set('trust proxy', 1);
  app.use(helmet({
    contentSecurityPolicy: true,
    hsts: { maxAge: 31536000, includeSubDomains: true }
  }));
}
```

## Integration Checklist

- [ ] Router with typed handlers and proper status codes
- [ ] Global error handler middleware (4-arg function)
- [ ] Authentication middleware (JWT verification)
- [ ] Authorization middleware (role checking)
- [ ] Input validation middleware
- [ ] Request logging middleware
- [ ] Rate limiting middleware
- [ ] Environment config with validation (Zod schema)
- [ ] Async wrapper for route handlers
- [ ] CORS configured appropriately
- [ ] Security headers (helmet)
- [ ] Body parsing with size limits