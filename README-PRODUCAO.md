# Sistema de Pedidos API - Guia de Produção

## 🚀 Visão Geral

Este é um sistema completo de gestão de pedidos desenvolvido em Java com frontend em HTML/CSS/JavaScript. O sistema inclui funcionalidades de autenticação, gerenciamento de pedidos, cardápio, chat em tempo real, relatórios e controle de permissões.

## ✨ Funcionalidades Principais

### 🔐 Autenticação e Segurança
- Sistema de login com JWT
- Controle de permissões por perfil
- Rate limiting por IP
- Validação de CORS
- Middleware de segurança

### 📋 Gestão de Pedidos
- Criação e edição de pedidos
- Controle de status (atendimento, preparo, pronto, etc.)
- Sistema de chat integrado
- Histórico completo de pedidos
- Filtros e busca avançada

### 🍽️ Cardápio
- Gerenciamento de produtos
- Categorias organizadas
- Controle de preços e disponibilidade
- Imagens e descrições

### 👥 Usuários e Perfis
- CRUD completo de usuários
- Sistema de perfis com permissões granulares
- Controle de acesso por funcionalidade

### 📊 Dashboard e Relatórios
- Métricas em tempo real
- Gráficos de faturamento
- Relatórios por período
- Estatísticas de pedidos

### 💬 Sistema de Chat
- Chat em tempo real para pedidos
- Histórico de mensagens
- Notificações automáticas
- Suporte a múltiplos usuários

## 🛠️ Requisitos Técnicos

### Backend
- **Java**: 11 ou superior
- **Memória**: Mínimo 1GB, Recomendado 2GB
- **Disco**: 100MB para aplicação + espaço para logs
- **Sistema**: Linux, Windows ou macOS

### Frontend
- **Navegador**: Chrome 80+, Firefox 75+, Safari 13+
- **JavaScript**: ES6+ habilitado
- **Responsivo**: Mobile-first design

## 📦 Instalação e Deploy

### 1. Preparação do Ambiente

```bash
# Clonar o repositório
git clone <url-do-repositorio>
cd sistema-pedidos

# Verificar Java
java -version
# Deve ser Java 11 ou superior
```

### 2. Deploy Automático

```bash
# Executar script de deploy
chmod +x deploy.sh
./deploy.sh
```

O script irá:
- Verificar dependências
- Compilar o código Java
- Criar scripts de produção
- Configurar ambiente

### 3. Configuração Manual (Opcional)

```bash
# Compilar manualmente
./compile.sh

# Ou usar o script de produção
./start-production.sh
```

## ⚙️ Configuração de Produção

### Variáveis de Ambiente

```bash
# Configurações críticas
export ENVIRONMENT=production
export JWT_SECRET=sua_chave_super_secreta_aqui
export PORT=8080
export HOST=0.0.0.0

# Configurações de banco (futuras implementações)
export DB_URL=jdbc:postgresql://localhost:5432/pedidos_db
export DB_USER=pedidos_user
export DB_PASSWORD=senha_secreta
```

### Arquivo de Configuração

O sistema criará automaticamente `config/production.properties` com as configurações necessárias.

## 🚀 Execução

### Iniciar em Produção

```bash
./start-production.sh
```

### Parar Serviço

```bash
./stop-production.sh
```

### Monitorar Status

```bash
./monitor.sh
```

### Verificar Logs

```bash
tail -f logs/sistema_pedidos.log
```

## 🔒 Segurança

### JWT Token
- **Expiração**: 24 horas (configurável)
- **Secret**: Configurável via variável de ambiente
- **Algoritmo**: HS256

### Rate Limiting
- **Limite**: 100 requisições por minuto por IP
- **Configurável**: Via arquivo de configuração

### CORS
- **Origins permitidas**: Configuráveis
- **Métodos**: GET, POST, PUT, DELETE, PATCH, OPTIONS
- **Headers**: Content-Type, Authorization, X-Requested-With

## 📊 Monitoramento

### Health Check
- **Endpoint**: `/api/health`
- **Página**: `health-check.html`
- **Status**: OK/ERRO com timestamp

### Logs
- **Arquivo**: `logs/sistema_pedidos.log`
- **Rotação**: Automática (10MB por arquivo, 5 arquivos)
- **Nível**: INFO em produção

### Métricas
- **Uso de memória**: Via script de monitoramento
- **Processos**: Contagem de processos Java
- **Disco**: Uso de espaço em disco

## 🔧 Manutenção

### Backup
```bash
# Backup dos dados (em produção, implementar banco de dados)
cp -r data/ backup/data_$(date +%Y%m%d_%H%M%S)
```

### Limpeza de Logs
```bash
# Limpeza automática configurada
# Manual: rm logs/sistema_pedidos.log.*
```

### Atualizações
```bash
# Parar serviço
./stop-production.sh

# Fazer backup
# Atualizar código
# Executar deploy
./deploy.sh

# Reiniciar
./start-production.sh
```

## 🐛 Troubleshooting

### Problemas Comuns

#### API não inicia
```bash
# Verificar Java
java -version

# Verificar portas
netstat -tulpn | grep 8080

# Verificar logs
cat logs/startup.log
```

#### Erro de permissão
```bash
# Dar permissão de execução
chmod +x *.sh

# Verificar usuário
whoami
```

#### Erro de memória
```bash
# Ajustar JVM options em start-production.sh
export JAVA_OPTS="-Xmx1g -Xms512m"
```

### Logs de Erro

```bash
# Erros críticos
grep "SEVERE" logs/sistema_pedidos.log

# Erros de autenticação
grep "Unauthorized" logs/sistema_pedidos.log

# Erros de rede
grep "Network" logs/sistema_pedidos.log
```

## 📈 Performance

### Otimizações Recomendadas

1. **JVM Options**
   ```bash
   -server -Xmx2g -Xms1g -XX:+UseG1GC
   ```

2. **Pool de Threads**
   - Configurado para 100 conexões simultâneas
   - Ajustável via `AppConfig.MAX_CONNECTIONS`

3. **Rate Limiting**
   - 100 requisições/minuto por IP
   - Configurável via configuração

4. **Logging**
   - Rotação automática de logs
   - Nível INFO em produção

## 🔄 Integração

### API Endpoints

```
POST   /api/auth/login          # Login
POST   /api/auth/logout         # Logout
GET    /api/auth/validate       # Validar token

GET    /api/users               # Listar usuários
POST   /api/users               # Criar usuário
PUT    /api/users               # Atualizar usuário
DELETE /api/users               # Deletar usuário

GET    /api/profiles            # Listar perfis
POST   /api/profiles            # Criar perfil
PUT    /api/profiles            # Atualizar perfil
DELETE /api/profiles            # Deletar perfil

GET    /api/products            # Listar produtos
POST   /api/products            # Criar produto
PUT    /api/products            # Atualizar produto
DELETE /api/products            # Deletar produto

GET    /api/orders              # Listar pedidos
POST   /api/orders              # Criar pedido
PUT    /api/orders              # Atualizar pedido
DELETE /api/orders              # Deletar pedido
PATCH  /api/orders/{id}/status # Atualizar status

GET    /api/orders/chat         # Histórico do chat
POST   /api/orders/chat         # Nova mensagem

GET    /api/metrics/dashboard   # Métricas do dashboard
GET    /api/metrics/reports     # Relatórios
```

### Formato de Resposta

```json
{
  "success": true,
  "data": {...},
  "message": "Operação realizada com sucesso"
}
```

### Autenticação

```bash
# Header obrigatório para endpoints protegidos
Authorization: Bearer <jwt_token>
```

## 📞 Suporte

### Informações de Contato
- **Desenvolvedor**: Manus AI
- **Versão**: 3.0 (Produção)
- **Data**: 2024

### Documentação Adicional
- `README.md` - Documentação geral
- `sources.txt` - Lista de arquivos fonte
- `config/` - Configurações de ambiente

---

## 🎯 Próximos Passos

1. **Implementar banco de dados persistente**
2. **Adicionar WebSocket para chat em tempo real**
3. **Implementar sistema de notificações push**
4. **Adicionar testes automatizados**
5. **Implementar CI/CD pipeline**
6. **Adicionar monitoramento APM**
7. **Implementar backup automático**
8. **Adicionar métricas de negócio**

---

**⚠️ IMPORTANTE**: Este sistema está configurado para produção com todas as funcionalidades de segurança habilitadas. Sempre teste em ambiente de desenvolvimento antes de fazer deploy em produção.