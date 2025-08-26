# Dockerfile para Sistema de Pedidos API
FROM openjdk:11-jre-slim

# Metadados
LABEL maintainer="Manus AI"
LABEL version="3.0"
LABEL description="Sistema de Gestão de Pedidos API"

# Configurar diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root para segurança
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copiar dependências JAR
COPY lib/*.jar lib/

# Copiar código compilado
COPY build/classes build/classes

# Copiar scripts e configurações
COPY config/ config/
COPY *.sh ./

# Dar permissões de execução
RUN chmod +x *.sh

# Criar diretórios necessários
RUN mkdir -p logs data && chown -R appuser:appuser /app

# Mudar para usuário não-root
USER appuser

# Expor porta
EXPOSE 8080

# Variáveis de ambiente padrão
ENV ENVIRONMENT=production
ENV PORT=8080
ENV HOST=0.0.0.0
ENV JAVA_OPTS="-server -Xmx1g -Xms512m -XX:+UseG1GC"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

# Comando de inicialização
CMD ["java", "-cp", "build/classes:lib/*", "com.sistema.pedidos.controller.ApiController", "8080"]