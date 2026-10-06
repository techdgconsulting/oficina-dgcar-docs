# ADR-014: Lambda Para Autenticacao Externa De Cliente Por CPF

**Status:** Aceito  
**Data:** 2026-09-27  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

A aplicacao atual possui autenticacao JWT para usuarios internos da oficina, baseada em usuario, senha e perfis operacionais. O novo desafio exige uma Function Serverless capaz de autenticar clientes por CPF, consultar a existencia e o status do cliente no banco e emitir JWT para APIs protegidas.

## Decisao

Criar uma Lambda dedicada para autenticacao externa de cliente por CPF.

A Lambda sera responsavel por:

- receber CPF;
- normalizar e validar formato;
- consultar o cliente no PostgreSQL;
- verificar existencia e status;
- emitir JWT de cliente externo;
- retornar resposta sanitizada para erros de CPF invalido, cliente inexistente ou cliente sem acesso.

O runtime alvo da Lambda sera Node.js 20.x. A escolha prioriza empacotamento simples, baixo acoplamento com a aplicacao Java, inicializacao leve para o contexto do desafio, disponibilidade madura no AWS Lambda, facilidade de testes automatizados e boa disponibilidade de bibliotecas para JWT e PostgreSQL.

## Separacao De Identidades

O projeto passara a ter dois tipos de identidade:

| Identidade | Origem | Uso |
|---|---|---|
| Usuario interno | Aplicacao principal | Operacoes da oficina com perfis `ATENDENTE`, `MECANICO` e `GESTOR` |
| Cliente externo | Lambda Auth CPF | Jornadas do cliente usando CPF e token de cliente |

O token de cliente externo nao deve conceder permissoes administrativas ou operacionais.

O token emitido pela Lambda devera ser validado no API Gateway e tambem pela aplicacao principal, conforme [`ADR-018`](./ADR-018-validacao-jwt-cliente-externo.md). Essa dupla validacao evita que a aplicacao dependa exclusivamente da borda para aplicar autorizacao em rotas de cliente.

## Claims Esperadas

O JWT de cliente deve conter, no minimo:

- `sub`: CPF normalizado;
- `clienteId`: identificador do cliente;
- `tipo`: `CLIENTE`;
- `status`: status do cliente;
- `iat`: emissao;
- `exp`: expiracao.

## Justificativa

- Atende diretamente o requisito de Function Serverless.
- Desacopla autenticacao de cliente da autenticacao interna da oficina.
- Permite evoluir seguranca de borda sem misturar perfis internos e externos.
- Reduz carga da aplicacao principal para o fluxo de emissao de token de cliente.
- Integra de forma natural com API Gateway.

## Consequencias Positivas

- Fluxo claro de autenticacao para clientes.
- Melhor isolamento de responsabilidade.
- Menor risco de conceder perfis internos a clientes.
- Possibilidade de escalar autenticacao independentemente da aplicacao.

## Consequencias Negativas

- Necessidade de conectividade segura entre Lambda e banco.
- Necessidade de gerenciar segredo de assinatura JWT.
- Risco de enumeracao de CPF se respostas nao forem bem sanitizadas.
- Exige atualizacao da aplicacao para reconhecer token de cliente externo.

## Alternativas Consideradas

| Alternativa | Motivo da nao escolha |
|---|---|
| Criar endpoint CPF dentro da aplicacao Spring | Atende funcionalmente, mas nao cumpre o requisito serverless |
| Reusar login interno com usuario/senha | Mistura atores internos e clientes externos |
| Usar Cognito nesta fase | Solucao robusta, mas adiciona complexidade maior que a exigida pelo desafio |

## Relacao Com Outros Documentos

- `RFC-002`: detalha o fluxo proposto de autenticacao por CPF.
- `ADR-013`: define API Gateway como entrada oficial.
- `ADR-004`: documenta JWT stateless atual.
- `ADR-018`: define validacao do JWT externo de cliente no API Gateway e na aplicacao.
