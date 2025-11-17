# OpenCode - Container Setup

This fork of OpenCode is configured to run in Docker containers with web-based terminal access.

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- At least one AI provider API key (Anthropic/OpenAI/Google)

### Setup

1. **Configure environment variables:**
   ```bash
   cp env.example .env
   # Edit .env and add your API keys
   ```

2. **Build and run:**
   ```bash
   docker-compose up -d
   ```

3. **Access:**
   - Web Terminal: http://localhost:7681
   - OpenCode App: http://localhost:8080 (if applicable)

## 📋 What's Included

### Files Created
- ✅ `Dockerfile` - Multi-stage build for Bun application
- ✅ `docker-compose.yml` - Container orchestration
- ✅ `.dockerignore` - Build optimization
- ✅ `env.example` - Environment variable template
- ✅ `CONTAINER_NOTES.md` - Implementation notes
- ✅ `DECISIONS.md` - Architecture decisions
- ✅ `README.container.md` - This file

### Features
- 🐳 **Multi-stage Docker build** - Optimized image size
- 💻 **Web terminal** - Browser-based access via ttyd
- 🔒 **Security hardened** - Non-root user, dropped capabilities
- 📦 **Persistent storage** - Data volumes for configuration
- 🔄 **Health checks** - Automatic container monitoring
- 🚀 **Production ready** - Resource limits, logging, restart policies

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Docker Container                │
│  ┌────────────────────────────────┐    │
│  │  Web Terminal (ttyd)           │    │
│  │  Port: 7681                    │    │
│  │  Access: http://localhost:7681 │    │
│  └────────────────────────────────┘    │
│                                         │
│  ┌────────────────────────────────┐    │
│  │  OpenCode (Bun Runtime)        │    │
│  │  Port: 8080                    │    │
│  │  Command: bun run dev          │    │
│  └────────────────────────────────┘    │
│                                         │
│  Running as: opencode:opencode (1000)  │
│  Base Image: oven/bun:1.3.2-slim       │
└─────────────────────────────────────────┘
```

## 🔧 Configuration

### Environment Variables

Key variables in `env.example`:

```env
# Required: At least one AI provider
ANTHROPIC_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
GOOGLE_API_KEY=your_key_here

# Application
NODE_ENV=production
LOG_LEVEL=info
APP_PORT=8080

# Web Terminal
TTYD_PORT=7681
TTYD_CREDENTIALS=admin:changeme  # CHANGE THIS!
```

### Ports

| Port | Service | Description |
|------|---------|-------------|
| 7681 | ttyd | Web-based terminal |
| 8080 | OpenCode | Main application |
| 3000 | Console | Web UI (if applicable) |

### Volumes

Persistent data is stored in Docker volumes:

```yaml
volumes:
  - opencode-data:/home/opencode/.opencode      # OpenCode data
  - opencode-config:/home/opencode/.config      # Configuration
  - opencode-app-data:/app/data                 # Application data
```

## 📝 Common Commands

### Development

```bash
# Start in foreground (see logs)
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f opencode

# Rebuild after changes
docker-compose up -d --build

# Stop containers
docker-compose down

# Stop and remove volumes (CAUTION: deletes data)
docker-compose down -v
```

### Container Management

```bash
# Enter the container
docker exec -it opencode-web-terminal /bin/bash

# Run commands as opencode user
docker exec -it -u opencode opencode-web-terminal bun run dev

# Check container status
docker-compose ps

# View resource usage
docker stats opencode-web-terminal

# Inspect container
docker inspect opencode-web-terminal
```

### Maintenance

```bash
# Restart container
docker-compose restart

# Pull latest base images
docker-compose pull

# Rebuild from scratch (no cache)
docker-compose build --no-cache

# Prune unused Docker resources
docker system prune -a
```

## 🔒 Security

### Authentication

By default, the web terminal uses basic authentication:
- Username: admin
- Password: changeme

**IMPORTANT:** Change this in production!

```env
TTYD_CREDENTIALS=your_username:your_password
```

### Best Practices

1. **Never commit `.env` file** - It's gitignored
2. **Use strong credentials** - Change default passwords
3. **Limit network exposure** - Use firewall rules
4. **Keep images updated** - Regularly rebuild with latest base images
5. **Review logs** - Monitor for suspicious activity
6. **Use HTTPS** - Add nginx reverse proxy with SSL

### SSL/TLS Setup

For production, add nginx reverse proxy:

1. Uncomment nginx service in `docker-compose.yml`
2. Create `nginx.conf` with SSL configuration
3. Add SSL certificates to `./ssl/` directory

## 🐛 Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs

# Check if ports are in use
lsof -i :7681
lsof -i :8080

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Can't Access Web Terminal

1. Verify container is running: `docker-compose ps`
2. Check logs: `docker-compose logs opencode`
3. Test locally: `curl http://localhost:7681`
4. Check firewall settings
5. Verify port mappings in `docker-compose.yml`

### Permission Errors

```bash
# Fix volume permissions
docker-compose down
docker volume rm opencode-data opencode-config opencode-app-data
docker-compose up -d
```

### Build Failures

1. Check internet connection (needed for downloading packages)
2. Verify Bun version matches in `package.json`
3. Clear Docker cache: `docker builder prune -a`
4. Check disk space: `df -h`

### High Memory Usage

Adjust resource limits in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      memory: 2G  # Reduce this value
```

## 🚀 Deployment

### Local Development
Already set up! Use `docker-compose up -d`

### Cloud Platforms

#### DigitalOcean
```bash
# Push to container registry
docker tag opencode-web-terminal registry.digitalocean.com/your-registry/opencode
docker push registry.digitalocean.com/your-registry/opencode

# Deploy via App Platform or Droplet
```

#### AWS ECS
```bash
# Push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker tag opencode-web-terminal <account-id>.dkr.ecr.us-east-1.amazonaws.com/opencode:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/opencode:latest
```

#### Google Cloud Run
```bash
# Push to GCR
docker tag opencode-web-terminal gcr.io/<project-id>/opencode
docker push gcr.io/<project-id>/opencode
gcloud run deploy opencode --image gcr.io/<project-id>/opencode
```

## 📊 Monitoring

### Health Checks

Built-in health check runs every 30 seconds:

```bash
# Manual health check
curl http://localhost:7681/

# View health status
docker inspect --format='{{.State.Health.Status}}' opencode-web-terminal
```

### Logs

Logs are configured with rotation:
- Max size: 10MB
- Max files: 3
- Compressed: Yes

### Metrics

Add monitoring services in `docker-compose.yml`:
- Prometheus
- Grafana
- cAdvisor

## 🔄 Updating

### From Upstream

```bash
# Fetch upstream changes
git fetch upstream

# Merge into your branch
git merge upstream/main

# Rebuild container
docker-compose up -d --build
```

### Dependencies

```bash
# Update Bun packages inside container
docker exec -it opencode-web-terminal bun update

# Or rebuild with latest versions
docker-compose build --no-cache
```

## 📚 Additional Resources

- [Main Planning Document](../WebAgent/OPENCODE_FORK_PLAN.md)
- [Container Notes](CONTAINER_NOTES.md)
- [Architecture Decisions](DECISIONS.md)
- [OpenCode Docs](https://opencode.ai/docs)
- [Docker Docs](https://docs.docker.com/)
- [Bun Docs](https://bun.sh/docs)

## 🆘 Getting Help

1. Check [troubleshooting](#-troubleshooting) section above
2. Review container logs: `docker-compose logs`
3. Check OpenCode GitHub issues
4. Review Docker documentation
5. Check Bun documentation

## 📄 License

Same as OpenCode - MIT License

---

**Status:** Initial setup complete ✅  
**Last Updated:** November 17, 2025  
**Version:** 1.0.0

