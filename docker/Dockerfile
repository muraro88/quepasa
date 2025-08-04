# =================================================================
# Estágio 1: Builder
# Este Dockerfile está localizado em /docker/Dockerfile
# O "Root Directory" no Railway deve estar VAZIO.
# =================================================================
FROM golang:1.22-bullseye AS builder

# Instala as ferramentas de build necessárias usando apt-get.
RUN apt-get update && apt-get install -y git gcc libc-dev

# Define o diretório de trabalho.
WORKDIR /app

# Copia os ficheiros de módulo primeiro. Os caminhos são relativos à raiz do projeto.
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copia o resto do código-fonte da pasta /src.
COPY src .

# Ativa o CGO.
ENV CGO_ENABLED=1

# Compila a aplicação.
RUN go build -ldflags="-w -s" -o /quepasa main.go

# =================================================================
# Estágio 2: Imagem Final
# =================================================================
FROM alpine:3.18

# Instala as dependências de execução.
RUN apk add --no-cache ffmpeg

# Define o diretório de trabalho.
WORKDIR /app

# Copia o binário compilado do estágio anterior.
COPY --from=builder /quepasa .

# Copia as migrações da base de dados, que foram copiadas para /app/migrations no estágio anterior.
COPY --from=builder /app/migrations ./migrations

# Expõe a porta.
EXPOSE 31000

# Define o comando de arranque.
ENTRYPOINT ["/app/quepasa"]
