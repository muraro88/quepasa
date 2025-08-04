# =================================================================
# Estágio 1: Builder
# Este Dockerfile deve estar localizado na RAIZ do projeto.
# =================================================================
FROM golang:1.23-bullseye AS builder

# Instala as ferramentas de build necessárias
RUN apt-get update && apt-get install -y git gcc libc-dev

WORKDIR /app

# Copia todo o código-fonte da pasta /src primeiro.
# Isto resolve o erro de "no such file or directory" para o submódulo /api.
COPY src/ ./

# Agora que todo o código está presente, podemos baixar as dependências.
RUN go mod download

# Ativa o CGO para compilar a dependência do SQLite.
ENV CGO_ENABLED=1

# Compila a aplicação.
RUN go build -ldflags="-w -s" -o /quepasa main.go

# =================================================================
# Estágio 2: Imagem Final
# =================================================================
FROM alpine:3.18

# Instala as dependências de execução (ffmpeg).
RUN apk add --no-cache ffmpeg

WORKDIR /app

# Copia o binário compilado do estágio anterior.
COPY --from=builder /quepasa .

# Copia as migrações da base de dados a partir da pasta /src/migrations.
COPY src/migrations ./migrations

# Expõe a porta.
EXPOSE 31000

# Define o comando de arranque.
ENTRYPOINT ["/app/quepasa"]
