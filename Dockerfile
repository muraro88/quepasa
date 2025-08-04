# =================================================================
# Estágio 1: Builder
# =================================================================
FROM golang:1.23-bullseye AS builder

# Instala as ferramentas de build necessárias
RUN apt-get update && apt-get install -y git gcc libc-dev

WORKDIR /app

# Copia TODO o projeto (inclui migrations, main.go, etc)
COPY . ./

# Baixa dependências
RUN go mod download

# Ativa o CGO para compilar a dependência do SQLite
ENV CGO_ENABLED=1

# Compila a aplicação como um binário estático
RUN go build -ldflags '-w -s -extldflags "-static"' -tags netgo,osuser -o /quepasa main.go

# =================================================================
# Estágio 2: Imagem Final
# =================================================================
FROM alpine:3.18

# Instala as dependências de execução (ffmpeg)
RUN apk add --no-cache ffmpeg

WORKDIR /app

# Copia o binário compilado
COPY --from=builder /quepasa ./

# Copia a pasta de migrações
COPY --from=builder /app/migrations ./migrations

# Porta da aplicação
EXPOSE 31000

# Comando de entrada
ENTRYPOINT ["/app/quepasa"]
