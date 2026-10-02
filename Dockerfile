# syntax=docker/dockerfile:1.4
FROM --platform=linux/amd64 python:3.12.13-slim as builder

WORKDIR /app

# Install system dependencies for building wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Create wheels for all dependencies (optimizes final image size)
RUN pip install --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Stage 2: Runtime Stage
FROM --platform=linux/amd64 python:3.12.13-slim

WORKDIR /app

# Install runtime dependencies including ODBC driver with explicit retries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unixodbc \
        unixodbc-dev \
        gnupg \
        curl \
        apt-transport-https \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC driver in a separate layer
RUN curl --retry 3 --retry-delay 2 https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    echo "deb [arch=amd64,arm64] https://packages.microsoft.com/debian/12/prod bookworm main" | tee /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 && \
    rm -rf /var/lib/apt/lists/*

# Copy wheels from builder stage
COPY --from=builder /app/wheels /wheels

# Copy application code
COPY . .

# Install Python dependencies from wheels
RUN pip install --no-cache /wheels/* && \
    rm -rf /wheels

# Create a non-root user for security
RUN useradd -m -u 1000 streamlit && chown -R streamlit:streamlit /app
USER streamlit

# Expose port for Streamlit
EXPOSE 8501

# Health check for Azure Container Apps
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Configure Streamlit to run properly in container
ENV STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_SERVER_PORT=8501 \
    STREAMLIT_SERVER_ADDRESS=0.0.0.0 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Run the application
ENTRYPOINT ["streamlit", "run", "src/ui.py"]
