# Etapa 3 - Extração De Artefatos Do Repositório Histórico

## Objetivo

Registrar a extração inicial dos artefatos do repositório histórico `mvp-posfiap-oficina-mecanica` para os quatro repositórios especializados do Tech Challenge 3.

## Commit De Origem

`e18b54454a9705396fefad329edc5d8cfbc56165`

## Estratégia

A extração foi realizada em branches de trabalho chamadas `feature/extracao-inicial`, preservando a regra de Pull Request obrigatório configurada na branch `main` dos repositórios de destino.

O repositório histórico não teve arquivos removidos ou movidos fisicamente. Ele permanece como origem histórica e fonte canônica da transição.

## Matriz Executada

| Origem histórica | Destino | Situação |
|---|---|---|
| `src/**` | `oficina-dgcar-api` | Extraído |
| `pom.xml` | `oficina-dgcar-api` | Extraído |
| `Dockerfile` | `oficina-dgcar-api` | Extraído |
| `docker-compose.yml` | `oficina-dgcar-api` | Extraído |
| `api-requests.http` | `oficina-dgcar-api` | Extraído |
| `postman/**` | `oficina-dgcar-api` | Extraído |
| `allure-report.ps1` | `oficina-dgcar-api` | Extraído |
| `docs/ReportOWASP/**` | `oficina-dgcar-api` | Extraído |
| `docs/ReportTRIVY/**` | `oficina-dgcar-api` | Extraído |
| `.github/workflows/app-cd.yml` | `oficina-dgcar-api` | Adaptado para build/test/package |
| `k8s/**` | `oficina-dgcar-infra-k8s` | Extraído |
| Terraform VPC/EKS/ECR/IAM | `oficina-dgcar-infra-k8s` | Separado em `terraform/**` |
| Terraform RDS PostgreSQL | `oficina-dgcar-infra-db` | Separado em `terraform/**` |
| `.github/workflows/infra.yml` | `oficina-dgcar-infra-k8s` e `oficina-dgcar-infra-db` | Dividido em workflows Terraform específicos |
| ADRs/RFCs/diagramas transversais | Repositório histórico | Mantidos como fonte canônica |

## Validações Executadas

| Repositório | Validação | Resultado |
|---|---|---|
| `oficina-dgcar-api` | `mvn test` | 363 testes, 0 falhas, build success |
| `oficina-dgcar-infra-k8s` | `terraform fmt -check -recursive` | Sucesso |
| `oficina-dgcar-infra-k8s` | `terraform init -backend=false && terraform validate` | Sucesso |
| `oficina-dgcar-infra-db` | `terraform fmt -check -recursive` | Sucesso |
| `oficina-dgcar-infra-db` | `terraform init -backend=false && terraform validate` | Sucesso |

## Observações Técnicas

- O Terraform histórico era monolítico; a extração inicial separou os recursos em dois estados lógicos.
- `oficina-dgcar-infra-k8s` publica outputs como `vpc_id`, `private_subnet_ids` e `eks_cluster_security_group_id`.
- `oficina-dgcar-infra-db` consome esses valores para criar o RDS com conectividade controlada.
- A implementação da Lambda Auth CPF permanece para a etapa seguinte.

## Próximos Passos

- Revisar Pull Requests das branches `feature/extracao-inicial`:
  - `oficina-dgcar-api`: https://github.com/techdgconsulting/oficina-dgcar-api/pull/1
  - `oficina-dgcar-infra-k8s`: https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/pull/1
  - `oficina-dgcar-infra-db`: https://github.com/techdgconsulting/oficina-dgcar-infra-db/pull/1
  - `oficina-dgcar-auth-lambda`: https://github.com/techdgconsulting/oficina-dgcar-auth-lambda/pull/1
- Revisar e aprovar a extração inicial.
- Configurar secrets/variables necessários para pipelines reais.
- Prosseguir para a implementação da Lambda Auth CPF.
