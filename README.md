# Oficina DGCar - Documentacao Arquitetural

Repositorio central de documentacao do Tech Challenge 3 da Oficina Mecanica DGCar.

Este repositorio concentra a visao arquitetural, decisoes tecnicas, diagramas, modelagem de banco e observabilidade da solucao. Os repositorios tecnicos permanecem focados em codigo, infraestrutura e deploy.

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
  -> Lambda Auth CPF + Senha
  -> RDS PostgreSQL
  -> JWT CLIENTE
  -> API Gateway
  -> API Spring Boot no EKS
  -> RDS PostgreSQL
```

Componentes principais:

- AWS API Gateway como entrada oficial.
- AWS Lambda para autenticacao externa de cliente por CPF e senha.
- Todo trafego externo de API entra pelo API Gateway. A rota `POST /auth/cpf` segue para a Lambda Auth CPF + Senha; as demais rotas `/api/**` seguem para a API Spring Boot no EKS, onde JWT interno e JWT `CLIENTE` sao validados conforme o ator.
- JWT externo `CLIENTE` separado do JWT interno de funcionarios.
- Aplicacao Spring Boot executada em Amazon EKS.
- Amazon RDS PostgreSQL como banco gerenciado.
- Terraform separado para banco e Kubernetes.
- GitHub Actions com validacao em PR e deploy automatico por branch protegida.
- New Relic definido para metricas, logs, traces, dashboards e alertas.

## Navegacao Centralizada

Este README e o indice unico do repositorio de documentacao. As pastas internas organizam os artefatos, mas nao possuem READMEs proprios.

### Arquitetura

Diagramas e visoes arquiteturais do Tech Challenge 3, incluindo C4 atualizado, arquitetura alvo em nuvem, componentes AWS, autenticacao por CPF e senha, abertura de ordem de servico, deploy, JWT/RBAC e maquina de estados da OS.

Arquivos principais:

- [cloud-target-architecture.puml](docs/arquitetura/cloud-target-architecture.puml) - visao alvo da solucao em nuvem, com atores, repositorios, CI/CD, fluxos e observabilidade.
- [aws-infra-components.puml](docs/arquitetura/aws-infra-components.puml) - componentes AWS provisionados por Terraform e pipelines.
- [1-diagram-context.puml](docs/arquitetura/1-diagram-context.puml) - contexto C4 com API Gateway, Lambda, RDS e observabilidade.
- [2-diagram-container.puml](docs/arquitetura/2-diagram-container.puml) - containers C4 com API Gateway, Lambda, API Spring Boot e RDS.
- [3-diagram-components.puml](docs/arquitetura/3-diagram-components.puml) - componentes da API Spring Boot e integracoes externas.
- [auth-cpf-sequence.puml](docs/arquitetura/auth-cpf-sequence.puml) - autenticacao CPF + senha.
- [sequencia-abertura-os.puml](docs/arquitetura/sequencia-abertura-os.puml) - abertura de ordem de servico.
- [sequencia-consulta-os-cliente.puml](docs/arquitetura/sequencia-consulta-os-cliente.puml) - consulta de OS pelo cliente.
- [infra-provisioning-flow.puml](docs/arquitetura/infra-provisioning-flow.puml) - provisionamento e teardown de infraestrutura em homolog e producao.
- [deploy-pipeline-flow.puml](docs/arquitetura/deploy-pipeline-flow.puml) - esteira de deploy com validacoes, aprovacoes, homolog e producao.
- [jwt-rbac-flow.puml](docs/arquitetura/jwt-rbac-flow.puml) - escopo interno de JWT/RBAC da API Spring Boot.
- [state-machine-diagram-service-order.puml](docs/arquitetura/state-machine-diagram-service-order.puml) - maquina de estados da ordem de servico.
- [tactical-ddd.puml](docs/arquitetura/tactical-ddd.puml) - visao tatica DDD interna da aplicacao.

### RFCs

Request for Comments usados para registrar decisoes tecnicas relevantes antes da consolidacao arquitetural.

Arquivos:

- [RFC-001-aws-cloud.md](docs/rfc/RFC-001-aws-cloud.md) - escolha da AWS como cloud alvo.
- [RFC-002-autenticacao-cpf-lambda.md](docs/rfc/RFC-002-autenticacao-cpf-lambda.md) - autenticacao externa por CPF e senha com Lambda.
- [RFC-003-separacao-repositorios-github.md](docs/rfc/RFC-003-separacao-repositorios-github.md) - separacao em repositorios especializados.
- [RFC-004-observabilidade-new-relic.md](docs/rfc/RFC-004-observabilidade-new-relic.md) - observabilidade com New Relic.
- [RFC-005-separacao-terraform-k8s-banco.md](docs/rfc/RFC-005-separacao-terraform-k8s-banco.md) - separacao dos estados Terraform.
- [RFC-006-postgresql-gerenciado.md](docs/rfc/RFC-006-postgresql-gerenciado.md) - escolha do PostgreSQL gerenciado como banco de dados.

### ADRs

Architecture Decision Records do projeto Oficina DGCar. As ADRs registram decisoes arquiteturais permanentes, com contexto, decisao e consequencias.

Principais decisoes cobertas:

- API Gateway como entrada oficial.
- Lambda para autenticacao externa por CPF e senha.
- JWT externo `CLIENTE` separado do JWT interno.
- HPA para escalabilidade da aplicacao.
- Logs estruturados e correlation-id.
- PostgreSQL gerenciado.
- Validacao de JWT externo tambem na API Spring Boot.
- Infraestrutura AWS com Terraform e Kubernetes.

Diretorio: [docs/adr](docs/adr)

### Banco De Dados

Documentacao da modelagem e da escolha do banco de dados da Oficina DGCar.

Documentos principais:

- [justificativa-postgresql.md](docs/banco/justificativa-postgresql.md) - justificativa formal do PostgreSQL.
- [modelo-relacional.md](docs/banco/modelo-relacional.md) - modelo relacional e cardinalidades.
- [dicionario-dados.md](docs/banco/dicionario-dados.md) - dicionario de dados.
- [indices-performance.md](docs/banco/indices-performance.md) - indices de performance.
- [plano-cluster-postgresql-gerenciado.md](docs/banco/plano-cluster-postgresql-gerenciado.md) - plano do cluster gerenciado.
- [diagrama-er.puml](docs/banco/diagrama-er.puml) - diagrama ER.
- [RFC-006-postgresql-gerenciado.md](docs/rfc/RFC-006-postgresql-gerenciado.md) - decisao tecnica relacionada.

### Observabilidade

Documentacao da estrategia de observabilidade da Oficina DGCar. A ferramenta escolhida e New Relic.

Documentos:

- [new-relic.md](docs/observabilidade/new-relic.md)
- [logs-json-correlation-id.md](docs/observabilidade/logs-json-correlation-id.md)
- [dashboards-alertas.md](docs/observabilidade/dashboards-alertas.md)
- [metricas-negocio.md](docs/observabilidade/metricas-negocio.md)

### Operacao

A documentacao operacional detalhada do ambiente AWS fica no repositorio [`oficina-dgcar-infra-k8s`](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s), responsavel por provisionamento, deploy coordenado e teardown.

Documento principal:

- [`docs/OPERACAO-AMBIENTE.md`](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/main/docs/OPERACAO-AMBIENTE.md) - provisionamento, validacao funcional e teardown dos ambientes `homolog` e `prod`.

### Evolucao Do Projeto

- [CHANGELOG.md](CHANGELOG.md)
- [PROMPT-TECH-CHALLENGE-3.md](PROMPT-TECH-CHALLENGE-3.md) - prompt atualizado de execucao, checklist e plano de voo.

## Entregas Consolidadas

A solucao foi reorganizada em quatro repositorios tecnicos, cada um com responsabilidade clara, Pull Requests obrigatorios, branches protegidas e environments separados para homologacao e producao.

O fluxo oficial de promocao e `feature/* -> PR -> homolog -> deploy automatico homolog -> PR -> main -> deploy automatico producao`. As branches `homolog` e `main` nao recebem commits diretos.

A infraestrutura foi separada em dois fluxos Terraform independentes: um para o banco PostgreSQL gerenciado e outro para Kubernetes, ECR e API Gateway. A Lambda de autenticacao externa foi implementada em repositorio proprio, com provisionamento AWS tambem descrito por Terraform.

O fluxo de autenticacao externa foi entregue com CPF e senha, consulta ao PostgreSQL, validacao de hash bcrypt e emissao de JWT `CLIENTE`. A aplicacao Spring Boot valida esse JWT externo por defesa em profundidade e restringe a consulta de OS ao CPF presente no token.

O API Gateway foi configurado como entrada oficial, com a rota `POST /auth/cpf` integrada a Lambda e a rota proxy encaminhando chamadas para a aplicacao no EKS. A consulta demonstravel do cliente usa o numero legivel da OS, sem expor `clienteId` como entrada externa.

A documentacao arquitetural foi centralizada neste repositorio para reunir decisoes, diagramas, banco de dados e observabilidade.

## Operacao Do Ambiente AWS

O ambiente academico e operado pelo repositorio `oficina-dgcar-infra-k8s`, que centraliza o provisionamento e o teardown de homologacao e producao. A aprovacao humana continua protegida pelos GitHub Environments, e a sequencia entre infraestrutura, banco, Lambda e aplicacao foi automatizada a partir da esteira de infraestrutura.

O workflow central usa `GH_AUTOMATION_TOKEN` para acionar as execucoes dependentes nos demais repositorios. As credenciais AWS permanecem nos environments dos repositorios tecnicos que executam Terraform, Lambda e deploy da aplicacao.

### Provisionamento Completo

Execucao automatica:

```text
feature/* -> PR -> homolog -> provisionamento/deploy homolog
homolog -> PR -> main -> provisionamento/deploy prod
```

Os workflows tambem mantem `workflow_dispatch` para reprocessamento operacional controlado.

O workflow provisiona rede, EKS, ECR, API Gateway, RDS PostgreSQL, Lambda Auth CPF + Senha, aplicacao no EKS, rota `POST /auth/cpf` e rota proxy `ANY /{proxy+}`. A validacao funcional com CPF, senha e numero de OS roda somente quando `run_smoke_tests=true`.

### Validacao Funcional

Depois do provisionamento, a validacao demonstravel usa:

1. health da aplicacao no EKS;
2. `POST /auth/cpf` com CPF e senha validos;
3. JWT `CLIENTE` retornado pela Lambda;
4. consulta protegida da OS por numero usando `Authorization: Bearer <accessToken>`;
5. chamadas negativas sem token, com token invalido e com OS de outro cliente.

### Teardown Completo

Executar no repositorio `oficina-dgcar-infra-k8s`:

```text
Actions -> Destruir Ambiente Homolog
environment=homolog
confirm=DESTROY
```

O workflow remove workloads Kubernetes, Load Balancers, RDS PostgreSQL, Lambda Auth CPF + Senha, API Gateway, EKS, VPC e dependencias residuais conhecidas. O teardown valida que VPC, EKS, RDS, Lambda e API Gateway nao permanecem na AWS.

O procedimento operacional completo fica documentado no repositorio `oficina-dgcar-infra-k8s`, em [`docs/OPERACAO-AMBIENTE.md`](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/main/docs/OPERACAO-AMBIENTE.md).

## Fonte De Verdade

Este repositorio e a fonte principal para documentacao arquitetural do Tech Challenge 3.

Os READMEs dos repositorios tecnicos documentam apenas o escopo de execucao, deploy, variaveis e operacao especifica de cada componente.

O repositorio `mvp-posfiap-oficina-mecanica` permanece preservado como origem historica da evolucao do projeto.
