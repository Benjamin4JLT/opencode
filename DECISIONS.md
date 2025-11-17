# Container Implementation Decisions

**Project:** OpenCode Containerization  
**Date Started:** November 17, 2025

---

## Decision Log

### 1. Base Image Selection

**Decision:** Use `oven/bun:1.3.2` (official Bun Docker image)

**Date:** November 17, 2025

**Context:**
- OpenCode uses Bun 1.3.2 as runtime/package manager
- Need official, well-maintained base image
- Size and performance are important

**Options Considered:**
1. **oven/bun:1.3.2** ⭐ SELECTED
   - Pros: Official, optimized, version-matched
   - Cons: Slightly larger than Alpine variants
   
2. **oven/bun:1.3.2-alpine**
   - Pros: Smaller size
   - Cons: Potential compatibility issues, less tested
   
3. **node:22 + Bun install**
   - Pros: More familiar to Node.js users
   - Cons: Inefficient, larger, slower
   
4. **debian:slim + Bun install**
   - Pros: Full control
   - Cons: Manual setup, maintenance burden

**Rationale:**
- Official images are better maintained
- Version match with package.json (1.3.2)
- Good balance of size and compatibility
- Can switch to alpine variant later if needed

**Impact:** Foundation for all container images

---

### 2. Web Terminal Choice

**Decision:** Use `ttyd` for web-based terminal

**Date:** November 17, 2025

**Context:**
- Need browser-accessible terminal
- OpenCode is terminal-first application
- Security and simplicity are priorities

**Options Considered:**
1. **ttyd** ⭐ SELECTED
   - Pros: Simple, lightweight, reliable, WebSocket-based
   - Cons: Basic authentication only
   - Port: 7681 (default)
   
2. **Wetty**
   - Pros: Better UI, SSH-based auth
   - Cons: More complex setup, heavier
   - Port: 3000
   
3. **Gotty**
   - Pros: Written in Go, good performance
   - Cons: Less actively maintained
   - Port: 8080
   
4. **Custom Xterm.js**
   - Pros: Full control, professional appearance
   - Cons: Significant development effort
   - Port: Custom

**Rationale:**
- Start simple, iterate later
- ttyd is battle-tested and reliable
- Easy to add authentication later
- Can upgrade to Wetty or custom solution if needed

**Impact:** How users access OpenCode in the browser

**Future Consideration:** May upgrade to Wetty for better UX

---

### 3. Build Strategy

**Decision:** Multi-stage Docker build

**Date:** November 17, 2025

**Context:**
- Need optimized image size
- Want fast rebuilds
- Separate build and runtime dependencies

**Approach:**
```dockerfile
Stage 1: deps    - Install dependencies only
Stage 2: builder - Build the application
Stage 3: runner  - Minimal runtime image
```

**Benefits:**
- ✅ Smaller final image (no dev dependencies)
- ✅ Better layer caching (faster rebuilds)
- ✅ More secure (no build tools in production)
- ✅ Clear separation of concerns

**Trade-offs:**
- Slightly more complex Dockerfile
- Longer initial build time
- More disk space during build

**Rationale:**
- Industry best practice
- Worth the complexity for production use
- Can simplify for development if needed

**Impact:** Image size, build time, security posture

---

### 4. Monorepo Handling

**Decision:** Build entire monorepo, run specific packages

**Date:** November 17, 2025

**Context:**
- OpenCode is a Turbo monorepo
- Multiple interdependent packages
- Need to determine what to include

**Approach:**
- Copy entire workspace into container
- Let Turbo handle dependency resolution
- Use workspace protocol for local packages
- Run specific package commands

**Alternatives Considered:**
1. **Extract single package** - Too complex, breaks dependencies
2. **Build all, include all** - Wasteful, larger image
3. **Build only needed packages** ⭐ - Requires careful analysis

**Current Status:** TBD - need to test if full monorepo is required

**Impact:** Image size, build complexity, maintenance

---

### 5. Port Allocation

**Decision:** Standard port mapping

**Date:** November 17, 2025

**Ports:**
- `7681` - Web terminal (ttyd)
- `8080` - OpenCode main application
- `3000` - Console UI (if needed)
- `XXXX` - LSP server (TBD)

**Rationale:**
- Standard ports for services
- Avoid conflicts with common services
- Easy to remember and document
- Configurable via environment variables

**Configuration:**
```env
TTYD_PORT=7681
APP_PORT=8080
CONSOLE_PORT=3000
```

**Impact:** Network configuration, user access patterns

---

### 6. Security Approach

**Decision:** Defense in depth with practical defaults

**Date:** November 17, 2025

**Strategy:**
1. **User Isolation**
   - Run as non-root user `opencode` (UID 1000)
   - Home directory: `/home/opencode`
   
2. **Filesystem**
   - Read-only root filesystem where possible
   - Writable volumes only where needed
   
3. **Capabilities**
   - Drop all capabilities
   - Add back only what's required
   
4. **Network**
   - No unnecessary external access
   - Firewall-ready configuration
   
5. **Secrets**
   - Environment variables only
   - No hardcoded credentials
   - Support for Docker secrets
   
6. **Authentication**
   - Basic auth for ttyd (initial)
   - Upgrade to OAuth2/OIDC later

**Trade-offs:**
- Some convenience for security
- May need adjustments for specific use cases

**Impact:** Security posture, compliance, user trust

---

### 7. Data Persistence

**Decision:** Volume mounts for stateful data

**Date:** November 17, 2025

**Approach:**
```yaml
volumes:
  - opencode-data:/home/opencode/.opencode
  - opencode-config:/home/opencode/.config
```

**What to Persist:**
- [ ] OpenCode configuration
- [ ] User preferences
- [ ] Chat history (if applicable)
- [ ] Workspace data
- [ ] API key cache (encrypted)

**What NOT to Persist:**
- Temporary files
- Build artifacts
- Logs (use log aggregation instead)

**Impact:** Data durability, container lifecycle, backups

---

### 8. Environment Configuration

**Decision:** Separate development and production configs

**Date:** November 17, 2025

**Files:**
- `.env.example` - Template with all variables
- `.env` - Local development (gitignored)
- `.env.production` - Production settings

**Required Variables:**
```env
# AI Providers
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GOOGLE_API_KEY=

# Application
LOG_LEVEL=info
NODE_ENV=production

# Ports
TTYD_PORT=7681
APP_PORT=8080

# Security
TTYD_CREDENTIALS=  # username:password
```

**Impact:** Configuration management, deployment process

---

## Questions Awaiting Decision

### 1. Single vs Multi-Container
**Status:** TBD  
**Question:** Should OpenCode and web terminal be in same container?

**Option A:** Single container (simpler)
**Option B:** Separate containers (more flexible)

**Next Step:** Test with single container first

---

### 2. Deployment Platform
**Status:** TBD  
**Options:**
- AWS ECS/Fargate
- Google Cloud Run
- DigitalOcean App Platform
- Self-hosted VPS
- Kubernetes

**Next Step:** Evaluate based on requirements and budget

---

### 3. CI/CD Platform
**Status:** TBD  
**Options:**
- GitHub Actions (likely choice - already has workflows)
- GitLab CI
- CircleCI
- Jenkins

**Next Step:** Start with GitHub Actions

---

### 4. Monitoring Strategy
**Status:** TBD  
**Options:**
- Prometheus + Grafana
- Datadog
- New Relic
- Simple health checks

**Next Step:** Start with health checks, add monitoring later

---

## Decision Criteria

When making future decisions, consider:

1. **Simplicity** - Start simple, iterate
2. **Security** - Never compromise on security
3. **Modularity** - Keep components decoupled
4. **Standards** - Follow industry best practices
5. **Documentation** - Document all decisions
6. **Reversibility** - Prefer reversible decisions
7. **Cost** - Consider long-term costs
8. **Maintenance** - Consider ongoing maintenance burden

---

## Review Schedule

- **Weekly:** Review pending decisions
- **Monthly:** Revisit completed decisions
- **Quarterly:** Re-evaluate major architectural choices

---

**Last Updated:** November 17, 2025  
**Next Review:** November 24, 2025

