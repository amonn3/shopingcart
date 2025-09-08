# Guia de Implementação - Carrinho de Compras

## Resumo da Implementação

Implementei todas as funcionalidades solicitadas no desafio de carrinho de compras:

### ✅ Funcionalidades Implementadas

1. **4 Endpoints da API:**
   - `GET /cart` - Listar itens do carrinho atual
   - `POST /cart` - Registrar produto no carrinho
   - `POST /cart/add_item` - Alterar quantidade de produtos
   - `DELETE /cart/:product_id` - Remover produto do carrinho

2. **Modelo de Dados:**
   - `CartItem` - Modelo para ligar carrinhos e produtos
   - Relacionamentos: Cart has_many CartItems has_many Products
   - Validações de integridade e quantidade positiva

3. **Gerenciamento de Sessões:**
   - Carrinho identificado por session_id
   - Criação automática de carrinho quando não existe

4. **Sistema de Carrinhos Abandonados:**
   - Job Sidekiq para marcar carrinhos abandonados (3h inatividade)
   - Remoção automática de carrinhos abandonados há mais de 7 dias
   - Agendamento via sidekiq-scheduler (execução a cada 30 minutos)

5. **Tratamento de Erros:**
   - Validação de produtos existentes
   - Validação de quantidades positivas
   - Mensagens de erro apropriadas

6. **Testes Completos:**
   - Testes de modelo para Cart, CartItem e Product
   - Testes de request para todos os endpoints
   - Testes de job para carrinhos abandonados
   - Uso de FactoryBot para dados de teste

7. **Docker:**
   - docker-compose.yml completo com PostgreSQL, Redis, Web, Sidekiq e Test
   - Health checks configurados
   - Serviços isolados e configurados

## Como Executar

### 1. Instalar Dependências
```bash
bundle install
```

### 2. Executar Migrações
```bash
bundle exec rails db:create
bundle exec rails db:migrate
```

### 3. Executar Testes
```bash
bundle exec rspec
```

### 4. Executar com Docker
```bash
docker-compose up
```

### 5. Executar Sidekiq (para jobs)
```bash
bundle exec sidekiq
```

## Exemplos de Uso da API

### 1. Adicionar produto ao carrinho
```bash
curl -X POST http://localhost:3000/cart \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 2}'
```

### 2. Ver carrinho atual
```bash
curl http://localhost:3000/cart
```

### 3. Adicionar mais itens
```bash
curl -X POST http://localhost:3000/cart/add_item \
  -H "Content-Type: application/json" \
  -d '{"product_id": 1, "quantity": 1}'
```

### 4. Remover produto
```bash
curl -X DELETE http://localhost:3000/cart/1
```

## Estrutura de Response

```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

## Arquivos Criados/Modificados

### Novos Modelos:
- `app/models/cart_item.rb`

### Migrações:
- `db/migrate/20240503000000_create_cart_items.rb`
- `db/migrate/20240503000001_add_abandoned_fields_to_carts.rb`

### Controllers:
- `app/controllers/carts_controller.rb` (implementado)

### Jobs:
- `app/sidekiq/mark_cart_as_abandoned_job.rb` (implementado)

### Testes:
- `spec/models/cart_item_spec.rb`
- `spec/requests/carts_spec.rb` (implementado)
- `spec/sidekiq/mark_cart_as_abandoned_job_spec.rb` (implementado)

### Factories:
- `spec/factories/products.rb`
- `spec/factories/carts.rb`
- `spec/factories/cart_items.rb`

### Configurações:
- `config/routes.rb` (rotas adicionadas)
- `config/schedule.yml` (agendamento de jobs)
- `docker-compose.yml` (completo)
- `Gemfile` (factory_bot_rails e faker)

## Características Técnicas

- **Clean Code:** Código organizado e legível
- **Validações:** Quantidade positiva, produtos únicos por carrinho
- **Performance:** Queries otimizadas com includes
- **Testes:** Cobertura completa com cenários de erro
- **Docker:** Ambiente containerizado completo
- **Jobs:** Processamento assíncrono para limpeza

Toda a implementação segue as especificações do desafio e boas práticas do Rails!
