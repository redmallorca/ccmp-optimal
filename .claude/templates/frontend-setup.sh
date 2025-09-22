#!/bin/bash
#
# Frontend Standardization Setup Script
# Automatically configures the standardized frontend stack across all projects
#

set -euo pipefail

# Configuration
REQUIRED_DEPS=(
    "tailwindcss@latest"
    "@tailwindcss/vite@latest"
    "daisyui@latest"
    "tailwindcss-primeui@latest"
    "alpinejs@latest"
)

DEV_DEPS=(
    "tailwindcss@latest"
    "@tailwindcss/vite@latest"
)

PROD_DEPS=(
    "daisyui@latest"
    "tailwindcss-primeui@latest"
    "alpinejs@latest"
)

# Framework-specific dependencies
ASTRO_DEPS=(
    "@astrojs/tailwind@latest"
    "@astrojs/alpinejs@latest"
)

VUE_DEPS=(
    "@tailwindcss/vue@latest"
)

REACT_DEPS=(
    "@tailwindcss/react@latest"
)

# Utility functions
log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Detect framework
detect_framework() {
    if [[ -f "astro.config.mjs" ]] || [[ -f "astro.config.js" ]] || [[ -f "astro.config.ts" ]]; then
        echo "astro"
    elif [[ -f "vue.config.js" ]] || grep -q '"vue"' package.json 2>/dev/null; then
        echo "vue"
    elif grep -q '"react"' package.json 2>/dev/null; then
        echo "react"
    else
        echo "unknown"
    fi
}

# Check if running in container
is_container_env() {
    if [[ -f "docker-compose.dev.yml" ]] || [[ -f "docker-compose.yml" ]]; then
        return 0
    fi
    return 1
}

# Execute npm command (container-aware)
npm_exec() {
    local cmd="$1"

    if is_container_env && [[ -f ".claude/scripts/container-exec.sh" ]]; then
        log "Executing in container: $cmd"
        .claude/scripts/container-exec.sh exec "$cmd"
    else
        log "Executing locally: $cmd"
        eval "$cmd"
    fi
}

# Install dependencies
install_dependencies() {
    local framework="$1"

    log "Installing development dependencies..."
    npm_exec "npm install -D ${DEV_DEPS[*]}"

    log "Installing production dependencies..."
    npm_exec "npm install ${PROD_DEPS[*]}"

    # Framework-specific dependencies
    case "$framework" in
        "astro")
            log "Installing Astro-specific dependencies..."
            npm_exec "npm install ${ASTRO_DEPS[*]}"
            ;;
        "vue")
            log "Installing Vue-specific dependencies..."
            npm_exec "npm install ${VUE_DEPS[*]}"
            ;;
        "react")
            log "Installing React-specific dependencies..."
            npm_exec "npm install ${REACT_DEPS[*]}"
            ;;
        *)
            log "Framework not detected, installing generic dependencies only"
            ;;
    esac
}

# Create Tailwind configuration
create_tailwind_config() {
    local framework="$1"

    log "Creating standardized Tailwind configuration..."

    cat > tailwind.config.js << 'EOF'
import daisyui from 'daisyui';
import primeui from 'tailwindcss-primeui';

export default {
  content: [
    './src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}',
    './node_modules/tailwindcss-primeui/**/*.js'
  ],
  theme: {
    extend: {
      // Standard brand colors (customize per project)
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a',
        },
        secondary: {
          50: '#f0fdf4',
          500: '#10b981',
          900: '#064e3b',
        }
      },
      // Standard typography scale
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      // Standard spacing extensions
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      }
    },
  },
  plugins: [
    daisyui,
    primeui
  ],
  // DaisyUI configuration
  daisyui: {
    themes: [
      {
        light: {
          "primary": "#3b82f6",
          "secondary": "#10b981",
          "accent": "#f59e0b",
          "neutral": "#374151",
          "base-100": "#ffffff",
        },
        dark: {
          "primary": "#60a5fa",
          "secondary": "#34d399",
          "accent": "#fbbf24",
          "neutral": "#d1d5db",
          "base-100": "#1f2937",
        }
      }
    ],
    darkTheme: "dark",
    base: true,
    utils: true,
    logs: false,
  },
}
EOF

    log "✅ Tailwind configuration created"
}

# Create Vite configuration
create_vite_config() {
    local framework="$1"

    log "Creating Vite configuration..."

    case "$framework" in
        "astro")
            # Astro handles its own Vite config
            log "Astro detected - Vite config handled by astro.config.js"
            ;;
        *)
            cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [
    tailwindcss(),
    // Framework-specific plugins here
  ],
  css: {
    postcss: {
      plugins: [
        // PostCSS plugins if needed
      ],
    },
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    hmr: {
      port: 24678,
    },
  },
});
EOF
            log "✅ Vite configuration created"
            ;;
    esac
}

# Create standard directory structure
create_directory_structure() {
    log "Creating standardized directory structure..."

    # Create base directories
    mkdir -p src/components/{ui,layout,features,forms}
    mkdir -p src/styles
    mkdir -p src/utils

    # Create subdirectories for features
    mkdir -p src/components/features/{auth,dashboard,settings}

    log "✅ Directory structure created"
}

# Create global styles
create_global_styles() {
    log "Creating standardized global styles..."

    cat > src/styles/globals.css << 'EOF'
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* Standard base styles */
@layer base {
  html {
    @apply scroll-smooth;
  }

  body {
    @apply font-sans antialiased;
  }

  /* Focus styles for accessibility */
  *:focus-visible {
    @apply ring-2 ring-primary ring-offset-2 ring-offset-base-100 outline-none;
  }
}

/* Standard component styles */
@layer components {
  .container-standard {
    @apply mx-auto max-w-7xl px-4 sm:px-6 lg:px-8;
  }

  .card-standard {
    @apply card bg-base-100 shadow-xl;
  }

  .form-standard {
    @apply space-y-6;
  }

  .input-standard {
    @apply input input-bordered w-full focus:input-primary;
  }

  .btn-standard {
    @apply btn btn-primary;
  }
}

/* Standard utility classes */
@layer utilities {
  .text-balance {
    text-wrap: balance;
  }

  .scrollbar-thin {
    scrollbar-width: thin;
  }

  .scrollbar-none {
    scrollbar-width: none;
  }
}
EOF

    log "✅ Global styles created"
}

# Create utility functions
create_utilities() {
    log "Creating standard utility functions..."

    # Class name utility
    cat > src/utils/cn.js << 'EOF'
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}
EOF

    # Theme utility
    cat > src/utils/theme.js << 'EOF'
// Theme switching utilities for DaisyUI
export function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);
}

export function getTheme() {
  return localStorage.getItem('theme') || 'light';
}

export function toggleTheme() {
  const current = getTheme();
  const newTheme = current === 'light' ? 'dark' : 'light';
  setTheme(newTheme);
  return newTheme;
}

// Initialize theme on page load
export function initTheme() {
  const savedTheme = getTheme();
  setTheme(savedTheme);
}
EOF

    log "✅ Utility functions created"
}

# Create standard components
create_standard_components() {
    local framework="$1"

    log "Creating standard components for $framework..."

    case "$framework" in
        "astro")
            create_astro_components
            ;;
        "vue")
            create_vue_components
            ;;
        "react")
            create_react_components
            ;;
        *)
            log "Framework not supported for component generation"
            ;;
    esac
}

# Create Astro components (Official DaisyUI v5 patterns)
create_astro_components() {
    # Button component with official DaisyUI v5 classes
    cat > src/components/ui/Button.astro << 'EOF'
---
export interface Props {
  variant?: 'primary' | 'secondary' | 'accent' | 'ghost' | 'link' | 'neutral';
  size?: 'xs' | 'sm' | 'md' | 'lg';
  loading?: boolean;
  disabled?: boolean;
  active?: boolean;
  type?: 'button' | 'submit' | 'reset';
  class?: string;
}

const {
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled = false,
  active = false,
  type = 'button',
  class: className = '',
  ...props
} = Astro.props;

// Official DaisyUI v5 class names
const variants = {
  primary: 'btn-primary',
  secondary: 'btn-secondary',
  accent: 'btn-accent',
  ghost: 'btn-ghost',
  link: 'btn-link',
  neutral: 'btn-neutral'
};

const sizes = {
  xs: 'btn-xs',
  sm: 'btn-sm',
  md: 'btn-md',
  lg: 'btn-lg'
};

const classes = [
  'btn',
  variants[variant],
  sizes[size],
  loading && 'loading',
  active && 'btn-active',
  className
].filter(Boolean).join(' ');
---

<button
  type={type}
  disabled={disabled || loading}
  class={classes}
  {...props}
>
  {loading ? (
    <span class="loading loading-spinner loading-sm"></span>
  ) : (
    <slot />
  )}
</button>
EOF

    # Card component
    cat > src/components/ui/Card.astro << 'EOF'
---
export interface Props {
  class?: string;
  title?: string;
  compact?: boolean;
}

const {
  class: className = '',
  title,
  compact = false
} = Astro.props;
---

<div class={`card bg-base-100 shadow-xl ${compact ? 'card-compact' : ''} ${className}`}>
  <div class="card-body">
    {title && <h2 class="card-title">{title}</h2>}
    <slot />
  </div>
</div>
EOF

    log "✅ Astro components created"
}

# Update Astro config if needed
update_astro_config() {
    if [[ -f "astro.config.mjs" ]]; then
        log "Updating Astro configuration..."

        # Backup original config
        cp astro.config.mjs astro.config.mjs.backup

        cat > astro.config.mjs << 'EOF'
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import alpinejs from '@astrojs/alpinejs';

export default defineConfig({
  integrations: [
    tailwind({
      applyBaseStyles: false, // We handle this in globals.css
    }),
    alpinejs()
  ],
  vite: {
    server: {
      host: '0.0.0.0',
      port: 4321,
    },
  },
});
EOF

        log "✅ Astro configuration updated"
    fi
}

# Main setup function
main() {
    log "🚀 Starting frontend standardization setup..."

    # Detect framework
    local framework=$(detect_framework)
    log "Detected framework: $framework"

    # Create directory structure
    create_directory_structure

    # Install dependencies
    install_dependencies "$framework"

    # Create configuration files
    create_tailwind_config "$framework"
    create_vite_config "$framework"

    # Create styles and utilities
    create_global_styles
    create_utilities

    # Create standard components
    create_standard_components "$framework"

    # Framework-specific setup
    case "$framework" in
        "astro")
            update_astro_config
            ;;
    esac

    log "✅ Frontend standardization setup complete!"
    log ""
    log "📋 Next steps:"
    log "   1. Import globals.css in your main layout/app file"
    log "   2. Customize colors in tailwind.config.js for your project"
    log "   3. Start using standardized components from src/components/ui/"
    log "   4. Build consistent features following the directory structure"
    log ""
    log "🎨 Standardized stack ready:"
    log "   - Tailwind CSS v4.1+ with DaisyUI themes"
    log "   - PrimeUI for advanced components"
    log "   - Alpine.js for reactive interactions"
    log "   - Consistent directory structure"
    log "   - Standard component patterns"
}

# Command line options
case "${1:-setup}" in
    "setup")
        main
        ;;
    "deps-only")
        framework=$(detect_framework)
        install_dependencies "$framework"
        ;;
    "config-only")
        framework=$(detect_framework)
        create_tailwind_config "$framework"
        create_vite_config "$framework"
        ;;
    "help"|"-h"|"--help")
        echo "Frontend Standardization Setup"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  setup      Complete frontend setup (default)"
        echo "  deps-only  Install dependencies only"
        echo "  config-only Create configuration files only"
        echo "  help       Show this help message"
        ;;
    *)
        error "Unknown command: $1. Use '$0 help' for usage information."
        ;;
esac