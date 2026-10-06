# Dicionario De Dados

Resumo dos principais dados usados pela solucao.

## clientes

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do cliente |
| `nome` | Nome do cliente |
| `documento` | CPF ou CNPJ |
| `tipo_documento` | Tipo do documento |
| `email` | E-mail de contato |
| `telefone` | Telefone de contato |
| `senha_hash` | Hash bcrypt usado na autenticacao externa por CPF e senha |
| `status_cliente` | Campo planejado para status operacional do cliente |

## veiculos

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do veiculo |
| `cliente_id` | Cliente proprietario |
| `placa` | Placa do veiculo |
| `marca` | Marca |
| `modelo` | Modelo |
| `ano` | Ano |

## ordens_servico

| Campo | Descricao |
|---|---|
| `id` | Identificador interno da OS |
| `numero` | Numero legivel da OS |
| `cliente_id` | Cliente associado |
| `veiculo_id` | Veiculo associado |
| `status` | Estado atual da OS |
| `data_criacao` | Data de abertura |
| `data_finalizacao` | Data de finalizacao |

## itens_os

| Campo | Descricao |
|---|---|
| `id` | Identificador do item |
| `ordem_servico_id` | OS associada |
| `tipo` | Peca ou servico |
| `referencia_id` | ID da peca ou servico de catalogo |
| `descricao` | Descricao do item |
| `quantidade` | Quantidade |
| `valor_unitario` | Valor aplicado |

## orcamentos

| Campo | Descricao |
|---|---|
| `id` | Identificador do orcamento |
| `ordem_servico_id` | OS associada |
| `status` | Estado do orcamento |
| `valor_total` | Valor total |
| `data_criacao` | Data de geracao |

## pagamentos

| Campo | Descricao |
|---|---|
| `id` | Identificador do pagamento |
| `ordem_servico_id` | OS associada |
| `status` | Estado do pagamento |
| `metodo_pagamento` | Metodo usado |
| `valor` | Valor pago |
| `transaction_id` | ID retornado pelo gateway |
