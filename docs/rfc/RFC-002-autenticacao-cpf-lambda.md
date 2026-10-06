# RFC-002: Autenticacao Por CPF Com Lambda

**Status:** Proposto  
**Data:** 2026-09-27  
**Contexto:** Tech Challenge - Autenticacao e API Gateway  
**Escopo:** Cliente externo

## Contexto

A aplicacao atual possui autenticacao JWT interna por usuario e senha, com perfis operacionais como `ATENDENTE`, `MECANICO` e `GESTOR`. O novo desafio exige proteger rotas sensiveis com autenticacao via CPF e criar uma Function Serverless para validar o CPF, consultar a existencia e o status do cliente e gerar um JWT valido para APIs protegidas.

## Problema

O modelo atual atende usuarios internos da oficina, mas nao representa a autenticacao de clientes externos por CPF. Misturar clientes externos com usuarios internos poderia enfraquecer o modelo de autorizacao e dificultar auditoria.

## Fluxo Proposto

1. Cliente externo informa CPF no endpoint publico do API Gateway.
2. API Gateway encaminha a requisicao para a Lambda Auth CPF.
3. Lambda normaliza e valida o CPF.
4. Lambda consulta o cliente no PostgreSQL.
5. Lambda verifica se o cliente existe e esta apto a acessar APIs protegidas.
6. Lambda gera JWT com claims de cliente externo.
7. API Gateway devolve o token ao cliente.
8. Cliente usa `Authorization: Bearer <token>` para consumir APIs protegidas.

## Contrato Esperado Da Lambda

Entrada proposta:

```json
{
  "cpf": "12345678909"
}
```

Saida em caso de sucesso:

```json
{
  "token": "<jwt>",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "clienteId": 123,
  "status": "ATIVO"
}
```

Saidas de erro esperadas:

| Cenario | Status HTTP | Resposta |
|---|---:|---|
| CPF invalido | 400 | Mensagem sanitizada |
| Cliente nao encontrado | 404 | Mensagem sanitizada |
| Cliente inativo/bloqueado | 403 | Mensagem sanitizada |
| Falha inesperada | 500 | Mensagem sanitizada e log interno |

## Claims Esperadas No JWT

| Claim | Conteudo |
|---|---|
| `sub` | CPF normalizado |
| `clienteId` | Identificador interno do cliente |
| `tipo` | `CLIENTE` |
| `status` | Status do cliente |
| `iss` | Emissor da autenticacao serverless |
| `iat` | Data/hora de emissao |
| `exp` | Data/hora de expiracao |

## Integracao Com API Gateway

O API Gateway sera a entrada publica oficial. A rota de autenticacao por CPF sera publica. As rotas sensiveis deverao exigir JWT de cliente externo ou JWT de usuario interno, conforme o caso de uso.

Todas as chamadas externas de API devem passar pelo API Gateway. Isso inclui clientes externos, atendentes, mecanicos e gestores. A Lambda Auth CPF participa apenas da autenticacao do cliente externo; usuarios internos continuam usando o login da aplicacao principal.

Para defesa em profundidade, o JWT externo de cliente devera ser validado em dois pontos: no API Gateway, como controle de borda, e na aplicacao Spring Boot, antes da execucao dos casos de uso protegidos. A decisao arquitetural permanente esta registrada na [`ADR-018`](../ADRS/ADR-018-validacao-jwt-cliente-externo.md).

| Ator | Rota de autenticacao | Quem autentica | Token resultante |
|---|---|---|---|
| Cliente externo | Rota publica de CPF no API Gateway | Lambda Auth CPF | JWT de cliente externo |
| Atendente | `/api/auth/login` via API Gateway | Aplicacao principal | JWT interno com role `ATENDENTE` |
| Mecanico | `/api/auth/login` via API Gateway | Aplicacao principal | JWT interno com role `MECANICO` |
| Gestor | `/api/auth/login` via API Gateway | Aplicacao principal | JWT interno com role `GESTOR` |

## Consulta Ao PostgreSQL

A Lambda devera consultar a tabela de clientes por documento normalizado. Nas proximas fases sera necessario avaliar a inclusao de um campo de status do cliente, como `ATIVO`, `INATIVO` ou `BLOQUEADO`, caso o modelo atual ainda nao represente esse estado explicitamente.

## Separacao Entre Cliente Externo E Usuario Interno

O token de cliente externo nao deve conceder permissoes de `ATENDENTE`, `MECANICO` ou `GESTOR`. Ele deve ser usado apenas para jornadas de cliente, como consulta de suas ordens, abertura de solicitacao ou acompanhamento de status.

## Riscos De Seguranca

- Exposicao indevida de existencia de CPF.
- Forca bruta de CPFs.
- Token com duracao excessiva.
- Logs contendo CPF completo.
- Compartilhamento indevido da chave de assinatura.
- Lambda com permissao ampla demais no banco.

## Mitigacoes Propostas

- Sanitizar respostas de erro.
- Aplicar rate limit no API Gateway.
- Usar expiracao curta para JWT de cliente.
- Mascarar CPF em logs.
- Armazenar segredo JWT em Secret Manager ou variavel segura de ambiente.
- Restringir permissao da Lambda ao minimo necessario.

## Relacao Com O Tech Challenge

Esta proposta atende o requisito de Function Serverless para validar CPF, consultar cliente e gerar token JWT para consumo de APIs protegidas.

## Relacao Com Outros Documentos

- [`ADR-014`](../ADRS/ADR-014-lambda-autenticacao-cliente-cpf.md): Lambda para autenticacao externa por CPF.
- [`ADR-018`](../ADRS/ADR-018-validacao-jwt-cliente-externo.md): validacao do JWT externo no API Gateway e na aplicacao.
- [`auth-cpf-sequence.puml`](../diagramas/infra/auth-cpf-sequence.puml): diagrama de sequencia do fluxo de autenticacao por CPF.
