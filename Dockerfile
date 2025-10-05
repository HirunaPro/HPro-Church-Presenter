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

# Copy application files
COPY . .

# Make sure scripts are executable
RUN chmod +x startup.sh 2>/dev/null || true

# Expose ports
# Port 8080 for HTTP (Azure Container Instances default)
# Port 8765 for WebSocket
EXPOSE 8080 8765

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8080
ENV HTTP_PORT=8080
ENV WEBSOCKET_PORT=8765

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/index.html')" || exit 1

# Run the optimized server
CMD ["python", "-u", "server-optimized.py"]
