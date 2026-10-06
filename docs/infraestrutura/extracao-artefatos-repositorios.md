# Extracao De Artefatos Do Repositorio Historico

Este documento registra a distribuicao dos artefatos do repositorio historico `mvp-posfiap-oficina-mecanica` para os repositorios especializados do Tech Challenge 3.

## Commit De Origem

```text
e18b54454a9705396fefad329edc5d8cfbc56165
```

## Estrategia Executada

A extracao preservou o repositorio historico sem remocao fisica de arquivos. Os artefatos foram copiados para branches de trabalho nos repositorios de destino, mantendo Pull Request obrigatorio para entrada na branch principal.

## Matriz Executada

| Origem historica | Destino | Resultado |
|---|---|---|
| `src/**` | `oficina-dgcar-api` | Extraido |
| `pom.xml` | `oficina-dgcar-api` | Extraido |
| `Dockerfile` | `oficina-dgcar-api` | Extraido |
| `docker-compose.yml` | `oficina-dgcar-api` | Extraido |
| `api-requests.http` | `oficina-dgcar-api` | Extraido |
| `postman/**` | `oficina-dgcar-api` | Extraido |
| `k8s/**` | `oficina-dgcar-infra-k8s` | Extraido |
| Terraform EKS/ECR/API Gateway | `oficina-dgcar-infra-k8s` | Separado |
| Terraform RDS PostgreSQL | `oficina-dgcar-infra-db` | Separado |
| Workflow de aplicacao | `oficina-dgcar-api` | Adaptado |
| Workflow de infraestrutura | `oficina-dgcar-infra-k8s` e `oficina-dgcar-infra-db` | Dividido |

## Validacoes Executadas

| Repositorio | Validacao | Resultado |
|---|---|---|
| `oficina-dgcar-api` | `mvn test` | Build aprovado |
| `oficina-dgcar-infra-k8s` | `terraform fmt` e `terraform validate` | Aprovado |
| `oficina-dgcar-infra-db` | `terraform fmt` e `terraform validate` | Aprovado |

## Registro De Escopo

A extracao consolidou a separacao de responsabilidades entre aplicacao, Lambda, infraestrutura Kubernetes e infraestrutura de banco. ADRs, RFCs e diagramas transversais foram centralizados neste repositorio de documentacao.
