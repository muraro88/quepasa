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

WORKDIR /app

# Copia o binário compilado do estágio anterior.
COPY --from=builder /quepasa .

# Copia as migrações da base de dados A PARTIR DO ESTÁGIO BUILDER.
# ESTA É A LINHA QUE FOI CORRIGIDA.
COPY --from=builder /app/migrations ./migrations

# Expõe a porta.
EXPOSE 31000

# Define o comando de arranque.
ENTRYPOINT ["/app/quepasa"]
