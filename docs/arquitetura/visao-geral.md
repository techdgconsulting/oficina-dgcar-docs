# Visão geral da arquitetura

A Oficina DGCar utiliza AWS para executar a API, autenticar clientes e persistir ordens de serviço. A configuração distingue homolog e prod; evidências de execução são identificadas pelo ambiente em que foram obtidas.

## Componentes e responsabilidades

| Componente | Responsabilidade | Repositório |
|---|---|---|
| API Gateway HTTP | Entrada pública e roteamento para autenticação e API | `oficina-dgcar-infra-k8s` |
| Lambda Auth | Validação de CPF e senha e emissão de JWT CLIENTE | `oficina-dgcar-auth-lambda` |
| API Spring Boot no EKS | Regras de negócio, autorização, fluxo de OS e migrations Flyway | `oficina-dgcar-api` |
| RDS PostgreSQL | Persistência gerenciada em subnets privadas | `oficina-dgcar-infra-db` |
| EKS, ECR e rede | Execução dos pods, imagens e conectividade | `oficina-dgcar-infra-k8s` |
| Metrics Server e HPA | Métricas de CPU e ajuste de réplicas da API | Infraestrutura e workflow de deploy da API |
| New Relic | APM da API, telemetria Kubernetes, logs, indicadores, monitor e alertas | Instrumentação na API e provisionamento em infra-k8s |
| CloudWatch Logs | Destino configurado dos logs JSON da Lambda | `oficina-dgcar-auth-lambda` |

## Autenticação e fluxo de atendimento

O API Gateway encaminha `POST /auth/cpf` à Lambda. Ela consulta o cliente no PostgreSQL, valida a senha com bcrypt e emite JWT externo com `tipo=CLIENTE`. A API Spring Boot valida esse JWT e restringe a consulta de OS ao cliente autenticado. Funcionários utilizam login interno e perfis de acesso separados.

As chamadas de negócio seguem pelo proxy do Gateway até o Service da API no EKS. A aplicação executa os casos de uso e persiste os dados no RDS. O status do cliente existe no schema; sua consulta pela Lambda depende da configuração de `CLIENT_STATUS_COLUMN`.

## Infraestrutura e escala

Terraform mantém os recursos de banco e da plataforma Kubernetes em repositórios e estados separados. Os workflows de provisionamento completo são acionados por dispatch e coordenam rede, banco, Lambda, API e integrações. O deploy da API possui gatilhos próprios, descritos em seu README.

O HPA usa CPU fornecida pelo Metrics Server, com mínimo de uma e máximo de três réplicas. O ensaio registrado em homolog comprova uma réplica, duas Ready sob carga e retorno a uma na mesma EC2. O máximo configurado não equivale à capacidade demonstrada. Os detalhes estão na [ADR-015](../adr/ADR-015-hpa-cluster-autoscaling.md) e no [roteiro operacional](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#hpa-e-capacidade).

## Observabilidade

A API e a Lambda produzem logs estruturados em JSON com o campo `correlationId`. O identificador é recebido pelo header `X-Correlation-Id`, preservado nos logs e devolvido na resposta. Quando ausente ou inválido, um novo identificador é gerado. Requisições relacionadas podem compartilhar o mesmo identificador para permitir seu acompanhamento.

## Diagramas e decisões

- [Diagramas de arquitetura](./).
- [ADR-013 — Entrada pelo API Gateway](../adr/ADR-013-api-gateway-entrada-oficial.md).
- [ADR-016 — Logs estruturados e correlação](../adr/ADR-016-logs-estruturados-correlation-id.md).
- [ADR-019 — Infraestrutura AWS](../adr/ADR-019-infraestrutura-aws-terraform-kubernetes.md).
- [Plataforma de observabilidade](../observabilidade/new-relic.md).
- [Dashboards, healthchecks e alertas](../observabilidade/dashboards-alertas.md).

Esta visão descreve os componentes e suas relações. As ADRs registram justificativas e consequências; as RFCs preservam propostas e discussões; os roteiros operacionais descrevem execução e verificação.
