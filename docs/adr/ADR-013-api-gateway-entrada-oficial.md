# ADR-013: API Gateway Como Entrada Oficial

**Status:** Aceito  
**Data:** 2026-09-27  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

A aplicacao atual e exposta em Kubernetes por meio de Service `LoadBalancer`. Para a nova fase do Tech Challenge, a arquitetura deve incluir um API Gateway para controle, roteamento e protecao das chamadas externas.

O API Gateway passa a representar a borda publica da solucao, centralizando entrada de clientes externos, usuarios internos, autenticacao por CPF e chamadas para a aplicacao principal.

## Decisao

Adotar Amazon API Gateway como entrada publica oficial da arquitetura alvo.

O API Gateway devera rotear:

- autenticacao por CPF para a Lambda Auth CPF;
- autenticacao de usuarios internos para `/api/auth/login` na aplicacao principal;
- chamadas protegidas para a aplicacao principal no EKS;
- chamadas operacionais internas conforme politica de autenticacao e autorizacao;
- chamadas de health ou documentacao apenas quando forem explicitamente publicas.

## Roteamento Por Tipo De Ator

Todas as chamadas externas de API entram pelo API Gateway, incluindo chamadas de clientes, atendentes, mecanicos e gestores. A diferenca esta no mecanismo de autenticacao:

| Ator | Entrada | Autenticacao | Destino |
|---|---|---|---|
| Cliente externo | API Gateway | Lambda Auth CPF | Lambda emite JWT de cliente |
| Atendente | API Gateway | `/api/auth/login` | Aplicacao principal emite JWT interno |
| Mecanico | API Gateway | `/api/auth/login` | Aplicacao principal emite JWT interno |
| Gestor | API Gateway | `/api/auth/login` | Aplicacao principal emite JWT interno |

A Lambda Auth CPF e exclusiva para clientes externos. Usuarios internos continuam autenticando na aplicacao principal, preservando o fluxo atual de JWT e RBAC por perfil.

## Justificativa

- Atende requisito obrigatorio de API Gateway.
- Centraliza exposicao publica e reduz dependencia direta do Load Balancer Kubernetes como borda da solucao.
- Permite aplicar rate limit, throttling, roteamento e politicas por rota.
- Integra naturalmente com Lambda para autenticacao serverless.
- Facilita observabilidade de latencia e erros na borda.
- Permite evoluir a seguranca sem alterar todos os consumidores da API.

## Consequencias Positivas

- Ponto unico de entrada para clientes externos.
- Melhor controle de rotas publicas e protegidas.
- Possibilidade de aplicar quotas e limitacao de taxa.
- Melhor rastreabilidade quando integrado a logs, traces e correlation-id.
- Arquitetura mais alinhada a operacao corporativa.

## Consequencias Negativas

- Aumenta complexidade de infraestrutura.
- Pode adicionar custo por requisicao.
- Exige configuracao cuidadosa de integracao com EKS e Lambda.
- Exige atencao para nao duplicar regras de seguranca de forma inconsistente entre Gateway e aplicacao.

## Alternativas Consideradas

| Alternativa | Motivo da nao escolha |
|---|---|
| Expor apenas Service LoadBalancer | Nao atende explicitamente o requisito de API Gateway |
| Usar Ingress Controller como unica borda | Bom para Kubernetes, mas nao substitui o requisito de API Gateway gerenciado |
| Chamar Lambda diretamente | Nao centraliza roteamento das APIs da aplicacao |

## Relacao Com Outros Documentos

- `RFC-001`: escolha da AWS como cloud alvo.
- `RFC-002`: autenticacao por CPF via Lambda.
- `cloud-target-architecture.puml`: diagrama cloud alvo.
