# Multi-stage build for Church Presentation App
# Optimized for Azure Container Instances with WebSocket support

FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Final stage
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy Python packages from builder
COPY --from=builder /root/.local /root/.local

# Copy application source code
COPY src ./src
COPY deployment ./deployment
COPY requirements.txt .

# Make sure scripts are executable
RUN chmod +x startup.sh 2>/dev/null || true

# Expose ports
# Port 8000 for HTTP (default)
# Port 8765 for WebSocket
EXPOSE 8000 8765

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
ENV HTTP_PORT=8000
ENV WEBSOCKET_PORT=8765

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/index.html')" || exit 1

# Run the optimized server
CMD ["python", "-u", "src/server/server-optimized.py"]
