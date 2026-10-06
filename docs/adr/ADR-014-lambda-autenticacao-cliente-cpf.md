# ADR-014: Lambda Para Autenticacao Externa De Cliente Com CPF E Senha

**Status:** Aceito  
**Data:** 2026-09-27  
**Atualizacao:** 2026-10-06  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

A aplicacao possui autenticacao JWT para usuarios internos da oficina, baseada em usuario, senha e perfis operacionais. O Tech Challenge exige uma Function Serverless capaz de autenticar clientes externos, consultar a existencia e o status do cliente no banco e emitir JWT para APIs protegidas.

CPF e usado como identificador do cliente, mas nao como credencial unica. A autenticacao externa implementada exige CPF e senha. A senha e comparada com o hash bcrypt armazenado em `clientes.senha_hash`.

## Decisao

Foi criada uma Lambda dedicada para autenticacao externa de cliente com CPF e senha.

A Lambda e responsavel por:

- receber CPF e senha;
- normalizar e validar o CPF;
- consultar o cliente no PostgreSQL;
- verificar existencia e status;
- comparar a senha recebida com `clientes.senha_hash` usando bcrypt;
- emitir JWT externo com `tipo=CLIENTE`;
- retornar resposta sanitizada para erros de CPF invalido, senha invalida, cliente inexistente ou cliente sem acesso.

O runtime da Lambda e Node.js 20.x. A escolha prioriza empacotamento simples, baixo acoplamento com a aplicacao Java, inicializacao leve para o contexto do desafio, disponibilidade madura no AWS Lambda, facilidade de testes automatizados e bibliotecas consolidadas para JWT, bcrypt e PostgreSQL.

## Separacao De Identidades

O projeto possui dois tipos de identidade:

| Identidade | Origem | Uso |
|---|---|---|
| Usuario interno | Aplicacao principal | Operacoes da oficina com perfis `ATENDENTE`, `MECANICO` e `GESTOR` |
| Cliente externo | Lambda Auth CPF + Senha | Jornadas do cliente usando CPF, senha e token de cliente |

O token de cliente externo nao concede permissoes administrativas ou operacionais.

A validacao posterior do JWT no API Gateway e na aplicacao Spring Boot foi registrada separadamente na [`ADR-018`](./ADR-018-validacao-jwt-cliente-externo.md). Esta ADR limita a decisao da Lambda a autenticacao do cliente externo e emissao do token.

## Claims Do JWT Externo

O JWT de cliente contem:

- `sub`: CPF normalizado;
- `clienteId`: identificador do cliente;
- `tipo`: `CLIENTE`;
- `status`: status do cliente;
- `iat`: emissao;
- `exp`: expiracao.

## Modelo De Dados

A tabela `clientes` possui o campo `senha_hash`, usado somente para armazenar hash bcrypt da senha do cliente externo. Senhas em texto puro nao sao gravadas.

Registros legados podem existir sem senha hash. Esses registros precisam receber senha inicial ou fluxo controlado de definicao de senha antes de usar a autenticacao externa.

## Justificativa

- Atende ao requisito de Function Serverless.
- Usa CPF como identificador e senha como fator secreto.
- Desacopla autenticacao de cliente da autenticacao interna da oficina.
- Evita misturar `CLIENTE` com `ATENDENTE`, `MECANICO` e `GESTOR`.
- Permite evoluir seguranca de borda sem alterar o login interno.
- Integra de forma natural com API Gateway.

## Consequencias Positivas

- Fluxo claro de autenticacao para clientes.
- Menor risco de acesso indevido baseado apenas em conhecimento do CPF.
- Melhor isolamento de responsabilidade.
- Menor risco de conceder perfis internos a clientes.
- Possibilidade de escalar autenticacao independentemente da aplicacao.

## Consequencias Negativas

- Necessidade de conectividade segura entre Lambda e banco.
- Necessidade de gerenciar segredo de assinatura JWT.
- Necessidade de manter `senha_hash` para clientes externos.
- Risco de enumeracao de CPF se respostas nao forem bem sanitizadas.
- Exige atualizacao da aplicacao para reconhecer token de cliente externo.

## Alternativas Consideradas

| Alternativa | Motivo da nao escolha |
|---|---|
| Autenticar apenas por CPF | CPF e identificador, nao segredo; risco de personificacao |
| Criar endpoint de CPF e senha dentro da aplicacao Spring | Atende funcionalmente, mas nao cumpre o requisito serverless |
| Reusar login interno com usuario e senha | Mistura atores internos e clientes externos |
| Usar Cognito nesta fase | Solucao robusta, mas adiciona complexidade maior que a exigida pelo desafio |

## Relacao Com Outros Documentos

- `RFC-002`: detalha o fluxo de autenticacao externa com CPF e senha.
- `ADR-013`: define API Gateway como entrada oficial.
- `ADR-004`: documenta JWT stateless interno.
- `ADR-018`: define validacao do JWT externo de cliente no API Gateway e na aplicacao.
