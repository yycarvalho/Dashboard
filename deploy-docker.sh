#!/bin/bash

# Script de Deploy com Docker - Sistema de Pedidos API
# Este script automatiza o deploy completo usando Docker e Docker Compose

set -e  # Parar em caso de erro

echo "=== Deploy Docker do Sistema de Pedidos API ==="
echo "Data: $(date)"
echo ""

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "ERRO: Docker não encontrado. Instale o Docker primeiro."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "ERRO: Docker Compose não encontrado. Instale o Docker Compose primeiro."
    exit 1
fi

echo "✓ Docker encontrado: $(docker --version)"
echo "✓ Docker Compose encontrado: $(docker-compose --version)"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    echo "ERRO: Execute este script no diretório raiz do projeto"
    exit 1
fi

# Verificar variáveis de ambiente
if [ -z "$JWT_SECRET" ]; then
    echo "AVISO: JWT_SECRET não definido, usando valor padrão"
    export JWT_SECRET="sistema_pedidos_secret_key_2024_producao"
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "AVISO: DB_PASSWORD não definido, usando valor padrão"
    export DB_PASSWORD="senha_super_secreta_2024"
fi

# Criar diretórios necessários
echo "Criando diretórios..."
mkdir -p logs data config ssl

# Gerar certificados SSL auto-assinados (para desenvolvimento)
if [ ! -f "ssl/cert.pem" ] || [ ! -f "ssl/key.pem" ]; then
    echo "Gerando certificados SSL auto-assinados..."
    mkdir -p ssl
    
    # Gerar certificado auto-assinado
    openssl req -x509 -newkey rsa:4096 -keyout ssl/key.pem -out ssl/cert.pem -days 365 -nodes \
        -subj "/C=BR/ST=SP/L=SaoPaulo/O=SistemaPedidos/CN=localhost" 2>/dev/null || {
        echo "AVISO: Não foi possível gerar certificados SSL. Use certificados válidos para produção."
        echo "Criando certificados dummy..."
        echo "-----BEGIN CERTIFICATE-----" > ssl/cert.pem
        echo "DUMMY CERTIFICATE" >> ssl/cert.pem
        echo "-----END CERTIFICATE-----" >> ssl/cert.pem
        echo "-----BEGIN PRIVATE KEY-----" > ssl/key.pem
        echo "DUMMY KEY" >> ssl/key.pem
        echo "-----END PRIVATE KEY-----" >> ssl/key.pem
    }
fi

# Compilar o código Java se necessário
if [ ! -d "build/classes" ] || [ ! -f "build/classes/com/sistema/pedidos/controller/ApiController.class" ]; then
    echo "Compilando código Java..."
    if [ -f "compile.sh" ]; then
        chmod +x compile.sh
        ./compile.sh &
        COMPILE_PID=$!
        
        # Aguardar compilação
        echo "Aguardando compilação..."
        wait $COMPILE_PID
        
        if [ $? -ne 0 ]; then
            echo "ERRO: Falha na compilação"
            exit 1
        fi
    else
        echo "ERRO: Script de compilação não encontrado"
        exit 1
    fi
else
    echo "✓ Código Java já compilado"
fi

# Verificar se as dependências estão presentes
if [ ! -f "lib/jackson-core-2.15.2.jar" ]; then
    echo "Baixando dependências Jackson..."
    mkdir -p lib
    curl -L -o lib/jackson-core-2.15.2.jar "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.15.2/jackson-core-2.15.2.jar"
    curl -L -o lib/jackson-databind-2.15.2.jar "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.15.2/jackson-databind-2.15.2.jar"
    curl -L -o lib/jackson-annotations-2.15.2.jar "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.15.2/jackson-annotations-2.15.2.jar"
fi

# Parar containers existentes
echo "Parando containers existentes..."
docker-compose down --remove-orphans 2>/dev/null || true

# Remover imagens antigas (opcional)
read -p "Deseja remover imagens antigas? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removendo imagens antigas..."
    docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null || true
fi

# Construir e iniciar containers
echo "Construindo e iniciando containers..."
docker-compose up --build -d

# Aguardar inicialização
echo "Aguardando inicialização dos serviços..."
sleep 30

# Verificar status dos containers
echo "Verificando status dos containers..."
docker-compose ps

# Verificar health check da API
echo "Verificando health check da API..."
for i in {1..10}; do
    if curl -f http://localhost:8080/api/health >/dev/null 2>&1; then
        echo "✓ API está respondendo"
        break
    else
        echo "Aguardando API... tentativa $i/10"
        sleep 5
    fi
    
    if [ $i -eq 10 ]; then
        echo "ERRO: API não está respondendo após 10 tentativas"
        echo "Verificando logs..."
        docker-compose logs api
        exit 1
    fi
done

# Verificar Nginx
echo "Verificando Nginx..."
if curl -f http://localhost/health >/dev/null 2>&1; then
    echo "✓ Nginx está funcionando"
else
    echo "AVISO: Nginx pode não estar funcionando corretamente"
fi

# Criar arquivo de configuração de produção
echo "Criando configurações de produção..."
cat > config/production.properties << EOF
# Configurações de Produção - Docker
environment=production
host=0.0.0.0
port=8080
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000
max.connections=100
request.timeout=30
log.level=INFO
log.file=logs/sistema_pedidos.log
cors.allowed.origins=https://localhost,http://localhost
rate.limit.max.requests=100
EOF

# Criar script de gerenciamento
echo "Criando scripts de gerenciamento..."
cat > docker-manage.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Iniciando Sistema de Pedidos API..."
        docker-compose up -d
        ;;
    stop)
        echo "Parando Sistema de Pedidos API..."
        docker-compose down
        ;;
    restart)
        echo "Reiniciando Sistema de Pedidos API..."
        docker-compose restart
        ;;
    logs)
        echo "Mostrando logs..."
        docker-compose logs -f
        ;;
    status)
        echo "Status dos containers..."
        docker-compose ps
        ;;
    update)
        echo "Atualizando Sistema de Pedidos API..."
        git pull
        docker-compose down
        docker-compose up --build -d
        ;;
    backup)
        echo "Fazendo backup dos dados..."
        docker-compose exec postgres pg_dump -U pedidos_user pedidos_db > backup_$(date +%Y%m%d_%H%M%S).sql
        ;;
    *)
        echo "Uso: $0 {start|stop|restart|logs|status|update|backup}"
        exit 1
        ;;
esac
EOF

chmod +x docker-manage.sh

# Criar arquivo .env
echo "Criando arquivo .env..."
cat > .env << EOF
# Configurações de ambiente para Docker Compose
ENVIRONMENT=production
JWT_SECRET=${JWT_SECRET}
DB_PASSWORD=${DB_PASSWORD}
EOF

echo ""
echo "=== Deploy Docker Concluído com Sucesso! ==="
echo ""
echo "Serviços disponíveis:"
echo "  - API: http://localhost:8080/api"
echo "  - Nginx: http://localhost (HTTP) e https://localhost (HTTPS)"
echo "  - Health Check: http://localhost/health"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis: localhost:6379"
echo ""
echo "Comandos úteis:"
echo "  - Iniciar: ./docker-manage.sh start"
echo "  - Parar: ./docker-manage.sh stop"
echo "  - Logs: ./docker-manage.sh logs"
echo "  - Status: ./docker-manage.sh status"
echo "  - Atualizar: ./docker-manage.sh update"
echo ""
echo "Para acessar o sistema:"
echo "  - Frontend: https://localhost"
echo "  - API: https://localhost/api"
echo ""
echo "Usuários padrão:"
echo "  - admin / 123 (Administrador)"
echo "  - atendente / 123 (Atendente)"
echo "  - entregador / 123 (Entregador)"
echo ""
echo "IMPORTANTE:"
echo "  - Configure certificados SSL válidos para produção"
echo "  - Altere as senhas padrão"
echo "  - Configure backup automático do banco de dados"
echo "  - Monitore os logs regularmente"
echo ""
echo "Logs dos containers:"
docker-compose logs --tail=10