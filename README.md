# 🛒 API Carrinho de Compras - Desafio Técnico E-commerce

Uma API REST completa para gerenciamento de carrinho de compras, desenvolvida em Ruby on Rails com foco em clean code, testes automatizados e containerização Docker.

## 🚀 Funcionalidades

### 📋 Endpoints da API
- **`GET /cart`** - Visualizar carrinho atual
- **`POST /cart`** - Adicionar produto ao carrinho (cria carrinho)
- **`POST /cart/add_item`** - Alterar quantidade de produtos (adiciona produtos a um carrinho existente)
- **`DELETE /cart/:product_id`** - Remover produto do carrinho
- **`GET /products`** - Listar produtos disponíveis
- **`POST /products`** - Criar novo produto

### 🛠️ Recursos Técnicos
- **Gerenciamento de Sessões**: Carrinho identificado por session_id
- **Sistema de Carrinhos Abandonados**: 
  - Marca carrinhos inativos há mais de 3 horas
  - Remove carrinhos abandonados há mais de 7 dias
  - Processamento assíncrono com Sidekiq
- **Validações**: Quantidades positivas, produtos únicos por carrinho
- **Testes Completos**: RSpec com FactoryBot e cobertura total
- **Docker**: Ambiente containerizado completo

## 🐳 Execução com Docker (Recomendado)

### Pré-requisitos
- Docker
- Docker Compose

### 1. Clone e acesse o projeto
```bash
git clone https://github.com/amonn3/shopingcart.git
cd shopingcart
```

### 2. Execute a aplicação completa
```bash
# Iniciar todos os serviços
docker-compose up

# Ou em background
docker-compose up -d
```

### 3. Serviços disponíveis
- **API**: http://localhost:3000
- **Sidekiq Web UI**: http://localhost:3000/sidekiq
- **PostgreSQL**: localhost:5433
- **Redis**: localhost:6380

### 4. Executar testes
```bash
docker-compose run test
```

### 5. Parar serviços
```bash
docker-compose down
```

## 🔧 Execução Local (Alternativa)

### Pré-requisitos
- Ruby 3.3.1
- PostgreSQL
- Redis

### 1. Instalar dependências
```bash
bundle install
```

### 2. Configurar banco de dados
```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

### 3. Iniciar serviços
```bash
# Terminal 1 - API
bundle exec rails server

# Terminal 2 - Sidekiq (jobs assíncronos)
bundle exec sidekiq

# Terminal 3 - Redis
redis-server

# Terminal 4 - PostgreSQL
pg_ctl start
```

### 4. Executar testes
```bash
bundle exec rspec
```

## 📡 Exemplos de Uso da API

### 1. Criar um produto
```bash
curl -X POST http://localhost:3000/products \
  -H "Content-Type: application/json" \
  -d '{"product": {"name": "Smartphone", "price": 999.99}}'
```

### 2. Adicionar produto ao carrinho
```bash
curl -X POST http://localhost:3000/cart \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'
```

### 3. Visualizar carrinho
```bash
curl http://localhost:3000/cart
```

### 4. Adicionar mais quantidade
```bash
curl -X POST http://localhost:3000/cart/add_item \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 1}'
```

### 5. Remover produto
```bash
curl -X DELETE http://localhost:3000/cart/1
```

## 📊 Estrutura de Response

```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Smartphone",
      "quantity": 2,
      "unit_price": 999.99,
      "total_price": 1999.98
    }
  ],
  "total_price": 1999.98
}
```

## 🏗️ Arquitetura Docker

### Serviços
- **`web`**: Aplicação Rails principal
- **`sidekiq`**: Worker para jobs assíncronos
- **`db`**: PostgreSQL 16 Alpine
- **`redis`**: Redis 7.0 Alpine
- **`test`**: Ambiente isolado para testes

### Características
- **Multi-stage Dockerfile**: Otimização de tamanho da imagem
- **Health checks**: Garante dependências prontas antes da inicialização
- **Volume caching**: Bundle cache compartilhado para builds rápidos
- **Segurança**: Containers executam como usuário não-root
- **Hot reload**: Desenvolvimento com live reloading

## 🧪 Testes

### Cobertura
- **Models**: Cart, CartItem, Product
- **Controllers**: Carts, Products
- **Jobs**: MarkCartAsAbandonedJob
- **Routing**: Todas as rotas

### Factories (FactoryBot)
- Dados realistas com Faker
- Factories com herança para diferentes cenários
- Associations automáticas entre modelos

### Executar testes específicos
```bash
# Todos os testes
docker-compose run test

# Testes de modelo
docker-compose run test bundle exec rspec spec/models

# Testes de request
docker-compose run test bundle exec rspec spec/requests

# Teste específico
docker-compose run test bundle exec rspec spec/models/cart_spec.rb
```

## 🛠️ Stack Técnica

- **Backend**: Ruby on Rails 7.1
- **Banco de Dados**: PostgreSQL 16
- **Cache/Jobs**: Redis + Sidekiq
- **Testes**: RSpec + FactoryBot + Faker
- **Containerização**: Docker + Docker Compose
- **Agendamento**: Sidekiq-scheduler

## 📁 Estrutura do Projeto

```
├── app/
│   ├── controllers/     # Controllers da API
│   ├── models/         # Models com validações
│   └── sidekiq/        # Jobs assíncronos
├── spec/
│   ├── factories/      # Factories para testes
│   ├── models/         # Testes de modelo
│   ├── requests/       # Testes de API
│   └── sidekiq/        # Testes de jobs
├── docker-compose.yml  # Orquestração Docker
├── Dockerfile         # Imagem da aplicação
└── config/
    ├── routes.rb      # Rotas da API
    └── schedule.yml   # Agendamento de jobs
```

## 🔄 Sistema de Carrinhos Abandonados

### Funcionamento
1. **Tracking**: Atualiza `last_interaction_at` a cada ação no carrinho
2. **Marcação**: Job executa a cada 30 minutos via sidekiq-scheduler
3. **Abandono**: Carrinhos inativos há 3+ horas são marcados como abandonados
4. **Limpeza**: Carrinhos abandonados há 7+ dias são removidos

### Monitoramento
- Acesse http://localhost:3000/sidekiq para ver jobs em execução
- Logs detalhados de processamento
- Métricas de performance

---# shopingcart
