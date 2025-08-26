#!/bin/bash

# Script de Deploy para Produção - Sistema de Pedidos API
# Este script deve ser executado em um ambiente controlado

set -e  # Parar em caso de erro

echo "=== Deploy do Sistema de Pedidos API ==="
echo "Data: $(date)"
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "compile.sh" ]; then
    echo "ERRO: Execute este script no diretório raiz do projeto"
    exit 1
fi

# Verificar variáveis de ambiente
if [ -z "$ENVIRONMENT" ]; then
    export ENVIRONMENT="production"
fi

if [ -z "$JWT_SECRET" ]; then
    echo "AVISO: JWT_SECRET não definido, usando valor padrão"
    export JWT_SECRET="sistema_pedidos_secret_key_2024_producao"
fi

# Verificar Java
if ! command -v java &> /dev/null; then
    echo "ERRO: Java não encontrado. Instale Java 11 ou superior"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 11 ]; then
    echo "ERRO: Java 11 ou superior é necessário. Versão atual: $JAVA_VERSION"
    exit 1
fi

echo "Java versão: $(java -version 2>&1 | head -n 1)"
echo ""

# Criar diretórios necessários
echo "Criando diretórios..."
mkdir -p build/classes
mkdir -p lib
mkdir -p logs
mkdir -p data
mkdir -p config

# Baixar dependências se necessário
echo "Verificando dependências..."
if [ ! -f "lib/jackson-core-2.15.2.jar" ]; then
    echo "Baixando dependências Jackson..."
    curl -L -o lib/jackson-core-2.15.2.jar "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.15.2/jackson-core-2.15.2.jar"
    curl -L -o lib/jackson-databind-2.15.2.jar "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.15.2/jackson-databind-2.15.2.jar"
    curl -L -o lib/jackson-annotations-2.15.2.jar "https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.15.2/jackson-annotations-2.15.2.jar"
fi

# Compilar código
echo "Compilando código Java..."
find src -name "*.java" > sources.txt

if javac -cp "lib/*" -d build/classes @sources.txt; then
    echo "Compilação concluída com sucesso!"
else
    echo "ERRO: Falha na compilação"
    exit 1
fi

# Verificar se a compilação foi bem-sucedida
if [ ! -f "build/classes/com/sistema/pedidos/controller/ApiController.class" ]; then
    echo "ERRO: Classe principal não foi compilada"
    exit 1
fi

# Criar arquivo de configuração de produção
echo "Configurando ambiente de produção..."
cat > config/production.properties << EOF
# Configurações de Produção
environment=production
host=0.0.0.0
port=8080
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000
max.connections=100
request.timeout=30
log.level=INFO
log.file=logs/sistema_pedidos.log
cors.allowed.origins=https://seudominio.com,https://www.seudominio.com
rate.limit.max.requests=100
EOF

# Criar script de inicialização
echo "Criando script de inicialização..."
cat > start-production.sh << 'EOF'
#!/bin/bash

# Script de inicialização para produção
export ENVIRONMENT=production
export JAVA_OPTS="-server -Xmx2g -Xms1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

echo "=== Iniciando Sistema de Pedidos API em Produção ==="
echo "Data: $(date)"
echo "Java Options: $JAVA_OPTS"
echo ""

# Verificar se já está rodando
if pgrep -f "ApiController" > /dev/null; then
    echo "ERRO: API já está rodando"
    exit 1
fi

# Iniciar aplicação
nohup java $JAVA_OPTS -cp "build/classes:lib/*" com.sistema.pedidos.controller.ApiController 8080 > logs/startup.log 2>&1 &

# Aguardar inicialização
sleep 5

# Verificar se iniciou com sucesso
if pgrep -f "ApiController" > /dev/null; then
    echo "API iniciada com sucesso! PID: $(pgrep -f 'ApiController')"
    echo "Logs: logs/startup.log"
    echo "API disponível em: http://0.0.0.0:8080/api"
else
    echo "ERRO: Falha ao iniciar API"
    echo "Verifique os logs: logs/startup.log"
    exit 1
fi
EOF

chmod +x start-production.sh

# Criar script de parada
echo "Criando script de parada..."
cat > stop-production.sh << 'EOF'
#!/bin/bash

echo "=== Parando Sistema de Pedidos API ==="

PID=$(pgrep -f "ApiController")
if [ -n "$PID" ]; then
    echo "Parando processo PID: $PID"
    kill $PID
    
    # Aguardar parada
    for i in {1..10}; do
        if ! pgrep -f "ApiController" > /dev/null; then
            echo "API parada com sucesso"
            exit 0
        fi
        sleep 1
    done
    
    # Forçar parada se necessário
    echo "Forçando parada..."
    kill -9 $PID
    echo "API forçada a parar"
else
    echo "API não está rodando"
fi
EOF

chmod +x stop-production.sh

# Criar script de monitoramento
echo "Criando script de monitoramento..."
cat > monitor.sh << 'EOF'
#!/bin/bash

echo "=== Status do Sistema de Pedidos API ==="
echo "Data: $(date)"
echo ""

# Verificar se está rodando
PID=$(pgrep -f "ApiController")
if [ -n "$PID" ]; then
    echo "✓ API está rodando (PID: $PID)"
    
    # Verificar uso de memória
    MEMORY=$(ps -o rss= -p $PID | awk '{print $1/1024 " MB"}')
    echo "  Memória: $MEMORY"
    
    # Verificar tempo de execução
    UPTIME=$(ps -o etime= -p $PID)
    echo "  Tempo ativo: $UPTIME"
    
    # Verificar logs recentes
    if [ -f "logs/sistema_pedidos.log" ]; then
        echo "  Logs recentes:"
        tail -5 logs/sistema_pedidos.log | sed 's/^/    /'
    fi
else
    echo "✗ API não está rodando"
fi

echo ""
echo "=== Verificação de Recursos ==="

# Verificar uso de disco
DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}')
echo "Uso de disco: $DISK_USAGE"

# Verificar uso de memória do sistema
MEMORY_USAGE=$(free -h | grep Mem | awk '{print $3 "/" $2}')
echo "Memória do sistema: $MEMORY_USAGE"

# Verificar processos Java
JAVA_PROCESSES=$(pgrep -c java)
echo "Processos Java: $JAVA_PROCESSES"
EOF

chmod +x monitor.sh

# Criar arquivo de health check
echo "Criando endpoint de health check..."
cat > health-check.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Health Check - Sistema de Pedidos API</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Health Check</h1>
    <p>Status: <span id="status">Verificando...</span></p>
    <p>Timestamp: <span id="timestamp"></span></p>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString('pt-BR');
        
        fetch('/api/health')
            .then(response => {
                if (response.ok) {
                    document.getElementById('status').textContent = 'OK';
                    document.getElementById('status').style.color = 'green';
                } else {
                    document.getElementById('status').textContent = 'ERRO';
                    document.getElementById('status').style.color = 'red';
                }
            })
            .catch(error => {
                document.getElementById('status').textContent = 'ERRO: ' + error.message;
                document.getElementById('status').style.color = 'red';
            });
    </script>
</body>
</html>
EOF

echo ""
echo "=== Deploy Concluído com Sucesso! ==="
echo ""
echo "Arquivos criados:"
echo "  - start-production.sh (script de inicialização)"
echo "  - stop-production.sh (script de parada)"
echo "  - monitor.sh (script de monitoramento)"
echo "  - config/production.properties (configurações)"
echo "  - health-check.html (página de health check)"
echo ""
echo "Para iniciar em produção:"
echo "  ./start-production.sh"
echo ""
echo "Para parar:"
echo "  ./stop-production.sh"
echo ""
echo "Para monitorar:"
echo "  ./monitor.sh"
echo ""
echo "Logs serão salvos em: logs/sistema_pedidos.log"
echo ""
echo "IMPORTANTE: Configure as variáveis de ambiente apropriadas antes de iniciar!"