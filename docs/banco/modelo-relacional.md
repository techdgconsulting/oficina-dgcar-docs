# Modelo Relacional

O modelo relacional da Oficina DGCar representa o ciclo completo de atendimento da oficina, desde cadastro de cliente e veiculo ate abertura de OS, itens, diagnostico, execucao, orcamento, decisao externa, pagamento, entrega e encerramento.

O schema fisico e versionado por migrations Flyway no repositorio `oficina-dgcar-api`.

## Entidades

| Tabela | Papel no modelo |
|---|---|
| `clientes` | Cadastro de clientes externos, incluindo documento, endereco, senha hash e status de autenticacao. |
| `veiculos` | Veiculos vinculados aos clientes. |
| `usuarios` | Identidades internas da oficina usadas no RBAC. |
| `servicos` | Catalogo de servicos. |
| `pecas` | Catalogo de pecas e controle de estoque. |
| `ordens_servico` | Nucleo operacional do atendimento. |
| `itens_os` | Itens de peca ou servico vinculados a OS. |
| `diagnosticos` | Diagnosticos tecnicos associados a execucoes. |
| `execucoes` | Acompanhamento tecnico da OS. |
| `orcamentos` | Propostas comerciais vinculadas a OS. |
| `orcamento_decisao_cliente` | Decisao externa do cliente por token opaco. |
| `pagamentos` | Registros de pagamento e integracao com gateway. |
| `entregas` | Registro de entrega do veiculo. |
| `encerramentos` | Fechamento formal da OS. |

## Relacionamentos Principais

| Relacionamento | Cardinalidade fisica | Descricao |
|---|---|---|
| Cliente -> Veiculos | 1:N | Um cliente pode possuir varios veiculos. |
| Cliente -> Ordens de servico | 1:N | Uma OS pertence a um cliente. |
| Veiculo -> Ordens de servico | 1:N | Um veiculo pode aparecer em varias OS ao longo do tempo. |
| Ordem de servico -> Itens | 1:N | Uma OS contem servicos e pecas. |
| Ordem de servico -> Execucoes | 1:N | O schema permite mais de um registro de acompanhamento tecnico por OS. |
| Execucao -> Diagnostico | N:1 opcional | Uma execucao pode apontar para um diagnostico tecnico. |
| Ordem de servico -> Orcamentos | 1:N | Uma OS pode gerar orcamentos ao longo do fluxo. |
| Orcamento -> Decisoes externas | 1:N | Um orcamento pode gerar solicitacoes de decisao por token. |
| Ordem de servico -> Decisoes externas | 1:N | A decisao externa tambem referencia diretamente a OS. |
| Ordem de servico -> Pagamentos | 1:N | Uma OS pode registrar tentativas e resultados de pagamento. |
| Ordem de servico -> Entregas | 1:N | O schema permite registros de entrega associados a OS. |
| Ordem de servico -> Encerramentos | 1:N | O schema permite registros de encerramento associados a OS. |
| Servico/Peca -> Itens | Referencia logica | `itens_os.referencia_id` aponta para `servicos.id` ou `pecas.id` conforme `itens_os.tipo`; nao ha FK fisica para essas duas tabelas. |

## Campos Relevantes Para O Tech Challenge 3

| Tabela | Campo | Finalidade |
|---|---|---|
| `clientes` | `documento` | CPF/CNPJ do cliente, usado pela Lambda Auth CPF + Senha. |
| `clientes` | `cep`, `logradouro`, `bairro`, `cidade`, `uf` | Endereco do cliente, preenchido no cadastro e apoiado pela integracao ViaCEP. |
| `clientes` | `senha_hash` | Hash bcrypt da senha do cliente externo. |
| `clientes` | `status_cliente` | Controle de acesso do cliente externo na autenticacao CPF + senha. |
| `ordens_servico` | `numero` | Numero legivel usado pelo cliente para consulta de OS. |
| `ordens_servico` | `status` | Estado atual da OS. |
| `ordens_servico` | `cliente_id` | Vinculo interno da OS com cliente. |
| `ordens_servico` | `atendente_nome` | Identificacao do atendente autenticado no momento da abertura da OS. |
| `execucoes` | `mecanico_nome` | Identificacao do mecanico autenticado no acompanhamento tecnico. |
| `itens_os` | `estoque_reduzido` | Controle para evitar dupla baixa de estoque. |
| `orcamento_decisao_cliente` | `token_hash` | Token opaco de aprovacao/recusa de orcamento. |
| `orcamento_decisao_cliente` | `email_destino` | E-mail usado para envio da decisao externa. |
| `pagamentos` | `transaction_id` | Identificador de rastreabilidade do gateway de pagamento. |
| `pagamentos` | `gateway_mensagem` | Mensagem retornada pelo gateway de pagamento. |

## Ajustes No Modelo Relacional

| Migration | Ajuste | Motivacao |
|---|---|---|
| `V3` | Endereco em `clientes` | Apoiar cadastro completo e integracao ViaCEP. |
| `V4` | `entregas` e `encerramentos` | Representar fechamento operacional da OS. |
| `V5` | `pecas.estoque_minimo` | Permitir controle de estoque minimo. |
| `V7` | Campos de gateway em `pagamentos` | Rastrear integracao de pagamento. |
| `V8`/`V9` | `ordens_servico.numero` | Expor numero legivel de OS sem revelar ID interno. |
| `V10` | `itens_os.estoque_reduzido` | Evitar dupla reducao de estoque. |
| `V11` | `orcamentos.data_aprovacao` e `execucoes.mecanico_nome` | Apoiar KPIs e auditoria operacional. |
| `V12` | `ordens_servico.atendente_nome` | Registrar responsavel pela abertura da OS. |
| `V16` | `orcamento_decisao_cliente` | Permitir aprovacao/recusa externa por token opaco. |
| `V17` | `clientes.senha_hash` | Autenticar cliente externo por CPF e senha sem armazenar senha pura. |
| `V18` | `clientes.status_cliente` | Permitir bloqueio operacional da autenticacao externa. |

## Regra De Consulta Externa

Cliente externo nao consulta OS por `clienteId`, pois esse identificador e interno.

O fluxo demonstravel usa:

```text
GET /api/ordens-servico/numero/{numero}
Authorization: Bearer <jwt-cliente>
```

A API valida se o CPF da OS corresponde ao `sub` do JWT externo.
