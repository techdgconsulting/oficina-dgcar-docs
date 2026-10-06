# Fechamento Da Etapa 1 - Arquitetura Alvo

## Objetivo

Este documento registra o fechamento da consolidação da arquitetura alvo do Tech Challenge 3 para a Oficina Mecânica DGCar.

## Escopo Revisado

Foram revisados os documentos arquiteturais relacionados a:

- API Gateway como entrada oficial.
- Lambda Auth CPF.
- JWT externo de cliente separado do JWT interno de usuários da oficina.
- PostgreSQL gerenciado em Amazon RDS.
- Kubernetes/EKS com HPA.
- Observabilidade com New Relic.
- Logs estruturados e correlation-id.
- Separação em quatro repositórios.
- Plano inicial de modelagem relacional.

## Decisões Confirmadas

| Decisão | Resultado |
|---|---|
| Nomes dos repositórios | `oficina-dgcar-auth-lambda`, `oficina-dgcar-infra-k8s`, `oficina-dgcar-infra-db`, `oficina-dgcar-api`. |
| Entrada oficial | Amazon API Gateway. |
| Autenticação externa | AWS Lambda Auth CPF. |
| Runtime da Lambda | Node.js 20.x. |
| JWT externo de cliente | Separado do JWT interno de funcionários. |
| Validação do JWT externo | API Gateway e aplicação Spring Boot. |
| Banco gerenciado | Amazon RDS PostgreSQL. |
| Infraestrutura | Terraform separado entre banco e Kubernetes. |
| Observabilidade | New Relic, logs JSON, correlation-id, dashboards e alertas. |

## Documentos Criados Ou Atualizados

- [`auth-cpf-sequence.puml`](../diagramas/infra/auth-cpf-sequence.puml)
- [`plano-modelagem-banco-tc3.md`](../modelagem/plano-modelagem-banco-tc3.md)
- [`ADR-018-validacao-jwt-cliente-externo.md`](../ADRS/ADR-018-validacao-jwt-cliente-externo.md)
- [`RFC-002-autenticacao-cpf-lambda.md`](../RFCS/RFC-002-autenticacao-cpf-lambda.md)
- [`RFC-003-separacao-repositorios-github.md`](../RFCS/RFC-003-separacao-repositorios-github.md)
- [`RFC-005-separacao-terraform-k8s-banco.md`](../RFCS/RFC-005-separacao-terraform-k8s-banco.md)
- [`ADR-014-lambda-autenticacao-cliente-cpf.md`](../ADRS/ADR-014-lambda-autenticacao-cliente-cpf.md)
- [`README.md`](../../README.md)

## Pendências Aceitas Para Etapas Futuras

- Criar fisicamente os quatro repositórios Git.
- Extrair os artefatos do repositório histórico.
- Implementar a Lambda Auth CPF.
- Implementar API Gateway e authorizer/validação de borda.
- Adaptar Spring Security para JWT externo de cliente.
- Implementar logs JSON, correlation-id e métricas customizadas.
- Integrar New Relic.
- Produzir diagrama ER e dicionário de dados definitivos.
- Avaliar e implementar `status_cliente`, se aprovado.

## Critérios Para Avançar À Etapa 2

A Etapa 2 pode iniciar quando:

- os nomes dos quatro repositórios forem aceitos;
- o runtime da Lambda estiver confirmado;
- a estratégia de validação do JWT externo estiver aceita;
- o plano de separação de repositórios estiver aprovado;
- a criação dos repositórios remotos for autorizada.

## Confirmação De Escopo

Nesta etapa não houve criação de repositórios remotos, movimentação física de arquivos entre repositórios, alteração de código Java, alteração de Terraform, alteração de manifests Kubernetes ou alteração de pipelines.
