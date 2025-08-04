# =================================================================
# Estágio 1: Builder
# - Usa uma imagem completa do Go para construir a aplicação.
# - Instala dependências e compila o binário Go.
# - Nomeamos este estágio como "builder".
# =================================================================
FROM golang:1.22-bullseye AS builder

# Instala as ferramentas de build necessárias usando apt-get.
# Esta imagem base é mais robusta e garante que o gcc seja encontrado.
RUN apt-get update && apt-get install -y git gcc libc-dev

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Copia os arquivos de módulo primeiro para aproveitar o cache do Docker.
COPY ./src/go.mod ./src/go.sum ./

# Baixa as dependências do projeto antes de copiar o resto do código.
# Isso melhora o cache e pode forçar a invalidação de camadas antigas.
RUN go mod download

# Copia o resto do código-fonte.
COPY ./src .

# Define a variável de ambiente CGO_ENABLED para este estágio de build.
# Esta é uma forma mais explícita de corrigir o erro "go-sqlite3 requires cgo".
ENV CGO_ENABLED=1

# Compila a aplicação Go de forma explícita e otimizada.
# O -ldflags "-w -s" remove informações de debug e reduz o tamanho do binário.
RUN go build -ldflags="-w -s" -o /quepasa main.go

# =================================================================
# Estágio 2: Imagem Final
# - Usa uma imagem mínima 'alpine' para um tamanho final pequeno.
# - Copia apenas o binário compilado e os arquivos necessários.
# =================================================================
FROM alpine:3.18

# Instala apenas as dependências de execução.
# 'ffmpeg' é uma dependência da aplicação.
RUN apk add --no-cache ffmpeg

# Define o diretório de trabalho para a imagem final.
WORKDIR /app

# Copia o binário da aplicação compilado do estágio "builder".
COPY --from=builder /quepasa .

# Copia os scripts de migração do banco de dados.
# Esta linha corrige o erro "no such file or directory" para as migrações.
COPY ./docker/postgres/migrations ./migrations

# Expõe a porta padrão da aplicação (boa prática).
# O Railway irá sobrepor isso com
