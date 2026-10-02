# syntax=docker/dockerfile:1.4
FROM --platform=linux/amd64 python:3.12.13-slim as builder

WORKDIR /app

# Install only build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install Python dependencies directly (no wheels needed for this size)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime Stage - Final image
FROM --platform=linux/amd64 python:3.12.13-slim

WORKDIR /app

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    unixodbc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Microsoft ODBC driver
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends gnupg ca-certificates; \
    curl --fail --retry 3 --retry-delay 2 --location https://packages.microsoft.com/keys/microsoft.asc -o /tmp/microsoft.asc; \
    gpg --dearmor < /tmp/microsoft.asc > /etc/apt/trusted.gpg.d/microsoft.gpg; \
    echo "deb [arch=amd64] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18; \
    rm -f /tmp/microsoft.asc; \
    rm -rf /var/lib/apt/lists/*

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# Copy application code
COPY . .

# Create non-root user
RUN useradd -m -u 1000 streamlit && chown -R streamlit:streamlit /app
USER streamlit

EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

ENV STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_SERVER_PORT=8501 \
    STREAMLIT_SERVER_ADDRESS=0.0.0.0 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ENTRYPOINT ["streamlit", "run", "src/ui.py"]
