# RFC-002: Autenticacao Externa Com CPF E Senha Na Lambda

**Status:** Aceito  
**Data:** 2026-09-27  
**Atualizacao:** 2026-10-06  
**Contexto:** Tech Challenge - Autenticacao e API Gateway  
**Escopo:** Cliente externo

## Contexto

A aplicacao possui autenticacao JWT interna por usuario e senha, com perfis operacionais `ATENDENTE`, `MECANICO` e `GESTOR`. O Tech Challenge adicionou o requisito de autenticar clientes externos por meio de Function Serverless, consultar a existencia e o status do cliente no PostgreSQL e emitir um JWT valido para APIs protegidas.

O fluxo implementado utiliza CPF e senha. O CPF identifica o cliente, mas nao e tratado como credencial suficiente. A senha recebida e comparada com `clientes.senha_hash`, armazenado como hash bcrypt.

## Problema

CPF isolado e dado identificador, nao segredo. Autenticar cliente apenas por CPF aumentaria risco de personificacao, enumeracao e acesso indevido a ordens de servico.

O modelo interno de usuarios tambem nao deve ser reutilizado para clientes externos, porque misturaria atores operacionais da oficina com clientes finais e enfraqueceria a autorizacao baseada em perfis.

## Fluxo Executado

1. Cliente externo informa CPF e senha no endpoint publico do API Gateway.
2. API Gateway encaminha a requisicao para a Lambda Auth CPF + Senha.
3. Lambda normaliza e valida o CPF.
4. Lambda consulta o cliente no PostgreSQL por `clientes.documento`.
5. Lambda verifica existencia e status do cliente.
6. Lambda compara a senha recebida com `clientes.senha_hash` usando bcrypt.
7. Lambda gera JWT com claims de cliente externo.
8. API Gateway devolve o token ao cliente.
9. Cliente usa `Authorization: Bearer <token>` para consumir APIs protegidas.
10. A API Spring valida o JWT externo e autoriza apenas recursos do proprio cliente.

## Contrato Da Lambda

Entrada:

```json
{
  "cpf": "12345678909",
  "senha": "senha-do-cliente"
}
```

Saida em caso de sucesso:

```json
{
  "accessToken": "<jwt>",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "clienteId": 123,
  "status": "ATIVO"
}
```

Saidas de erro:

| Cenario | Status HTTP | Resposta |
|---|---:|---|
| CPF invalido | 400 | Mensagem sanitizada |
| Senha ausente | 400 | Mensagem sanitizada |
| Cliente nao encontrado | 404 | Mensagem sanitizada |
| Cliente inativo ou bloqueado | 403 | Mensagem sanitizada |
| Senha invalida | 401 | Mensagem sanitizada |
| Falha inesperada | 500 | Mensagem sanitizada e log interno |

## Claims Do JWT Externo

| Claim | Conteudo |
|---|---|
| `sub` | CPF normalizado |
| `clienteId` | Identificador interno do cliente |
| `tipo` | `CLIENTE` |
| `status` | Status do cliente |
| `iss` | Emissor da autenticacao serverless |
| `aud` | Audiencia da API protegida |
| `iat` | Data/hora de emissao |
| `exp` | Data/hora de expiracao |

## Integracao Com API Gateway

O API Gateway e a entrada publica oficial. A rota `POST /auth/cpf` e publica e integrada a Lambda Auth CPF + Senha. As rotas sensiveis exigem JWT externo de cliente ou JWT interno de usuario da oficina, conforme o caso de uso.

Todas as chamadas externas passam pelo API Gateway. A Lambda participa apenas da autenticacao de cliente externo; usuarios internos continuam usando o login da aplicacao principal.

Para defesa em profundidade, o JWT externo de cliente e validado em dois pontos: no API Gateway, como controle de borda, e na aplicacao Spring Boot, antes da execucao dos casos de uso protegidos. A decisao arquitetural permanente esta registrada na [`ADR-018`](../adr/ADR-018-validacao-jwt-cliente-externo.md).

| Ator | Rota de autenticacao | Quem autentica | Token resultante |
|---|---|---|---|
| Cliente externo | `POST /auth/cpf` | Lambda Auth CPF + Senha | JWT externo com `tipo=CLIENTE` |
| Atendente | `/api/auth/login` via API Gateway | Aplicacao principal | JWT interno com role `ATENDENTE` |
| Mecanico | `/api/auth/login` via API Gateway | Aplicacao principal | JWT interno com role `MECANICO` |
| Gestor | `/api/auth/login` via API Gateway | Aplicacao principal | JWT interno com role `GESTOR` |

## Consulta Ao PostgreSQL

A Lambda consulta a tabela `clientes` por documento normalizado. O modelo relacional registra `clientes.senha_hash` para autenticar clientes externos sem armazenar senha em texto puro.

Campos usados no fluxo:

| Campo | Uso |
|---|---|
| `clientes.id` | Claim `clienteId` |
| `clientes.documento` | Claim `sub` e busca por CPF |
| `clientes.senha_hash` | Comparacao bcrypt da senha recebida |
| `clientes.status_cliente` | Controle de cliente apto, quando disponivel no modelo |

## Separacao Entre Cliente Externo E Usuario Interno

O token de cliente externo nao concede permissoes de `ATENDENTE`, `MECANICO` ou `GESTOR`. Ele e usado apenas em jornadas de cliente, como consulta de ordens proprias por numero de OS.

O cliente nao informa `clienteId` em rotas externas. A API extrai a identidade do JWT e valida se a OS consultada pertence ao CPF autenticado.

## Riscos De Seguranca

- Exposicao indevida de existencia de CPF.
- Forca bruta de CPF e senha.
- Token com duracao excessiva.
- Logs contendo CPF completo.
- Compartilhamento indevido da chave de assinatura.
- Lambda com permissao ampla demais no banco.

## Controles Aplicados

- Respostas de erro sanitizadas.
- Rate limit no API Gateway.
- JWT com expiracao controlada.
- CPF mascarado em logs.
- Senha armazenada somente como hash bcrypt.
- Segredo JWT armazenado em GitHub Environment ou servico seguro equivalente.
- Permissoes da Lambda restritas ao necessario.
- Validacao do JWT tambem na API Spring Boot.

## Relacao Com O Tech Challenge

Esta arquitetura atende ao requisito de Function Serverless para validar cliente, consultar base de dados e gerar token JWT para consumo de APIs protegidas. A evolucao para CPF + senha preserva o requisito academico e fortalece a seguranca do fluxo.

## Relacao Com Outros Documentos

- [`ADR-014`](../adr/ADR-014-lambda-autenticacao-cliente-cpf.md): Lambda para autenticacao externa de cliente.
- [`ADR-018`](../adr/ADR-018-validacao-jwt-cliente-externo.md): validacao do JWT externo no API Gateway e na aplicacao.
- [`sequencia-auth-cpf-senha.puml`](../arquitetura/sequencia-auth-cpf-senha.puml): diagrama de sequencia do fluxo de autenticacao.
- [`sequencia-consulta-os-cliente.puml`](../arquitetura/sequencia-consulta-os-cliente.puml): diagrama de consulta protegida por numero de OS.
