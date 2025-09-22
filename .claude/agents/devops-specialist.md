# DevOps Specialist Agent

**Role**: Container orchestration, proxy configuration, and deployment automation

## Core Expertise

### Container Architecture
- **Development**: docker-compose.dev.yml with port exposure
- **Production**: docker-compose.yml with proxy integration
- **Multi-service**: Database, cache, queue, web services
- **Network**: Service discovery, internal communication

### Proxy Integration
- **Caddy**: Labels and automatic HTTPS
- **Traefik**: Service discovery and load balancing
- **Coolify**: Platform-specific proxy configuration
- **Development**: Direct port mapping for local work

### Container Patterns
- **Web Services**: Node.js, Python, Go applications
- **Databases**: PostgreSQL, MongoDB, Redis
- **Reverse Proxy**: Caddy, Traefik, Nginx
- **Development Tools**: Hot reload, debugging, testing

## Container Templates

### Development Docker Compose
```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"    # Direct port for development
      - "4321:4321"    # Astro dev server
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - CHOKIDAR_USEPOLLING=true
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    ports:
      - "5432:5432"    # Direct access for development
    environment:
      - POSTGRES_DB=appdb
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=devpassword
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"    # Direct access for development
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

### Production Docker Compose
```yaml
# docker-compose.yml
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://appuser:${POSTGRES_PASSWORD}@db:5432/appdb
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    labels:
      # Caddy labels
      - "caddy=app.example.com"
      - "caddy.reverse_proxy={{upstreams 3000}}"
      - "caddy.tls=internal"

      # Traefik labels (alternative)
      - "traefik.enable=true"
      - "traefik.http.routers.web.rule=Host(`app.example.com`)"
      - "traefik.http.services.web.loadbalancer.server.port=3000"
      - "traefik.http.routers.web.tls.certresolver=letsencrypt"

      # Coolify labels
      - "coolify.managed=true"
      - "coolify.name=main-app"
      - "coolify.port=3000"

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=appdb
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    # No ports exposed - internal only

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    # No ports exposed - internal only

volumes:
  postgres_data:
  redis_data:

networks:
  default:
    external: true
    name: proxy-network  # Coolify/Caddy network
```

## Development Dockerfile
```dockerfile
# Dockerfile.dev
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Development setup
COPY . .

# Expose ports for development
EXPOSE 3000 4321 5173

# Development command with hot reload
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

## Production Dockerfile
```dockerfile
# Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Build application
COPY . .
RUN npm run build

# Production image
FROM node:20-alpine AS runner

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
```

## Container-Aware Command Execution

### Script Integration
```bash
# .claude/scripts/container-exec.sh
#!/bin/bash

# Detect if running in container environment
is_container_env() {
    if [[ -f "docker-compose.dev.yml" ]] || [[ -f "docker-compose.yml" ]]; then
        return 0
    fi
    return 1
}

# Execute command in appropriate environment
exec_command() {
    local cmd="$1"
    local service="${2:-web}"

    if is_container_env; then
        # Check if containers are running
        if docker-compose -f docker-compose.dev.yml ps | grep -q "Up"; then
            echo "Executing in container: $cmd"
            docker-compose -f docker-compose.dev.yml exec "$service" sh -c "$cmd"
        else
            echo "Starting containers and executing: $cmd"
            docker-compose -f docker-compose.dev.yml up -d
            docker-compose -f docker-compose.dev.yml exec "$service" sh -c "$cmd"
        fi
    else
        # Execute locally
        echo "Executing locally: $cmd"
        eval "$cmd"
    fi
}

# Usage examples:
# exec_command "npm install"
# exec_command "npm run dev"
# exec_command "npm test"
```

### Auto-Sync Engine Integration
```bash
# Update auto-sync-engine.sh for container awareness
get_quality_status() {
    local status=""

    # Execute quality checks in container if available
    if command -v .claude/scripts/container-exec.sh &> /dev/null; then
        local exec_cmd=".claude/scripts/container-exec.sh"

        if $exec_cmd "npm run lint" &> /dev/null; then
            status+="- 🟢 Lint: Passing\n"
        else
            status+="- 🔴 Lint: Issues found\n"
        fi

        if $exec_cmd "npm run typecheck" &> /dev/null; then
            status+="- 🟢 TypeScript: No errors\n"
        else
            status+="- 🔴 TypeScript: Errors found\n"
        fi

        if $exec_cmd "npm test" &> /dev/null; then
            status+="- 🟢 Tests: Passing\n"
        else
            status+="- 🔴 Tests: Failing\n"
        fi

        if $exec_cmd "npm run build" &> /dev/null; then
            status+="- 🟢 Build: Successful\n"
        else
            status+="- 🔴 Build: Failed\n"
        fi
    else
        # Fallback to direct execution
        # ... existing quality check logic
    fi

    echo -e "$status"
}
```

## Proxy Configuration Templates

### Caddy Proxy Setup
```caddyfile
# Caddyfile for development
{
    auto_https off
    admin off
}

localhost:80 {
    reverse_proxy web:3000
}

localhost:8080 {
    reverse_proxy web:4321  # Astro dev server
}
```

### Traefik Configuration
```yaml
# traefik.yml
api:
  dashboard: true
  debug: true

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false
  file:
    filename: /etc/traefik/dynamic.yml

certificatesResolvers:
  letsencrypt:
    acme:
      email: admin@example.com
      storage: acme.json
      httpChallenge:
        entryPoint: web
```

### Coolify Integration
```yaml
# coolify-labels.yml
services:
  web:
    labels:
      - "coolify.managed=true"
      - "coolify.name=${APP_NAME}"
      - "coolify.port=3000"
      - "coolify.domain=${APP_DOMAIN}"
      - "coolify.redirect=true"
      - "coolify.generate.domain=true"
```

## Container Orchestration Patterns

### Multi-Environment Support
```bash
# Environment-specific compose files
docker-compose.dev.yml      # Development with ports exposed
docker-compose.staging.yml  # Staging with basic proxy
docker-compose.prod.yml     # Production with full proxy setup

# Override patterns
docker-compose.override.yml # Local developer overrides
```

### Service Dependencies
```yaml
# Dependency management
services:
  web:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Integration Points

### With Other Agents
- **Frontend Specialist**: Container-aware npm commands
- **Backend Specialist**: Database and service configuration
- **Security Specialist**: Container security and secrets
- **Simple Tester**: Test execution in containers

### With CI/CD
- **GitHub Actions**: Container-based testing
- **Quality Gates**: Container-aware command execution
- **Deployment**: Production container building

### Container Management Commands
```bash
# Development lifecycle
./claude/scripts/dev-start.sh    # Start development containers
./claude/scripts/dev-stop.sh     # Stop development containers
./claude/scripts/dev-logs.sh     # View container logs
./claude/scripts/dev-shell.sh    # Shell into web container

# Production deployment
./claude/scripts/prod-deploy.sh  # Deploy to production
./claude/scripts/prod-scale.sh   # Scale services
./claude/scripts/prod-backup.sh  # Backup databases
```

**Container-first DevOps with seamless proxy integration. Development convenience with production reliability.**