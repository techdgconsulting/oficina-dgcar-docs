# Oficina DGCar - Documentacao Arquitetural

Repositorio central de documentacao do Tech Challenge 3 da Oficina Mecanica DGCar.

Este repositorio concentra a visao arquitetural, decisoes tecnicas, diagramas, modelagem de banco, observabilidade e evidencias da solucao. Os repositorios tecnicos permanecem focados em codigo, infraestrutura e deploy.

## Repositorios Do Projeto

| Repositorio | Responsabilidade |
|---|---|
| [oficina-dgcar-api](https://github.com/techdgconsulting/oficina-dgcar-api) | Aplicacao principal Spring Boot executada em Kubernetes |
| [oficina-dgcar-auth-lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda) | Lambda de autenticacao externa por CPF e senha |
| [oficina-dgcar-infra-db](https://github.com/techdgconsulting/oficina-dgcar-infra-db) | Terraform do banco PostgreSQL gerenciado |
| [oficina-dgcar-infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s) | Terraform de EKS, ECR, API Gateway e manifests Kubernetes |
| [mvp-posfiap-oficina-mecanica](https://github.com/techdgconsulting/mvp-posfiap-oficina-mecanica) | Repositorio historico preservado como origem da evolucao |

## Arquitetura Atual

```text
Cliente externo
  -> API Gateway
  -> POST /auth/cpf
  -> Lambda Auth CPF + senha
  -> RDS PostgreSQL
  -> JWT CLIENTE
  -> API Gateway
  -> API Spring Boot no EKS
  -> RDS PostgreSQL
```

Componentes principais:

- AWS API Gateway como entrada oficial.
- AWS Lambda para autenticacao externa de cliente por CPF e senha.
- JWT externo `CLIENTE` separado do JWT interno de funcionarios.
- Aplicacao Spring Boot executada em Amazon EKS.
- Amazon RDS PostgreSQL como banco gerenciado.
- Terraform separado para banco e Kubernetes.
- GitHub Actions com validacao em PR e deploy manual protegido por environment.
- New Relic previsto para metricas, logs, traces, dashboards e alertas.

## Navegacao

| Area | Caminho |
|---|---|
| RFCs | [docs/rfc](docs/rfc) |
| ADRs | [docs/adr](docs/adr) |
| Diagramas de arquitetura | [docs/arquitetura](docs/arquitetura) |
| Banco de dados | [docs/banco](docs/banco) |
| Observabilidade | [docs/observabilidade](docs/observabilidade) |
| Infraestrutura e operacao | [docs/infraestrutura](docs/infraestrutura) |
| Evidencias e roteiro de apresentacao | [docs/evidencias](docs/evidencias) |
| Evolucao por fase | [CHANGELOG.md](CHANGELOG.md) |

## Status Da Implementacao

| Item | Status |
|---|---|
| Separacao em quatro repositorios | Implementado |
| Protecao de branch e Pull Requests | Implementado |
| Terraform DB separado | Implementado |
| Terraform K8s separado | Implementado |
| Lambda Auth CPF + senha | Implementado |
| API Gateway `POST /auth/cpf` | Implementado |
| JWT externo `CLIENTE` | Implementado |
| Validacao do JWT externo na API | Implementado |
| Consulta de OS do cliente por numero | Implementado |
| Observabilidade New Relic | Em organizacao |
| Documentacao de banco e ER | Em organizacao |

## Fonte De Verdade

Este repositorio e a fonte principal para documentacao arquitetural do Tech Challenge 3.

Os READMEs dos repositorios tecnicos documentam apenas o escopo de execucao, deploy, variaveis e operacao especifica de cada componente.

O repositorio `mvp-posfiap-oficina-mecanica` permanece preservado como origem historica da evolucao do projeto.
