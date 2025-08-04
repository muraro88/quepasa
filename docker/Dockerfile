# Dockerfile para diagnóstico
FROM golang:1.22-bullseye AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    gcc \
    g++ \
    libc-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY src/go.mod src/go.sum ./
RUN go mod download && go mod verify

COPY src/ ./
ENV CGO_ENABLED=1
RUN go build -ldflags="-w -s" -o quepasa main.go

FROM alpine:3.18
RUN apk add --no-cache ffmpeg ca-certificates tzdata postgresql-client

WORKDIR /app
COPY --from=builder /app/quepasa ./quepasa

# Copia migrações e lista o conteúdo para debug
COPY docker/postgres/migrations ./migrations

# Script de debug que mostra o que existe
RUN echo '#!/bin/sh' > /app/debug.sh && \
    echo 'echo "=== DEBUG INFO ==="' >> /app/debug.sh && \
    echo 'echo "📁 Current directory contents:"' >> /app/debug.sh && \
    echo 'ls -la .' >> /app/debug.sh && \
    echo '' >> /app/debug.sh && \
    echo 'echo "📂 Migrations directory:"' >> /app/debug.sh && \
    echo 'if [ -d "./migrations" ]; then' >> /app/debug.sh && \
    echo '  ls -la ./migrations/' >> /app/debug.sh && \
    echo '  echo "📄 Migration files count: $(ls ./migrations/*.sql 2>/dev/null | wc -l)"' >> /app/debug.sh && \
    echo 'else' >> /app/debug.sh && \
    echo '  echo "❌ Migrations directory NOT found"' >> /app/debug.sh && \
    echo 'fi' >> /app/debug.sh && \
    echo '' >> /app/debug.sh && \
    echo 'echo "🔧 Environment variables:"' >> /app/debug.sh && \
    echo 'echo "DATABASE_URL: ${DATABASE_URL:0:20}..."' >> /app/debug.sh && \
    echo 'echo "MIGRATIONS: $MIGRATIONS"' >> /app/debug.sh && \
    echo '' >> /app/debug.sh && \
    echo 'echo "🚀 Starting application..."' >> /app/debug.sh && \
    echo './quepasa' >> /app/debug.sh && \
    chmod +x /app/debug.sh

EXPOSE 8080
CMD ["./debug.sh"]
