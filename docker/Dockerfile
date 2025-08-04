# Dockerfile simplificado para debug
FROM golang:1.22-bullseye

# Instala dependências
RUN apt-get update && apt-get install -y ffmpeg git gcc libc-dev

# Define diretório de trabalho
WORKDIR /app

# Copia todo o projeto
COPY . .

# Move para diretório src se existir
RUN if [ -d "src" ]; then cd src; else cd /app; fi

# Baixa dependências
RUN if [ -f "src/go.mod" ]; then cd src && go mod download; else go mod download; fi

# Compila
ENV CGO_ENABLED=1
RUN if [ -f "src/main.go" ]; then cd src && go build -o /app/quepasa main.go; else go build -o /app/quepasa main.go; fi

# Expõe porta
EXPOSE 8080

# Executa aplicação
CMD ["./quepasa"]
