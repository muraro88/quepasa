# =================================================================
# Estágio 1: Builder
# =================================================================
FROM golang:1.23-bullseye AS builder

RUN apt-get update && apt-get install -y git gcc libc-dev
WORKDIR /app

# 1) copia apenas go.mod e go.sum para instalar deps
COPY go.mod go.sum ./

# 2) baixa as dependências (usa cache se não mudar go.mod)
RUN go mod download

# 3) agora copia TODO o restante do código, incluindo migrations/
COPY . ./

# ativa CGO (para SQLite) e compila
ENV CGO_ENABLED=1
RUN go build -ldflags '-w -s -extldflags "-static"' -tags netgo,osuser -o /quepasa main.go

# =================================================================
# Estágio 2: Imagem Final
# =================================================================
FROM alpine:3.18

RUN apk add --no-cache ffmpeg
WORKDIR /app

COPY --from=builder /quepasa ./
COPY --from=builder /app/migrations ./migrations

EXPOSE 31000
ENTRYPOINT ["/app/quepasa"]
