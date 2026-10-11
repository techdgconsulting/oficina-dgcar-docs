# Dicionario De Dados

Resumo dos principais dados usados pela solucao. O schema fisico e versionado por migrations Flyway no repositorio `oficina-dgcar-api`.

## clientes

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do cliente. |
| `documento` | CPF ou CNPJ, unico no cadastro. |
| `tipo_documento` | Tipo do documento, `CPF` ou `CNPJ`. |
| `nome` | Nome do cliente. |
| `telefone` | Telefone de contato. |
| `email` | E-mail de contato. |
| `cep` | CEP do endereco do cliente. |
| `logradouro` | Logradouro obtido/informado no cadastro. |
| `bairro` | Bairro do endereco. |
| `cidade` | Cidade do endereco. |
| `uf` | Unidade federativa do endereco. |
| `senha_hash` | Hash bcrypt usado na autenticacao externa por CPF e senha. Senha em texto puro nao e armazenada. |
| `status_cliente` | Status operacional do cliente externo usado para permitir ou bloquear autenticacao. |

## veiculos

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do veiculo. |
| `placa` | Placa unica do veiculo. |
| `marca` | Marca do veiculo. |
| `modelo` | Modelo do veiculo. |
| `ano` | Ano do veiculo. |
| `cliente_id` | Cliente proprietario. |

## usuarios

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do usuario. |
| `username` | Login unico do usuario interno. |
| `password` | Hash da senha do usuario interno. |
| `role` | Perfil interno usado no RBAC: `ATENDENTE`, `MECANICO` ou `GESTOR`. |

## servicos

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do servico. |
| `nome` | Nome do servico. |
| `descricao` | Descricao do servico. |
| `valor_unitario` | Valor base do servico. |
| `tempo_estimado_minutos` | Tempo estimado de execucao em minutos. |

## pecas

| Campo | Descricao |
|---|---|
| `id` | Identificador interno da peca. |
| `nome` | Nome da peca. |
| `descricao` | Descricao da peca. |
| `quantidade_estoque` | Quantidade disponivel em estoque. |
| `estoque_minimo` | Limite minimo usado para controle operacional. |
| `valor_unitario` | Valor unitario da peca. |

## ordens_servico

| Campo | Descricao |
|---|---|
| `id` | Identificador interno da OS. |
| `numero` | Numero legivel e unico da OS, usado em consultas externas. |
| `status` | Estado atual da OS. |
| `data_criacao` | Data de abertura. |
| `data_finalizacao` | Data de finalizacao. |
| `atendente_nome` | Nome do atendente autenticado que abriu a OS. |
| `cliente_id` | Cliente associado. |
| `veiculo_id` | Veiculo associado. |

## itens_os

| Campo | Descricao |
|---|---|
| `id` | Identificador do item. |
| `tipo` | Tipo do item: peca ou servico. |
| `descricao` | Descricao aplicada ao item da OS. |
| `quantidade` | Quantidade. |
| `valor_unitario` | Valor aplicado. |
| `referencia_id` | ID da peca ou servico de catalogo, conforme `tipo`. |
| `estoque_reduzido` | Indica se a baixa de estoque da peca ja foi aplicada para este item. |
| `ordem_servico_id` | OS associada. |

## diagnosticos

| Campo | Descricao |
|---|---|
| `id` | Identificador interno do diagnostico. |
| `descricao_problema` | Descricao tecnica do problema identificado. |
| `data_diagnostico` | Data de registro do diagnostico. |
| `status` | Estado do diagnostico. |

## execucoes

| Campo | Descricao |
|---|---|
| `id` | Identificador interno da execucao. |
| `ordem_servico_id` | OS acompanhada pela execucao. |
| `diagnostico_id` | Diagnostico associado, quando houver. |
| `status` | Estado da execucao tecnica. |
| `data_inicio` | Inicio da execucao. |
| `data_fim` | Fim da execucao. |
| `mecanico_nome` | Nome do mecanico autenticado que executou o servico. |

## orcamentos

| Campo | Descricao |
|---|---|
| `id` | Identificador do orcamento. |
| `ordem_servico_id` | OS associada. |
| `status` | Estado do orcamento. |
| `valor_total` | Valor total. |
| `data_criacao` | Data de geracao. |
| `data_validade` | Data limite de validade. |
| `data_aprovacao` | Data em que o orcamento foi aprovado. |

## orcamento_decisao_cliente

| Campo | Descricao |
|---|---|
| `id` | Identificador da solicitacao de decisao. |
| `orcamento_id` | Orcamento associado. |
| `ordem_servico_id` | OS associada. |
| `token_hash` | Hash do token opaco enviado ao cliente. |
| `status` | Estado da decisao externa. |
| `data_criacao` | Data de criacao da solicitacao. |
| `data_expiracao` | Data de expiracao do token. |
| `data_decisao` | Data da aprovacao ou recusa. |
| `email_destino` | E-mail usado para envio da decisao externa. |

## pagamentos

| Campo | Descricao |
|---|---|
| `id` | Identificador do pagamento. |
| `ordem_servico_id` | OS associada. |
| `status` | Estado do pagamento. |
| `metodo_pagamento` | Metodo usado. |
| `valor` | Valor pago ou tentado. |
| `data_pagamento` | Data do pagamento aprovado. |
| `transaction_id` | ID retornado pelo gateway. |
| `gateway_mensagem` | Mensagem retornada pelo gateway de pagamento. |

## entregas

| Campo | Descricao |
|---|---|
| `id` | Identificador da entrega. |
| `ordem_servico_id` | OS associada. |
| `status` | Estado da entrega. |
| `data_entrega` | Data de entrega do veiculo. |
| `observacoes` | Observacoes registradas na entrega. |

## encerramentos

| Campo | Descricao |
|---|---|
| `id` | Identificador do encerramento. |
| `ordem_servico_id` | OS associada. |
| `status` | Estado do encerramento. |
| `data_encerramento` | Data do encerramento formal da OS. |
