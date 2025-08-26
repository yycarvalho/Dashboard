# Sistema de Gestão de Pedidos

Sistema completo para gerenciamento de pedidos, cardápio e entregas com dashboard em tempo real.

## ✨ Funcionalidades

- **Dashboard**: Métricas em tempo real, gráficos e visão geral do sistema
- **Pedidos**: Gerenciamento completo de pedidos com status e chat
- **Cardápio**: Controle de produtos, categorias e disponibilidade
- **Relatórios**: Análises de vendas e performance
- **Perfis**: Sistema de usuários e permissões
- **Interface Responsiva**: Funciona perfeitamente em desktop e mobile

## 🚀 Correções Implementadas

### 1. Estrutura HTML e Acessibilidade
- ✅ Corrigidos caminhos dos arquivos CSS e JS
- ✅ Adicionadas meta tags para SEO otimizado
- ✅ Melhorada estrutura semântica com tags adequadas
- ✅ Implementados atributos ARIA para acessibilidade
- ✅ Adicionados labels descritivos e roles apropriados

### 2. Performance e SEO
- ✅ Preconnect para recursos externos
- ✅ DNS prefetch para otimização
- ✅ Meta tags Open Graph e Twitter Cards
- ✅ Títulos otimizados para cada seção
- ✅ Descrições e palavras-chave relevantes

### 3. Inicialização de Módulos
- ✅ Corrigida inicialização dupla dos módulos
- ✅ Implementada verificação de existência antes da inicialização
- ✅ Melhorada ordem de carregamento dos scripts
- ✅ Adicionado tratamento de erros na inicialização

### 4. Responsividade
- ✅ Design mobile-first implementado
- ✅ Media queries para diferentes tamanhos de tela
- ✅ Navegação adaptativa (sidebar desktop, bottom nav mobile)
- ✅ Grid system flexível e adaptativo

## 📁 Estrutura do Projeto

```
/
├── index.html              # Interface principal do sistema
├── index-simples.html      # Interface simplificada
├── test.html               # Página de testes
├── config.js               # Configurações da aplicação
├── api.js                  # Cliente da API
├── auth.js                 # Gerenciador de autenticação
├── ui.js                   # Componentes de interface
├── dashboard.js            # Gerenciador do dashboard
├── pedidos.js              # Gerenciador de pedidos
├── cardapio.js             # Gerenciador do cardápio
├── relatorios.js           # Gerenciador de relatórios
├── perfis.js               # Gerenciador de perfis
├── app.js                  # Aplicação principal
├── style.css               # Estilos principais
├── layout.css              # Layout e estrutura
├── components.css          # Componentes reutilizáveis
├── responsive.css          # Estilos responsivos
├── variables.css           # Variáveis CSS
└── reset.css               # Reset CSS
```

## 🛠️ Como Usar

### 1. Abrir o Sistema
```bash
# Navegar para o diretório do projeto
cd /caminho/para/projeto

# Abrir index.html no navegador
# Ou usar um servidor local
python3 -m http.server 8000
```

### 2. Testar Funcionalidades
- Abrir `test.html` para verificar status dos módulos
- Verificar console do navegador para logs de debug
- Testar navegação entre seções

### 3. Configurar API
- Editar `config.js` com URL da sua API
- Configurar endpoints e timeouts conforme necessário

## 🔧 Configuração

### Variáveis de Ambiente
```javascript
// config.js
const CONFIG = {
    API_BASE_URL: 'http://localhost:8080/api',
    DEBUG: { ENABLED: true },
    TIMEOUTS: { REQUEST: 30000 }
};
```

### Personalização de Estilos
```css
/* variables.css */
:root {
    --primary-color: #3b82f6;
    --secondary-color: #64748b;
    --success: #10b981;
    --warning: #f59e0b;
    --danger: #ef4444;
}
```

## 📱 Responsividade

O sistema é totalmente responsivo com breakpoints:
- **Desktop**: > 1024px (sidebar lateral)
- **Tablet**: 768px - 1024px (layout adaptativo)
- **Mobile**: < 768px (navegação inferior)

## ♿ Acessibilidade

- **Navegação por teclado**: Tab, Enter, Escape
- **Screen readers**: Labels ARIA e roles apropriados
- **Contraste**: Cores com contraste adequado
- **Semântica**: Estrutura HTML semântica

## 🚨 Solução de Problemas

### Módulos não carregam
1. Verificar console do navegador para erros
2. Confirmar que todos os arquivos JS estão presentes
3. Verificar ordem de carregamento dos scripts

### Estilos não aplicam
1. Verificar caminhos dos arquivos CSS
2. Confirmar que arquivos CSS existem
3. Verificar console para erros de carregamento

### API não responde
1. Verificar URL da API em `config.js`
2. Confirmar que servidor está rodando
3. Verificar CORS e autenticação

## 📈 Próximos Passos

- [ ] Implementar testes automatizados
- [ ] Adicionar PWA (Progressive Web App)
- [ ] Implementar cache offline
- [ ] Adicionar notificações push
- [ ] Implementar tema escuro

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 📞 Suporte

Para suporte e dúvidas:
- Abra uma issue no GitHub
- Verifique a documentação da API
- Consulte os logs de debug no console

---

**Desenvolvido com ❤️ para otimizar a gestão de pedidos e melhorar a experiência do usuário.**