# Docker Container Deployment Guide

Deploy the Church Presentation App using Docker containers for consistent, isolated environments.

## Overview

Docker allows you to run the Church Presentation App in a containerized environment. This ensures consistency across different machines and simplifies deployment.

**Perfect for:**
- Development environments
- Testing before cloud deployment
- Local deployment with isolation
- Multi-container setups
- Learning containerization

---

## Prerequisites

1. **Docker Desktop Installed**
   - Windows: [Download Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - macOS: [Download Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
   - Linux: [Install Docker Engine](https://docs.docker.com/engine/install/)

2. **Docker Running**
   - Windows/macOS: Start Docker Desktop
   - Linux: Ensure Docker daemon is running
   ```bash
   docker --version
   ```

3. **Docker Compose** (optional, for easier multi-container setup)
   - Usually comes with Docker Desktop
   ```bash
   docker-compose --version
   ```

---

## Quick Start

### Option 1: Using Docker Compose (Recommended)

**Simplest method - runs everything with one command:**

```bash
cd deployment/docker
docker-compose up
```

Access the app at: `http://localhost:8000/index.html`

**Stop the container:**
```bash
docker-compose down
```

### Option 2: Using Docker CLI

**Building the image:**
```bash
cd deployment/docker
docker build -t church-app:latest .
```

**Running the container:**
```bash
docker run -p 8000:8000 -p 8765:8765 \
  -v $(pwd)/../../src/songs:/app/src/songs \
  church-app:latest
```

On Windows PowerShell:
```powershell
docker run -p 8000:8000 -p 8765:8765 `
  -v "$PWD\..\..\src\songs:/app/src/songs" `
  church-app:latest
```

Access the app at: `http://localhost:8000/index.html`

---

## Step-by-Step Setup

### 1. Navigate to Docker Directory

```bash
cd deployment/docker
```

### 2. Build the Docker Image

```bash
docker build -t church-app:latest .
```

This creates a Docker image named `church-app` with the tag `latest`.

**Output should show:**
```
[+] Building X.Xsec
[+] SUCCESS
```

### 3. Run the Container

#### Using Docker Compose (Easier)

```bash
docker-compose up
```

#### Using Docker CLI

```bash
docker run -d \
  --name church-app \
  -p 8000:8000 \
  -p 8765:8765 \
  -v $(pwd)/../../src/songs:/app/src/songs \
  church-app:latest
```

Flags:
- `-d` - Run in background
- `--name` - Container name
- `-p` - Port mapping
- `-v` - Volume (mount) songs directory

### 4. Verify Container is Running

```bash
docker ps
```

Should show your `church-app` container with status `Up`.

### 5. Access the Application

Open browser:
```
http://localhost:8000/index.html
```

### 6. Stop the Container

**Using Docker Compose:**
```bash
docker-compose down
```

**Using Docker CLI:**
```bash
docker stop church-app
docker rm church-app
```

---

## Configuration

### Environment Variables

Edit `docker-compose.yml` to customize:

```yaml
environment:
  - HTTP_PORT=8000
  - WEBSOCKET_PORT=8765
  - PYTHONUNBUFFERED=1
```

### Port Mapping

Change exposed ports in `docker-compose.yml`:

```yaml
ports:
  - "8080:8000"  # Access on 8080, app runs on 8000
  - "8765:8765"  # WebSocket port
```

### Volume Mounting

Mount songs directory for easy updates:

```yaml
volumes:
  - ./../../src/songs:/app/src/songs
```

Changes to `src/songs/` on your host are immediately visible in container.

---

## Docker Compose File

### Default Configuration

```yaml
version: '3.8'

services:
  church-presenter:
    build: .
    container_name: church-presentation-app
    ports:
      - "8000:8000"  # HTTP
      - "8765:8765"  # WebSocket
    environment:
      - PORT=8000
      - HTTP_PORT=8000
      - WEBSOCKET_PORT=8765
    volumes:
      - ./../../src/songs:/app/src/songs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/index.html')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s
```

### Customization Examples

**Add environment variable:**
```yaml
environment:
  - HTTP_PORT=8000
  - CHURCH_NAME="My Church"
```

**Change restart policy:**
```yaml
restart: always  # Always restart (production)
restart: on-failure  # Only on failure
```

**Add resource limits:**
```yaml
deploy:
  resources:
    limits:
      cpus: '1'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
```

---

## Common Tasks

### View Container Logs

**Using Docker Compose:**
```bash
docker-compose logs -f
```

**Using Docker CLI:**
```bash
docker logs -f church-app
```

### Access Container Shell

```bash
docker exec -it church-app /bin/bash
```

### Restart Container

**Using Docker Compose:**
```bash
docker-compose restart
```

**Using Docker CLI:**
```bash
docker restart church-app
```

### Remove Container and Image

```bash
# Stop and remove container
docker stop church-app
docker rm church-app

# Remove image
docker rmi church-app:latest
```

### Check Container Health

```bash
docker inspect church-app --format='{{.State.Health.Status}}'
```

---

## Troubleshooting

### "Docker daemon is not running"

**Windows/macOS:**
1. Start Docker Desktop application
2. Wait for Docker to finish initializing
3. Try command again

**Linux:**
```bash
sudo systemctl start docker
```

### "Port already in use"

Another container or application is using port 8000 or 8765.

**Find what's using the port:**
```bash
# Windows
netstat -ano | findstr :8000

# macOS/Linux
lsof -i :8000
```

**Solutions:**
1. Change port mapping in `docker-compose.yml`
2. Stop the other application
3. Run container on different port:
   ```bash
   docker run -p 8080:8000 church-app:latest
   ```

### "Cannot mount volume"

Ensure paths are correct and songs directory exists:

```bash
# Check if songs directory exists
ls -la ../../src/songs

# Use absolute path if relative path fails
docker run -v /absolute/path/to/src/songs:/app/src/songs church-app:latest
```

### "Container exits immediately"

Check logs for errors:

```bash
docker logs church-app
```

Common causes:
- Python module not installed
- Song directory not found
- Port conflict

### "WebSocket connection fails"

Ensure port 8765 is exposed and mapped:

```yaml
ports:
  - "8000:8000"  # HTTP
  - "8765:8765"  # WebSocket (don't forget this!)
```

### Slow song loading

Increase Docker memory allocation:

**Docker Desktop Settings:**
- Windows: Settings → Resources → Memory (set to 4GB+)
- macOS: Docker → Preferences → Resources → Memory (set to 4GB+)

---

## Advanced Usage

### Multi-Container Setup

Run multiple instances for load balancing:

```yaml
version: '3.8'

services:
  church-app-1:
    build: .
    ports:
      - "8000:8000"
      - "8765:8765"
    volumes:
      - ./../../src/songs:/app/src/songs

  church-app-2:
    build: .
    ports:
      - "8001:8000"
      - "8766:8765"
    volumes:
      - ./../../src/songs:/app/src/songs
```

Access on ports 8000 and 8001.

### Custom Dockerfile

Modify `Dockerfile` to customize:

```dockerfile
# Use different Python version
FROM python:3.10-slim

# Add custom packages
RUN apt-get update && apt-get install -y curl

# Set custom environment variables
ENV CHURCH_NAME="My Church"
```

Then rebuild:
```bash
docker build -t church-app:custom .
```

### Push to Docker Hub

Share your image publicly:

```bash
# Tag image
docker tag church-app:latest your-username/church-app:latest

# Login
docker login

# Push
docker push your-username/church-app:latest
```

Others can then run:
```bash
docker run -p 8000:8000 -p 8765:8765 your-username/church-app:latest
```

### Docker Network

Connect multiple containers:

```bash
# Create network
docker network create church-network

# Run containers on network
docker run --network church-network --name app1 church-app:latest
docker run --network church-network --name app2 church-app:latest
```

---

## Performance Optimization

### Build Optimization

For faster builds, use `.dockerignore`:

```
.git
.gitignore
node_modules
__pycache__
*.pyc
build/
dist/
```

### Runtime Optimization

**Use multi-stage build** (already in Dockerfile):
- Smaller final image
- Faster deployment
- Less disk space

**Current size:** ~500MB (Python 3.11 slim base)

### Caching

Docker layers are cached. Structure Dockerfile for efficiency:

```dockerfile
# Cache invalidation - put frequently changing files last
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src ./src  # App code (changes often)
```

---

## Security Best Practices

### Don't run as root

```dockerfile
RUN useradd -m appuser
USER appuser
```

### Use specific versions

```dockerfile
FROM python:3.11-slim  # Good (specific version)
FROM python:latest     # Bad (always changes)
```

### Scan for vulnerabilities

```bash
docker scan church-app:latest
```

### Environment secrets

Use Docker secrets for sensitive data:

```bash
docker secret create db_password secret.txt
```

---

## Comparison: Docker vs Other Methods

| Feature | Docker | Local | Azure | Executable |
|---------|--------|-------|-------|-----------|
| Setup Time | 5-10 min | 5 min | 5 min | 15 min |
| Consistency | ✅ Excellent | ❌ System dependent | ✅ Excellent | ✅ Good |
| Easy Updates | ✅ Yes | ✅ Yes | ⚠️ Rebuild image | ❌ Rebuild exe |
| Cross-Platform | ✅ Yes | ❌ Platform specific | ✅ Yes | ❌ Windows only |
| Production Ready | ✅ Yes | ❌ Development | ✅ Yes | ⚠️ Limited |
| Scaling | ✅ Easy | ❌ Difficult | ✅ Very easy | ❌ No |

---

## Docker vs Azure Container Instances

| Aspect | Docker Local | Azure Container |
|--------|--------------|-----------------|
| Cost | $0 | $0.57/month |
| Setup | Local | Cloud |
| Access | Local network | Internet |
| Maintenance | You manage | Microsoft manages |
| Scaling | Manual | Automatic |
| Best For | Development | Production |

---

## Next Steps

1. **Learn Docker Basics**
   - [Official Docker Tutorial](https://docs.docker.com/guides/getting-started/)
   - [Docker Compose Documentation](https://docs.docker.com/compose/)

2. **Try Docker Compose**
   - Run: `docker-compose up`
   - Stop: `docker-compose down`
   - Modify: Edit `docker-compose.yml`

3. **Scale to Production**
   - For local: Keep using Docker Compose
   - For cloud: Move to [Azure Deployment](../azure/README.md)
   - For distribution: Build [Windows Executable](../pyinstaller/README.md)

4. **Optimize Images**
   - Reduce layer count
   - Use Alpine Linux (smaller base image)
   - Implement health checks

---

## Useful Docker Commands

```bash
# Build
docker build -t church-app:latest .

# Run
docker run -p 8000:8000 church-app:latest

# List containers
docker ps -a

# View logs
docker logs church-app

# Stop container
docker stop church-app

# Remove container
docker rm church-app

# Remove image
docker rmi church-app:latest

# Compose up
docker-compose up -d

# Compose down
docker-compose down

# View compose logs
docker-compose logs -f
```

---

## Support

For Docker-specific issues:
- Check [Docker Documentation](https://docs.docker.com/)
- Review Docker logs: `docker logs church-app`
- Check container health: `docker inspect church-app`

For app-specific issues:
- See [README.md](../../README.md)
- Check other deployment guides
- Review documentation in `docs/`

---

## Version

Docker deployment guide v1.0  
Works with Church Presentation App v2.0+
