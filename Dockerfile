# =================================================================
# Dockerfile de Depuração (Estágio Único e Simplificado)
# Este ficheiro cria uma imagem maior, mas é mais simples e robusto para encontrar o erro.
# Ele deve estar localizado na RAIZ do seu projeto.
# =================================================================
FROM golang:1.23-bullseye

# 1. Instala TODAS as ferramentas necessárias (build e execução) de uma só vez.
RUN apt-get update && apt-get install -y git gcc libc-dev ffmpeg

# 2. Define o diretório de trabalho para a aplicação.
WORKDIR /app

# 3. Copia TODO o código-fonte da sua pasta local /src para dentro do contêiner.
#    Isto garante que a pasta /migrations será copiada para /app/migrations.
COPY src/ ./

# 4. Baixa as dependências do Go.
RUN go mod download

# 5. Ativa o CGO para que a compilação funcione.
ENV CGO_ENABLED=1

# 6. Compila a aplicação, colocando o executável dentro do diretório de trabalho /app.
RUN go build -o /app/quepasa main.go

# 7. Expõe a porta da aplicação.
EXPOSE 31000

# 8. Define o comando para iniciar a aplicação.
#    Como o executável e as migrações estão ambos dentro de /app, tudo deve ser encontrado.
ENTRYPOINT ["/app/quepasa"]
