# OpenCode Containerized with Web Terminal
# Multi-stage build for optimized image size

# =============================================================================
# Stage 1: Dependencies
# =============================================================================
FROM oven/bun:1.3.2 AS deps

WORKDIR /app

# Copy package files
COPY package.json bun.lock bunfig.toml ./
COPY turbo.json tsconfig.json ./

# Copy workspace package.json files
COPY packages/opencode/package.json ./packages/opencode/
COPY packages/console/package.json ./packages/console/ 2>/dev/null || true
COPY packages/sdk/js/package.json ./packages/sdk/js/ 2>/dev/null || true

# Install dependencies
RUN bun install --frozen-lockfile

# =============================================================================
# Stage 2: Builder
# =============================================================================
FROM oven/bun:1.3.2 AS builder

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json

# Copy source code
COPY . .

# Build the application
# Note: OpenCode may not need a build step, but including for completeness
RUN bun run typecheck || true

# =============================================================================
# Stage 3: Runtime with Web Terminal
# =============================================================================
FROM oven/bun:1.3.2-slim AS runner

# Install ttyd for web-based terminal access
RUN apt-get update && apt-get install -y \
    ttyd \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built application from builder
COPY --from=builder /app ./

# Create non-root user for security
RUN groupadd -r opencode -g 1000 && \
    useradd -r -g opencode -u 1000 -m -s /bin/bash opencode && \
    chown -R opencode:opencode /app

# Create directories for data persistence
RUN mkdir -p /home/opencode/.opencode \
    /home/opencode/.config/opencode \
    /app/data \
    /app/logs && \
    chown -R opencode:opencode /home/opencode /app/data /app/logs

# Switch to non-root user
USER opencode

# Set environment variables
ENV NODE_ENV=production \
    PORT=8080 \
    TTYD_PORT=7681 \
    PATH="/app/node_modules/.bin:${PATH}"

# Expose ports
# 7681 - Web terminal (ttyd)
# 8080 - OpenCode application
# 3000 - Console UI (if applicable)
EXPOSE 7681 8080 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${TTYD_PORT}/ || exit 1

# Volume for persistent data
VOLUME ["/home/opencode/.opencode", "/app/data"]

# Default: Start web terminal that runs OpenCode
# The -W flag makes ttyd wait for the command
# Use -c for basic auth: ttyd -c username:password
CMD ["sh", "-c", "ttyd -p ${TTYD_PORT} -W bun run dev"]

# Alternative startup commands (uncomment as needed):

# Option 1: Run OpenCode directly (no web terminal)
# CMD ["bun", "run", "dev"]

# Option 2: Run with authentication
# CMD ["sh", "-c", "ttyd -p ${TTYD_PORT} -c ${TTYD_CREDENTIALS:-admin:changeme} -W bun run dev"]

# Option 3: Run OpenCode in background + web terminal on bash
# CMD ["sh", "-c", "bun run dev & ttyd -p ${TTYD_PORT} /bin/bash"]

# Option 4: For production, you might want to run the built output
# CMD ["bun", "run", "--cwd", "packages/opencode", "src/index.ts"]

