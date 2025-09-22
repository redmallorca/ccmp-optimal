#!/bin/bash
#
# Container-Aware Command Execution
# Automatically detects container environment and executes commands appropriately
#

set -euo pipefail

# Configuration
DEFAULT_SERVICE="web"
DEV_COMPOSE_FILE="docker-compose.dev.yml"
PROD_COMPOSE_FILE="docker-compose.yml"

# Logging
log() {
    echo "[$(date '+%H:%M:%S')] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Check if Docker is available
check_docker_available() {
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Install Docker Desktop or use --local flag to force local execution"
    fi

    if ! command -v docker-compose &> /dev/null; then
        error "docker-compose not found. Install docker-compose or use --local flag"
    fi

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        error "Docker daemon not running. Start Docker Desktop or use --local flag"
    fi
}

# Detect if running in container environment
is_container_env() {
    if [[ -f "$DEV_COMPOSE_FILE" ]] || [[ -f "$PROD_COMPOSE_FILE" ]]; then
        return 0
    fi
    return 1
}

# Get the appropriate compose file
get_compose_file() {
    if [[ -f "$DEV_COMPOSE_FILE" ]]; then
        echo "$DEV_COMPOSE_FILE"
    elif [[ -f "$PROD_COMPOSE_FILE" ]]; then
        echo "$PROD_COMPOSE_FILE"
    else
        error "No docker-compose file found"
    fi
}

# Check if containers are running
containers_running() {
    local compose_file=$(get_compose_file)
    check_docker_available
    docker-compose -f "$compose_file" ps --services --filter "status=running" | grep -q .
}

# Start containers if not running
ensure_containers_running() {
    local compose_file=$(get_compose_file)

    if ! containers_running; then
        log "Starting containers with $compose_file..."
        docker-compose -f "$compose_file" up -d

        # Wait for web service to be ready
        local service="${1:-$DEFAULT_SERVICE}"
        log "Waiting for $service service to be ready..."

        # Wait up to 60 seconds for service to be healthy
        local timeout=60
        local count=0

        while [[ $count -lt $timeout ]]; do
            if docker-compose -f "$compose_file" exec -T "$service" echo "ready" &>/dev/null; then
                log "$service service is ready"
                return 0
            fi
            sleep 1
            ((count++))
        done

        error "$service service failed to start within $timeout seconds"
    fi
}

# Execute command in container or locally
exec_command() {
    local cmd="$1"
    local service="${2:-$DEFAULT_SERVICE}"

    if is_container_env; then
        log "Container environment detected"

        # Ensure containers are running
        ensure_containers_running "$service"

        local compose_file=$(get_compose_file)

        log "Executing in container ($service): $cmd"

        # Execute command in container and preserve exit code
        docker-compose -f "$compose_file" exec -T "$service" sh -c "$cmd"
        local exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            log "Command failed in container: $cmd (exit code: $exit_code)"
            return $exit_code
        fi
    else
        log "Local environment detected"
        log "Executing locally: $cmd"

        # Execute locally and preserve exit code
        eval "$cmd"
        local exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            log "Command failed locally: $cmd (exit code: $exit_code)"
            return $exit_code
        fi
    fi
}

# Execute command with output capture
exec_command_with_output() {
    local cmd="$1"
    local service="${2:-$DEFAULT_SERVICE}"

    if is_container_env; then
        ensure_containers_running "$service"
        local compose_file=$(get_compose_file)
        docker-compose -f "$compose_file" exec -T "$service" sh -c "$cmd"
    else
        eval "$cmd"
    fi
}

# Check if command exists in container/local
command_exists() {
    local cmd="$1"
    local service="${2:-$DEFAULT_SERVICE}"

    if is_container_env; then
        ensure_containers_running "$service"
        local compose_file=$(get_compose_file)
        docker-compose -f "$compose_file" exec -T "$service" which "$cmd" &>/dev/null
    else
        command -v "$cmd" &>/dev/null
    fi
}

# Get container logs
show_logs() {
    local service="${1:-$DEFAULT_SERVICE}"
    local compose_file=$(get_compose_file)

    if is_container_env; then
        docker-compose -f "$compose_file" logs -f "$service"
    else
        log "Not in container environment - no logs to show"
    fi
}

# Container shell access
shell_access() {
    local service="${1:-$DEFAULT_SERVICE}"
    local compose_file=$(get_compose_file)

    if is_container_env; then
        ensure_containers_running "$service"
        log "Opening shell in $service container..."
        docker-compose -f "$compose_file" exec "$service" sh
    else
        log "Not in container environment - opening local shell"
        bash
    fi
}

# Container status check
container_status() {
    if is_container_env; then
        local compose_file=$(get_compose_file)
        echo "Container Status:"
        docker-compose -f "$compose_file" ps
    else
        echo "Not in container environment"
    fi
}

# Development-specific commands
dev_install() {
    exec_command "npm install"
}

dev_start() {
    if is_container_env; then
        local compose_file=$(get_compose_file)
        log "Starting development environment..."
        docker-compose -f "$compose_file" up -d
        log "Development containers started"
        log "View logs with: $0 logs"
    else
        exec_command "npm run dev"
    fi
}

dev_stop() {
    if is_container_env; then
        local compose_file=$(get_compose_file)
        log "Stopping development environment..."
        docker-compose -f "$compose_file" down
        log "Development containers stopped"
    else
        log "Not in container environment - nothing to stop"
    fi
}

dev_build() {
    exec_command "npm run build"
}

dev_test() {
    exec_command "npm test"
}

dev_lint() {
    exec_command "npm run lint"
}

dev_typecheck() {
    exec_command "npm run typecheck"
}

# Production commands
prod_deploy() {
    if [[ -f "$PROD_COMPOSE_FILE" ]]; then
        log "Deploying to production..."
        docker-compose -f "$PROD_COMPOSE_FILE" up -d --build
        log "Production deployment complete"
    else
        error "Production compose file not found: $PROD_COMPOSE_FILE"
    fi
}

# Command line interface
usage() {
    cat << EOF
Container-Aware Command Execution

Usage: $0 <command> [args...]

Container Management:
  status                 Show container status
  start                 Start development containers
  stop                  Stop development containers
  logs [service]        Show container logs
  shell [service]       Open shell in container

Development Commands:
  install               npm install
  dev                   Start development server
  build                 Build project
  test                  Run tests
  lint                  Run linter
  typecheck            TypeScript check

Production Commands:
  deploy                Deploy to production

Direct Execution:
  exec <command> [service]    Execute command in container/locally
  run <command> [service]     Execute with output capture

Examples:
  $0 install                    # npm install
  $0 dev                       # Start development
  $0 exec "npm run custom"     # Custom npm command
  $0 shell web                 # Shell into web container
  $0 logs                      # View logs

Environment Detection:
  - Checks for docker-compose.dev.yml or docker-compose.yml
  - Automatically starts containers if needed
  - Falls back to local execution if no containers
EOF
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        "install")
            dev_install
            ;;
        "start"|"dev")
            dev_start
            ;;
        "stop")
            dev_stop
            ;;
        "build")
            dev_build
            ;;
        "test")
            dev_test
            ;;
        "lint")
            dev_lint
            ;;
        "typecheck")
            dev_typecheck
            ;;
        "logs")
            show_logs "${2:-$DEFAULT_SERVICE}"
            ;;
        "shell")
            shell_access "${2:-$DEFAULT_SERVICE}"
            ;;
        "status")
            container_status
            ;;
        "deploy")
            prod_deploy
            ;;
        "exec")
            if [[ $# -lt 2 ]]; then
                error "Usage: $0 exec <command> [service]"
            fi
            exec_command "$2" "${3:-$DEFAULT_SERVICE}"
            ;;
        "run")
            if [[ $# -lt 2 ]]; then
                error "Usage: $0 run <command> [service]"
            fi
            exec_command_with_output "$2" "${3:-$DEFAULT_SERVICE}"
            ;;
        "help"|"-h"|"--help")
            usage
            ;;
        *)
            error "Unknown command: $1. Use '$0 help' for usage information."
            ;;
    esac
}

# Execute main function with all arguments
main "$@"