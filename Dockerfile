# =================================================================
# Estágio 1: Builder
# Este Dockerfile deve estar localizado na RAIZ do projeto.
# =================================================================
FROM golang:1.23-bullseye AS builder

# Instala as ferramentas de build necessárias
RUN apt-get update && apt-get install -y git gcc libc-dev

WORKDIR /app

# Copia todo o código-fonte da pasta /src primeiro.
COPY src/ ./

# Agora que todo o código está presente, podemos baixar as dependências.
RUN go mod download

# Ativa o CGO para compilar a dependência do SQLite.
ENV CGO_ENABLED=1

# Compila a aplicação como um binário estático.
RUN go build -ldflags '-w -s -extldflags "-static"' -tags netgo,osuser -o /quepasa main.go

# =================================================================
# Estágio 2: Imagem Final
# =================================================================
FROM alpine:3.18

# Instala as dependências de execução (ffmpeg).
RUN apk add --no-cache ffmpeg

# Define o diretório de trabalho final.
WORKDIR /app

# Copia o binário compilado do estágio anterior para o diretório de trabalho.
COPY --from=builder /quepasa .

# Copia a pasta de migrações usando um caminho de destino absoluto.
# ESTA É A CORREÇÃO FINAL E MAIS ROBUSTA.
COPY --from=builder /app/migrations /app/migrations/

# Expõe a porta.
EXPOSE 31000

# Define o comando de arranque.
ENTRYPOINT ["/app/quepasa"]
