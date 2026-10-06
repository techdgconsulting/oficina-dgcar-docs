# Plano De Modelagem Do Banco De Dados - Tech Challenge 3

## Objetivo

Este documento define os artefatos de modelagem relacional que devem ser produzidos para transformar o banco de dados da Oficina Mecânica DGCar em evidência arquitetural do Tech Challenge 3.

O banco permanece PostgreSQL gerenciado em Amazon RDS, conforme [`ADR-017`](../ADRS/ADR-017-postgresql-gerenciado.md). As alterações físicas de schema devem ocorrer somente por migrations Flyway versionadas.

## Artefatos Esperados

- Diagrama ER do modelo relacional.
- Dicionário de dados.
- Justificativa formal do PostgreSQL.
- Documentação de cardinalidades.
- Revisão de índices.
- Avaliação do campo `status_cliente`.
- Relação entre dados operacionais e dashboards de observabilidade.

## Entidades Principais

| Entidade | Papel no domínio |
|---|---|
| `clientes` | Representa pessoa física ou jurídica atendida pela oficina. |
| `veiculos` | Veículos vinculados aos clientes. |
| `ordens_servico` | Núcleo operacional do atendimento. |
| `itens_os` | Serviços e peças associados à ordem de serviço. |
| `orcamentos` | Proposta comercial vinculada à ordem. |
| `orcamento_decisao_cliente` | Decisão externa do cliente por token opaco. |
| `execucoes` | Controle de execução técnica e diagnóstico. |
| `pagamentos` | Registro de pagamento e integração com gateway. |
| `entregas` | Controle de liberação e retirada do veículo. |
| `encerramentos` | Fechamento formal da ordem de serviço. |
| `pecas` | Catálogo e estoque de peças. |
| `servicos` | Catálogo de serviços. |
| `usuarios` | Identidades internas da oficina. |

## Cardinalidades A Documentar

| Relação | Cardinalidade esperada | Observação |
|---|---|---|
| cliente -> veículos | 1:N | Um cliente pode possuir vários veículos. |
| cliente -> ordens | 1:N | Uma ordem pertence a um cliente. |
| veículo -> ordens | 1:N | Um veículo pode ter várias ordens ao longo do tempo. |
| ordem -> itens | 1:N | Uma ordem contém serviços e/ou peças. |
| ordem -> orçamento | 1:0..N | O fluxo pode gerar orçamento para aprovação. |
| ordem -> pagamento | 1:0..N | Pagamentos registram tentativa e resultado. |
| ordem -> execução | 1:0..1 ou 1:N | Deve ser confirmado no modelo atual antes do ER final. |
| ordem -> entrega | 1:0..1 | Entrega ocorre após finalização e pagamento aprovado. |
| ordem -> encerramento | 1:0..1 | Encerramento formaliza conclusão da OS. |
| orçamento -> decisão externa | 1:N | Decisões anteriores podem expirar quando uma nova solicitação é emitida. |

## Índices A Revisar

| Índice/campo | Motivo |
|---|---|
| `clientes.documento` | Busca por CPF/CNPJ e consulta da Lambda Auth CPF. |
| `ordens_servico.status` | Filtros por etapa operacional. |
| `ordens_servico.cliente_id` | Listagem de ordens do cliente autenticado. |
| `ordens_servico.data_criacao` | Ordenação da fila e métricas temporais. |
| `ordens_servico(status, data_criacao)` | Fila operacional priorizada por status e antiguidade. |
| `ordens_servico(cliente_id, data_criacao)` | Histórico de OS por cliente. |
| `ordens_servico(status, data_finalizacao)` | Métricas por status e período. |
| `orcamento_decisao_cliente.token_hash` | Validação de decisão externa por token opaco. |
| `pagamentos.transaction_id` | Rastreabilidade de integração de pagamento. |

## Avaliação Do Campo `status_cliente`

A Lambda Auth CPF precisa consultar existência e status do cliente. Caso o modelo atual não possua um campo explícito para o status do cliente, deve ser avaliada uma migration com campo como:

```sql
ALTER TABLE clientes
ADD COLUMN status_cliente VARCHAR(20) NOT NULL DEFAULT 'ATIVO';
```

Estados mínimos recomendados:

| Status | Significado |
|---|---|
| `ATIVO` | Cliente pode autenticar e consumir rotas protegidas. |
| `INATIVO` | Cliente existe, mas não deve consumir rotas protegidas. |
| `BLOQUEADO` | Cliente teve acesso suspenso por regra operacional ou segurança. |

Essa alteração deve ser acompanhada de validação na Lambda, testes automatizados e documentação no dicionário de dados.

## Relação Com Observabilidade

O modelo relacional deve sustentar dashboards e métricas como:

- volume diário de ordens de serviço;
- ordens por status;
- tempo médio por status;
- falhas de pagamento;
- falhas de notificação;
- acompanhamento de decisões externas de orçamento;
- consultas de OS por cliente autenticado.

## Critérios Para Considerar A Modelagem Fechada

- Diagrama ER versionado em `docs/diagramas`.
- Dicionário de dados com tabelas, colunas, tipos, chaves e índices.
- Cardinalidades documentadas.
- Justificativa do PostgreSQL referenciada no README.
- Decisão sobre `status_cliente` registrada e, se aprovada, implementada por migration Flyway.
- Relação entre modelo e dashboards documentada.
