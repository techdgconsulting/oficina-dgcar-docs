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
| Evolucao do projeto | [CHANGELOG.md](CHANGELOG.md) |

## Entregas Consolidadas

A solucao foi reorganizada em quatro repositorios tecnicos, cada um com responsabilidade clara, Pull Requests obrigatorios, branch principal protegida e environments separados para homologacao e producao.

A infraestrutura foi separada em dois fluxos Terraform independentes: um para o banco PostgreSQL gerenciado e outro para Kubernetes, ECR e API Gateway. A Lambda de autenticacao externa foi implementada em repositorio proprio, com provisionamento AWS tambem descrito por Terraform.

O fluxo de autenticacao externa foi entregue com CPF e senha, consulta ao PostgreSQL, validacao de hash bcrypt e emissao de JWT `CLIENTE`. A aplicacao Spring Boot valida esse JWT externo por defesa em profundidade e restringe a consulta de OS ao CPF presente no token.

O API Gateway foi configurado como entrada oficial, com a rota `POST /auth/cpf` integrada a Lambda e a rota proxy encaminhando chamadas para a aplicacao no EKS. A consulta demonstravel do cliente usa o numero legivel da OS, sem expor `clienteId` como entrada externa.

A documentacao arquitetural foi centralizada neste repositorio para reunir decisoes, diagramas, banco de dados, observabilidade e evidencias da apresentacao.

## Fonte De Verdade

Este repositorio e a fonte principal para documentacao arquitetural do Tech Challenge 3.

Os READMEs dos repositorios tecnicos documentam apenas o escopo de execucao, deploy, variaveis e operacao especifica de cada componente.

O repositorio `mvp-posfiap-oficina-mecanica` permanece preservado como origem historica da evolucao do projeto.
