# =================================================================
# Estágio 1: Builder
# - Usa uma imagem completa do Go para construir a aplicação.
# - Instala dependências e compila o binário Go.
# - Nomeamos este estágio como "builder".
# =================================================================
FROM golang:1.22-alpine AS builder

# Instala as ferramentas de build necessárias.
# 'git' e 'gcc' são necessários para compilar dependências com CGO.
RUN apk add --no-cache git gcc libc-dev

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Copia o código-fonte da sua pasta local 'src' para o contêiner.
COPY ./src .

# Define a variável de ambiente CGO_ENABLED para este estágio de build.
# Esta é uma forma mais explícita de corrigir o erro "go-sqlite3 requires cgo".
ENV CGO_ENABLED=1

# Compila a aplicação Go.
# Isso cria um executável estático chamado 'quepasa'.
RUN go build -o /quepasa

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
# O Railway irá sobrepor isso com a variável de ambiente PORT.
EXPOSE 31000

# Define o comando que será executado quando o contêiner iniciar.
ENTRYPOINT ["/app/quepasa"]
