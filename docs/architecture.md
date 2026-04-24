# Plano de Arquitetura: Beauty Planner (Cloud Native & CQRS)

## Objetivo
Criar a fundação de um sistema de gestão de salão/clínica (Beauty Planner) utilizando arquitetura Cloud Native, Microsserviços e o padrão CQRS (Command Query Responsibility Segregation).

## Estrutura do Repositório
O projeto adotará uma estrutura multi-módulo dividida por responsabilidades:
- `/services`: Contém os microsserviços executáveis.
- `/libs`: Bibliotecas e códigos compartilhados (ex: core domain).
- `/platform`: Código de infraestrutura, automações, manifestos Kubernetes, Terraform e scripts de deploy (focado em Platform Engineering).

## Microsserviços (Domínio: Planner)
O domínio principal é o `planner`, responsável por gerenciar clientes (`customers`), procedimentos (`procedures`) e agendamentos (`appointments`).

1. **`planner-query`**
   - **Responsabilidade:** API de leitura (Read Model). Retorna dados otimizados para a interface do usuário.
   - **Banco de Dados Futuro:** MongoDB.

2. **`planner-command`**
   - **Responsabilidade:** API de escrita (Write Model). Processa as regras de negócio, validações e mutações de estado.
   - **Banco de Dados Futuro:** PostgreSQL.

3. **`planner-sync`**
   - **Responsabilidade:** Worker em background que consome eventos do Command e atualiza as bases de leitura do Query.
   - **Mensageria Futura:** RabbitMQ.

## Stack Tecnológica Base
- **Linguagem:** Java 25
- **Framework:** Spring Boot 3.x
- **Namespace/Pacotes:** `io.planner`

## Próximos Passos (Fase de Inicialização)
1. **Documentação:** Salvar este plano de arquitetura na pasta `/docs/architecture.md` do repositório principal.
2. **Estrutura de Pastas:** Criar as pastas `/services`, `/libs` e `/platform` na raiz do projeto.
3. **Geração dos Projetos:** Utilizar a API do Spring Initializr (via `curl`) para gerar os 3 projetos (`planner-query`, `planner-command`, `planner-sync`) dentro da pasta `/services`.
   - **Dependências Iniciais:** Apenas `web` (Spring Web) e `actuator` (Spring Boot Actuator). Isso garantirá que os projetos sejam leves e já estejam preparados para expor os *health checks* (Liveness/Readiness probes) necessários para o Kubernetes.
4. **Configuração da IDE:** Criar um arquivo `beautyplanner.code-workspace` na raiz do projeto configurando as pastas `services/planner-command`, `services/planner-query` e `services/planner-sync` como projetos independentes (Multi-root Workspace). Isso garantirá que as extensões do VS Code carreguem os projetos Java nativamente, sem forçar configurações Maven (POM) globais que poluem o repositório poliglota.
