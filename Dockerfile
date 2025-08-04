# =================================================================
# Dockerfile Final e Simplificado (Estágio Único)
# Este ficheiro cria uma imagem maior, mas é mais robusto para resolver o problema.
# Ele deve estar localizado na RAIZ do seu projeto.
# =================================================================
FROM golang:1.23-bullseye

# 1. Instala TODAS as ferramentas necessárias (build e execução) de uma só vez.
RUN apt-get update && apt-get install -y git gcc libc-dev ffmpeg

# 2. Define o diretório de trabalho para a aplicação.
WORKDIR /app

# 3. Copia os ficheiros de módulo a partir da pasta /src.
#    ESTA É A CORREÇÃO PARA O ERRO "go.mod not found".
COPY src/go.mod src/go.sum ./

# 4. Baixa as dependências do Go.
RUN go mod download

# 5. Copia o resto do código-fonte para dentro do contêiner.
COPY src/ ./

# 6. Ativa o CGO para que a compilação funcione.
ENV CGO_ENABLED=1

# 7. Compila a aplicação como um binário estático para maior compatibilidade.
RUN go build -ldflags '-w -s -extldflags "-static"' -tags netgo,osuser -o /app/quepasa main.go

# 8. Expõe a porta da aplicação.
EXPOSE 31000

# 9. Define o comando para iniciar a aplicação.
#    Como o executável e as migrações estão ambos dentro de /app, tudo deve ser encontrado.
ENTRYPOINT ["/app/quepasa"]
