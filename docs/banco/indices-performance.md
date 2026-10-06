# Indices E Performance

Indices recomendados para sustentar as consultas operacionais, autenticacao externa e dashboards.

## Clientes

| Indice | Finalidade |
|---|---|
| `clientes(documento)` | Consulta da Lambda Auth por CPF |
| `clientes(email)` | Busca operacional e contato |

## Ordens De Servico

| Indice | Finalidade |
|---|---|
| `ordens_servico(numero)` | Consulta externa por numero de OS |
| `ordens_servico(cliente_id)` | Listagem interna por cliente |
| `ordens_servico(status)` | Fila operacional e dashboards |
| `ordens_servico(data_criacao)` | Ordenacao e metricas temporais |
| `ordens_servico(status, data_criacao)` | Fila operacional priorizada |
| `ordens_servico(cliente_id, status)` | Consultas internas por cliente e status |

## Orcamentos E Decisoes

| Indice | Finalidade |
|---|---|
| `orcamentos(ordem_servico_id)` | Recuperacao por OS |
| `orcamento_decisao_cliente(token_hash)` | Validacao de token opaco |
| `orcamento_decisao_cliente(status, data_expiracao)` | Expiracao e controle operacional |

## Pagamentos

| Indice | Finalidade |
|---|---|
| `pagamentos(ordem_servico_id)` | Consulta de pagamento por OS |
| `pagamentos(status)` | Monitoramento e reconciliacao |

## Observabilidade De Negocio

Consultas de dashboard usam principalmente:

- volume diario de OS por `data_criacao`;
- tempo medio por status;
- quantidade de OS por `status`;
- falhas de pagamento e notificacao.
