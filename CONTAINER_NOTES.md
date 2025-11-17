# OpenCode Containerization Notes

**Fork Date:** November 17, 2025  
**Forked From:** https://github.com/sst/opencode  
**Fork URL:** https://github.com/Benjamin4JLT/opencode

---

## Project Analysis

### Technology Stack
- **Runtime:** Bun 1.3.2 (TypeScript-based, NOT Go)
- **Package Manager:** Bun
- **Type:** Monorepo with workspaces
- **Build Tool:** Turbo
- **Framework:** Hono (API), SolidJS (Frontend)
- **Infrastructure:** SST (Serverless Stack)

### Project Structure
```
opencode/
├── packages/
│   ├── opencode/       # Main CLI package
│   ├── console/        # Web console UI
│   ├── sdk/           # SDK packages
│   └── ...
├── infra/             # Infrastructure as code
├── script/            # Build and utility scripts
├── package.json       # Root package config
└── bun.lock          # Lock file
```

### Entry Points
- **Main Entry:** `packages/opencode/src/index.ts`
- **Dev Command:** `bun dev`
- **Working Directory:** `packages/opencode`

### Dependencies (Key)
- TypeScript 5.8.2
- Hono 4.7.10 (Web framework)
- SolidJS 1.9.9 (UI framework)
- AI SDK 5.0.8
- Zod 4.1.8 (Validation)
- Vite 7.1.4 (Build tool)

### Ports & Services
- **To Determine:** Need to check actual runtime configuration
- Likely uses:
  - Main app port (typically 3000-8080)
  - Console/web UI port
  - LSP server port

### Environment Variables
- **To Document:** Check packages/opencode for required env vars
- Likely needs:
  - AI provider credentials (Anthropic, OpenAI, Google)
  - Database connection (if applicable)
  - Configuration paths

---

## Docker Strategy

### Base Image Decision
**Selected:** `oven/bun:1.3.2` (official Bun Docker image)

**Alternatives Considered:**
- Node.js + Bun install: Less efficient
- Debian + Bun install: Larger image

**Rationale:** Official Bun image is optimized and regularly updated

### Build Strategy
**Multi-stage build:**
1. **Stage 1 (deps):** Install dependencies only
2. **Stage 2 (builder):** Build the application
3. **Stage 3 (runner):** Minimal runtime image

**Benefits:**
- Smaller final image
- Faster rebuilds (layer caching)
- No dev dependencies in production

### Web Terminal Integration
**Selected:** ttyd

**Port Allocation:**
- ttyd: 7681
- OpenCode app: 8080 (configurable)
- Console UI: 3000 (if exposed)

---

## Container Architecture

```
┌─────────────────────────────────────────┐
│         Docker Container                │
│                                         │
│  ┌────────────────────────────────┐    │
│  │  Web Terminal (ttyd)           │    │
│  │  Port: 7681                    │    │
│  └────────────────────────────────┘    │
│                                         │
│  ┌────────────────────────────────┐    │
│  │  OpenCode CLI                  │    │
│  │  (Bun runtime)                 │    │
│  └────────────────────────────────┘    │
│                                         │
│  ┌────────────────────────────────┐    │
│  │  Optional: Console UI          │    │
│  │  Port: 3000                    │    │
│  └────────────────────────────────┘    │
│                                         │
│  Running as non-root user: opencode    │
│  Base: oven/bun:1.3.2-slim             │
└─────────────────────────────────────────┘
```

---

## Implementation Phases

### ✅ Phase 1: Repository Setup (COMPLETE)
- [x] Fork repository
- [x] Clone locally
- [x] Set up upstream remote
- [x] Verify git configuration

### 🔄 Phase 2: Analysis & Planning (IN PROGRESS)
- [x] Identify technology stack
- [x] Document project structure
- [x] Choose base image
- [x] Plan Docker strategy
- [ ] Identify runtime requirements
- [ ] Document all required ports
- [ ] List all environment variables

### ⏳ Phase 3: Docker Configuration (NEXT)
- [ ] Create .dockerignore
- [ ] Create .env.example
- [ ] Create Dockerfile
- [ ] Create docker-compose.yml
- [ ] Test local build

### ⏳ Phase 4: Testing & Validation
- [ ] Build Docker image
- [ ] Test OpenCode functionality
- [ ] Test web terminal access
- [ ] Verify all features work
- [ ] Performance testing

### ⏳ Phase 5: Security Hardening
- [ ] Non-root user execution
- [ ] Drop unnecessary capabilities
- [ ] Security scanning (Trivy)
- [ ] Add authentication to terminal
- [ ] SSL/TLS configuration

### ⏳ Phase 6: Documentation
- [ ] Update README with container instructions
- [ ] Document environment variables
- [ ] Create deployment guide
- [ ] Troubleshooting guide

### ⏳ Phase 7: Deployment
- [ ] Choose deployment platform
- [ ] Set up CI/CD
- [ ] Deploy to staging
- [ ] Production deployment

---

## Questions to Answer

### Runtime Configuration
- [ ] What port does OpenCode listen on?
- [ ] Does it need a database?
- [ ] What AI providers are required?
- [ ] What are the minimal resource requirements?

### Build Configuration
- [ ] Does the full monorepo need to be built?
- [ ] Can we build just the CLI package?
- [ ] What build outputs are needed?
- [ ] Are there any build-time secrets?

### Security
- [ ] What credentials are needed?
- [ ] How are API keys managed?
- [ ] What network access is required?
- [ ] Any special filesystem permissions?

---

## Next Actions

1. **Explore packages/opencode** - Understand main app
2. **Check for config files** - Find runtime configuration
3. **Identify ports** - Determine what needs to be exposed
4. **List env vars** - Document required configuration
5. **Create .dockerignore** - Optimize build context
6. **Create Dockerfile** - Implement multi-stage build
7. **Test locally** - Verify everything works

---

## Notes

- OpenCode is actively developed - expect frequent upstream changes
- Uses client/server architecture - may need multiple containers
- LSP support means editor protocol handling
- Terminal-focused UI - perfect for web terminal integration
- Bun is faster than Node.js - good for containers

---

**Last Updated:** November 17, 2025  
**Status:** Analysis phase - gathering requirements

