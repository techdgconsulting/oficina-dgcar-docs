# Modelo Relacional

O modelo relacional da Oficina DGCar representa o ciclo completo de atendimento da oficina.

## Relacionamentos Principais

| Relacionamento | Cardinalidade | Descricao |
|---|---|---|
| Cliente -> Veiculos | 1:N | Um cliente pode possuir varios veiculos |
| Cliente -> Ordens de servico | 1:N | Um cliente pode abrir varias OS |
| Veiculo -> Ordens de servico | 1:N | Um veiculo pode aparecer em varias OS ao longo do tempo |
| Ordem de servico -> Itens | 1:N | Uma OS possui servicos e pecas |
| Ordem de servico -> Orcamento | 1:1 | Uma OS pode possuir orcamento associado |
| Ordem de servico -> Pagamento | 1:1 | Uma OS pode possuir pagamento associado |
| Ordem de servico -> Execucao | 1:1 | Uma OS possui acompanhamento de execucao |
| Execucao -> Diagnostico | 1:1 | A execucao pode possuir diagnostico tecnico |
| Ordem de servico -> Entrega | 1:1 | Uma OS pode possuir registro de entrega |
| Ordem de servico -> Encerramento | 1:1 | Uma OS pode possuir encerramento |
| Orcamento -> Decisao externa | 1:N | Um orcamento pode gerar solicitacoes de decisao por token |

## Campos Relevantes Para O Tech Challenge 3

| Tabela | Campo | Finalidade |
|---|---|---|
| `clientes` | `documento` | CPF/CNPJ do cliente, usado pela Lambda Auth CPF |
| `clientes` | `senha_hash` | Hash bcrypt da senha do cliente externo |
| `clientes` | `status_cliente` | Campo planejado para controle de acesso do cliente |
| `ordens_servico` | `numero` | Numero legivel usado pelo cliente para consulta de OS |
| `ordens_servico` | `status` | Estado atual da OS |
| `ordens_servico` | `cliente_id` | Vinculo interno da OS com cliente |
| `orcamento_decisao_cliente` | `token_hash` | Token opaco de aprovacao/recusa de orcamento |

## Regra De Consulta Externa

Cliente externo nao consulta OS por `clienteId`, pois esse identificador e interno.

O fluxo demonstravel usa:

```text
GET /api/ordens-servico/numero/{numero}
Authorization: Bearer <jwt-cliente>
```

A API valida se o CPF da OS corresponde ao `sub` do JWT externo.
