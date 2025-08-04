# =================================================================
# Estágio 1: Builder
# =================================================================
FROM golang:1.23-bullseye AS builder

# Instala as ferramentas de build necessárias
RUN apt-get update && apt-get install -y git gcc libc-dev

# Define o WORKDIR
WORKDIR /app

# 1) Copia apenas go.mod e go.sum (cache do 'go mod download')
COPY go.mod go.sum ./

# 2) Baixa dependências
RUN go mod download

# 3) Copia o restante do código (inclui migrations/)
COPY . ./

# Ativa o CGO para compilar a dependência do SQLite
ENV CGO_ENABLED=1

# 4) Compila a aplicação como um binário estático
RUN go build \
    -ldflags '-w -s -extldflags "-static"' \
    -tags netgo,osuser \
    -o /quepasa \
    main.go

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

# Expõe a porta da aplicação
EXPOSE 31000

# Comando de entrada
ENTRYPOINT ["/app/quepasa"]
