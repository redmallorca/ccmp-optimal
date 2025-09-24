# CCPM Optimal - Code Style and Conventions

## Core Code Standards

### 1. File Headers (ABOUTME Comments)
**REQUIRED**: Start all files with 2-line description
```bash
#!/bin/bash
# ABOUTME: Epic creator with GitHub integration - implementation for new command
# Automatically creates GitHub issues and sets up deliverable tracking
```

```javascript
// ABOUTME: User authentication service - handles login/logout with JWT tokens
// Integrates with backend API and manages user session state
```

### 2. Naming Conventions

#### Files and Directories
- **Lowercase + hyphens**: `epic-name`, `user-auth`, `api-client`
- **No "new", "improved", "enhanced"**: Use evergreen naming
- **Descriptive**: `auth-service.ts` not `service.ts`

#### Epic Names
```bash
# Valid epic names (lowercase, numbers, hyphens only)
user-auth
payment-flow  
dashboard-v2
api-integration

# Invalid epic names
UserAuth          # No camelCase
user_auth         # No underscores
user auth         # No spaces
```

#### Variables and Functions
```typescript
// camelCase for variables and functions
const userToken = getAuthToken();
const apiResponse = await fetchUserData();

// PascalCase for classes and components
class AuthService {}
const LoginForm = () => {};
```

## Git Commit Standards

### 3. Commit Message Format
```bash
# Required format: type(scope): description
feat(auth): implement login component
fix(api): resolve authentication timeout
test(auth): add comprehensive test coverage
docs(readme): update installation instructions
refactor(auth): simplify token validation logic

# Completion keywords (trigger auto-sync)
feat(auth): complete user authentication system
fix(api): finish debugging connection issues
implement(dashboard): done with main dashboard components
```

### 4. Branch Naming
```bash
# Auto-created by /new command
feature/epic-name
feature/user-auth
feature/payment-flow

# Manual branches (if needed)
hotfix/critical-bug
release/v2.0.0
```

## Code Quality Standards

### 5. TypeScript Requirements
- **Strict mode enabled**: No `any` types
- **Type hints**: All function parameters and returns
- **Interface definitions**: For all data structures
```typescript
interface User {
  id: string;
  email: string;
  roles: UserRole[];
}

const authenticateUser = async (credentials: LoginCredentials): Promise<User> => {
  // Implementation
};
```

### 6. Testing Standards
- **TDD Required**: Write failing test before code
- **Test file naming**: `*.test.ts`, `*.spec.ts`
- **E2E tests**: Playwright for user flows
- **Unit tests**: Component and service testing

### 7. Quality Gates (Automated)
```bash
# Must pass before merge
npm run lint          # ESLint + Prettier
npm run typecheck     # TypeScript validation  
npm run test          # All tests passing
npm run build         # Production build successful
```

## Architecture Patterns

### 8. Directory Structure
```
src/
├── components/       # Reusable UI components
│   ├── base/        # Atomic design: atoms
│   └── ui/          # Atomic design: molecules
├── pages/           # Route components
├── services/        # API and business logic
├── types/           # TypeScript type definitions
├── utils/           # Helper functions
└── middleware/      # Request/response middleware

tests/
├── unit/            # Component and service tests  
├── integration/     # API and service integration
└── e2e/            # End-to-end user flows
```

### 9. Component Patterns
```typescript
// Preferred: Composition API (Vue 3) or Functional Components (React)
const LoginForm = () => {
  const { authenticateUser } = useAuthService();
  
  // Implementation
};

// File naming: PascalCase for components
LoginForm.vue
UserProfile.tsx
PaymentModal.astro
```

### 10. Error Handling
```typescript
// Always handle errors gracefully
try {
  const user = await authService.login(credentials);
  return { success: true, user };
} catch (error) {
  logger.error('Login failed', { error, credentials: credentials.email });
  return { success: false, error: error.message };
}
```

## Documentation Standards

### 11. README Requirements
- **Quick Start**: Copy-paste installation
- **Commands**: Essential development commands
- **Architecture**: High-level system overview
- **No fluff**: Essential information only

### 12. Code Comments
```typescript
// Good: Explain WHY, not WHAT
// Use JWT with 24h expiration for security compliance
const token = jwt.sign(payload, secret, { expiresIn: '24h' });

// Bad: Explain obvious code
// Create a JWT token
const token = jwt.sign(payload, secret, { expiresIn: '24h' });
```

## Integration Standards

### 13. API Patterns
```typescript
// Consistent error handling
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

// Authentication headers
const headers = {
  'Authorization': `Bearer ${token}`,
  'Content-Type': 'application/json',
};
```

### 14. Memory Integration
```bash
# Document decisions in Supermemory
"Decided to use Vue 3 Composition API for better TypeScript integration in user authentication components"

# Architecture patterns  
"Authentication flow: LoginForm.vue → AuthService.ts → JWT validation → user state in Pinia store"
```

## Performance Standards

### 15. Optimization Requirements
- **Core Web Vitals**: LCP < 2.5s, FID < 100ms, CLS < 0.1
- **Bundle size**: Monitor and optimize
- **Lazy loading**: Non-critical components
- **Caching**: API responses and static assets

### 16. Accessibility Standards
- **WCAG 2.1 AA**: Minimum compliance
- **Semantic HTML**: Proper element usage
- **Keyboard navigation**: All interactive elements
- **Screen reader**: ARIA labels and descriptions