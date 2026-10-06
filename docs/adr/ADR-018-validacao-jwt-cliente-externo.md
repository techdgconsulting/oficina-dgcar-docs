# ADR-018: Validacao Do JWT Externo De Cliente

**Status:** Aceito  
**Data:** 2026-10-03  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

O Tech Challenge 3 introduz autenticacao externa de clientes por CPF e senha usando API Gateway e Lambda Auth CPF + Senha. Esse fluxo emite um JWT especifico para clientes externos, separado do JWT interno utilizado por atendentes, mecanicos e gestores.

Como as rotas protegidas de cliente serao consumidas por meio do API Gateway e executadas pela aplicacao Spring Boot no EKS, e necessario definir onde o token externo sera validado.

## Decisao

Validar o JWT externo de cliente em dois pontos:

- no API Gateway, como controle de borda, roteamento e bloqueio inicial de chamadas invalidas;
- na aplicacao Spring Boot, como defesa em profundidade antes da execucao dos casos de uso protegidos.

A aplicacao principal devera reconhecer explicitamente tokens com claim `tipo=CLIENTE`, validar assinatura, emissor, expiracao e claims obrigatorias, e restringir o acesso do cliente aos seus proprios recursos.

## Justificativa

- Reduz dependencia exclusiva do API Gateway para autorizacao.
- Protege a aplicacao em cenarios de chamada indevida, configuracao incorreta de rota ou mudanca futura na borda.
- Mantem separacao clara entre cliente externo e usuarios internos.
- Permite testar regras de autorizacao de cliente na propria suite da aplicacao.
- Facilita auditoria e demonstracao academica do controle de acesso em mais de uma camada.

## Regras De Validacao Esperadas

- O token deve possuir assinatura valida.
- O token deve possuir `iss` esperado para autenticacao serverless de cliente.
- O token deve possuir `tipo=CLIENTE`.
- O token deve possuir `clienteId`.
- O token deve possuir `sub` com CPF normalizado.
- O token nao pode estar expirado.
- O token de cliente nao pode carregar roles internas como `ATENDENTE`, `MECANICO` ou `GESTOR`.
- Endpoints de cliente devem comparar o CPF do token com o recurso solicitado. Na consulta de OS, o cliente informa o numero da OS e a API valida se a ordem pertence ao CPF autenticado.

## Consequencias Positivas

- Maior seguranca por defesa em profundidade.
- Menor risco de escalada indevida de privilegios.
- Separacao explicita entre autorizacao de cliente e RBAC interno.
- Melhor testabilidade das rotas protegidas de cliente.

## Consequencias Negativas

- Aumenta a complexidade do `SecurityConfig` e dos filtros de autenticacao.
- Exige gestao cuidadosa de segredo/chave de assinatura compartilhada ou mecanismo equivalente de validacao.
- Pode haver duplicacao controlada de validacoes entre Gateway e aplicacao.

## Relacao Com Outros Documentos

- [`RFC-002`](../rfc/RFC-002-autenticacao-cpf-lambda.md): autenticacao por CPF e senha com Lambda.
- [`ADR-014`](./ADR-014-lambda-autenticacao-cliente-cpf.md): Lambda para autenticacao externa de cliente.
- [`ADR-013`](./ADR-013-api-gateway-entrada-oficial.md): API Gateway como entrada oficial.
- [`auth-cpf-sequence.puml`](../arquitetura/auth-cpf-sequence.puml): fluxo de autenticacao por CPF e senha.
