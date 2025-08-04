# =================================================================
# Dockerfile de Depuração (Estágio Único e Simplificado)
# Este ficheiro inclui um comando para listar os ficheiros no log de build.
# =================================================================
FROM golang:1.23-bullseye

# 1. Instala TODAS as ferramentas necessárias (build e execução) de uma só vez.
RUN apt-get update && apt-get install -y git gcc libc-dev ffmpeg

# 2. Define o diretório de trabalho para a aplicação.
WORKDIR /app

# 3. Copia TODO o código-fonte da sua pasta local /src para dentro do contêiner.
COPY src/ ./

# 4. COMANDO DE DEPURAÇÃO: Lista todos os ficheiros e pastas dentro de /app.
#    O resultado deste comando aparecerá no "Build Log".
RUN ls -R

# 5. Baixa as dependências do Go.
RUN go mod download

# 6. Ativa o CGO para que a compilação funcione.
ENV CGO_ENABLED=1

# 7. Compila a aplicação.
RUN go build -o /app/quepasa main.go

# 8. Expõe a porta da aplicação.
EXPOSE 31000

# 9. Define o comando para iniciar a aplicação.
ENTRYPOINT ["/app/quepasa"]
