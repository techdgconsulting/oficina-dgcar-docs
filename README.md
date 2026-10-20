# Oficina DGCar — Guia do projeto

A Oficina DGCar é um sistema de gestão de oficina mecânica, com cadastro de clientes e veículos e acompanhamento de ordens de serviço, desde o diagnóstico e orçamento até o pagamento e a entrega.

Este repositório reúne a documentação do projeto. Use este README para localizar os diretórios, entender o conteúdo de cada área e acessar os documentos e repositórios responsáveis por cada componente.

## Repositórios do projeto

| Repositório | O que encontrar |
|---|---|
| [oficina-dgcar-docs](https://github.com/techdgconsulting/oficina-dgcar-docs) | Documentação central: arquitetura, decisões técnicas, diagramas, banco de dados, observabilidade e operação. |
| [oficina-dgcar-api](https://github.com/techdgconsulting/oficina-dgcar-api) | API Spring Boot, regras de negócio, testes, migrations, contrato OpenAPI e collection Postman. O README apresenta a execução local e as configurações da aplicação. |
| [oficina-dgcar-auth-lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda) | Autenticação de clientes por CPF e senha, emissão de JWT e infraestrutura da Lambda. O README reúne as instruções do componente. |
| [oficina-dgcar-infra-db](https://github.com/techdgconsulting/oficina-dgcar-infra-db) | Infraestrutura do banco PostgreSQL no Amazon RDS, conectividade e procedimentos de operação do banco. |
| [oficina-dgcar-infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s) | Infraestrutura AWS e Kubernetes, incluindo rede, EKS, ECR, API Gateway e observabilidade. O README orienta o provisionamento e a operação dos ambientes. |
| [mvp-posfiap-oficina-mecanica](https://github.com/techdgconsulting/mvp-posfiap-oficina-mecanica) | Versão de origem do projeto e documentação histórica anterior à separação dos componentes. |

## Diretórios da documentação

| Diretório | Conteúdo |
|---|---|
| [docs/arquitetura](docs/arquitetura/) | Visão geral da solução e diagramas de contexto, containers, componentes, autenticação, deploy e estados da ordem de serviço. Os diagramas são mantidos em arquivos PlantUML (`.puml`). |
| [docs/adr](docs/adr/) | Registros de decisões arquiteturais (ADRs), com o contexto e as justificativas das escolhas técnicas. |
| [docs/rfc](docs/rfc/) | Propostas técnicas (RFCs) sobre nuvem AWS, autenticação, separação dos repositórios, observabilidade e infraestrutura. |
| [docs/banco](docs/banco/) | Modelo relacional, diagrama entidade-relacionamento, dicionário de dados, índices e documentação do banco gerenciado. |
| [docs/observabilidade](docs/observabilidade/) | Documentação do New Relic, logs estruturados, correlação de requisições, métricas de negócio, dashboards e alertas. |
| [docs/operacao](docs/operacao/) | Índice de links para os guias técnicos de operação, validação e deploy dos componentes. |
| [docs/testes](docs/testes/README.md) | Resultados executados, cenários, quantidades, cobertura JaCoCo/Jest e acesso aos relatórios da CI. |

O [CHANGELOG.md](CHANGELOG.md) registra a evolução da documentação.

## Catálogo de diretórios e arquivos

O diretório [docs/](docs/) concentra os documentos abaixo. Cada tabela oferece acesso direto aos arquivos da área; os arquivos `.puml` contêm as fontes dos diagramas PlantUML.

### Arquitetura e diagramas

Diretório: [docs/arquitetura/](docs/arquitetura/).

| Arquivo | O que encontrar |
|---|---|
| [1-diagram-context.puml](docs/arquitetura/1-diagram-context.puml) | C4 — contexto do sistema e integrações externas |
| [2-diagram-container.puml](docs/arquitetura/2-diagram-container.puml) | C4 — containers e principais blocos da solução |
| [3-diagram-components.puml](docs/arquitetura/3-diagram-components.puml) | C4 — componentes internos da API |
| [auth-cpf-sequence.puml](docs/arquitetura/auth-cpf-sequence.puml) | Sequência detalhada da autenticação externa por CPF e senha |
| [aws-infra-components.puml](docs/arquitetura/aws-infra-components.puml) | Componentes da infraestrutura AWS |
| [cloud-target-architecture.puml](docs/arquitetura/cloud-target-architecture.puml) | Visão da arquitetura alvo em nuvem |
| [jwt-rbac-flow.puml](docs/arquitetura/jwt-rbac-flow.puml) | Fluxo de autenticação JWT e autorização por perfil |
| [sequencia-consulta-os-cliente.puml](docs/arquitetura/sequencia-consulta-os-cliente.puml) | Sequência de consulta de OS com JWT de cliente |
| [state-machine-diagram-service-order.puml](docs/arquitetura/state-machine-diagram-service-order.puml) | Máquina de estados da ordem de serviço |
| [tactical-ddd.puml](docs/arquitetura/tactical-ddd.puml) | Visão tática DDD e contextos internos |
| [visao-geral.md](docs/arquitetura/visao-geral.md) | Visão geral da arquitetura |
| [deploy-pipeline-flow.puml](docs/arquitetura/deploy-pipeline-flow.puml) | Esteira De Deploy - Validacoes, Aprovacoes E Promocao |
| [infra-provisioning-flow.puml](docs/arquitetura/infra-provisioning-flow.puml) | Provisionamento E Teardown Da Infraestrutura - Homolog E Producao |
| [sequencia-abertura-os.puml](docs/arquitetura/sequencia-abertura-os.puml) | Sequencia De Abertura De Ordem De Servico |

### Decisões arquiteturais — ADRs

Diretório: [docs/adr/](docs/adr/).

| Arquivo | O que encontrar |
|---|---|
| [ADR-001-adocao-ddd.md](docs/adr/ADR-001-adocao-ddd.md) | ADR-001: Adoção de Domain-Driven Design (DDD) |
| [ADR-002-arquitetura-clean-arch.md](docs/adr/ADR-002-arquitetura-clean-arch.md) | ADR-002: Arquitetura Clean Architecture com Ports e Adapters |
| [ADR-003-postgresql.md](docs/adr/ADR-003-postgresql.md) | ADR-003: PostgreSQL como Banco de Dados |
| [ADR-004-jwt-stateless.md](docs/adr/ADR-004-jwt-stateless.md) | ADR-004: Autenticação JWT Stateless |
| [ADR-005-flyway-migrations.md](docs/adr/ADR-005-flyway-migrations.md) | ADR-005: Flyway para Gerenciamento de Migrations |
| [ADR-006-docker-containerizacao.md](docs/adr/ADR-006-docker-containerizacao.md) | ADR-006: Containerização com Docker e Docker Compose |
| [ADR-007-gateway-pagamento.md](docs/adr/ADR-007-gateway-pagamento.md) | ADR-007: Gateway de Pagamento via Port/Adapter (Mock) |
| [ADR-008-stack-tecnologico.md](docs/adr/ADR-008-stack-tecnologico.md) | ADR-008: Stack Tecnológico do Projeto |
| [ADR-009-estrategia-testes.md](docs/adr/ADR-009-estrategia-testes.md) | ADR-009: Estratégia de Testes — Frameworks e Ferramentas |
| [ADR-010-decisao-externa-orcamento-token.md](docs/adr/ADR-010-decisao-externa-orcamento-token.md) | ADR-010: Decisão Externa de Orçamento por Token |
| [ADR-011-notificacao-status-os-email.md](docs/adr/ADR-011-notificacao-status-os-email.md) | ADR-011: Notificação Informativa de Status da OS por E-mail |
| [ADR-012-varreduras-seguranca-owasp-zap-trivy.md](docs/adr/ADR-012-varreduras-seguranca-owasp-zap-trivy.md) | ADR-012: Varreduras de Segurança com OWASP ZAP e Trivy |
| [ADR-013-api-gateway-entrada-oficial.md](docs/adr/ADR-013-api-gateway-entrada-oficial.md) | ADR-013: API Gateway Como Entrada Oficial |
| [ADR-014-lambda-autenticacao-cliente-cpf.md](docs/adr/ADR-014-lambda-autenticacao-cliente-cpf.md) | ADR-014: Lambda Para Autenticacao Externa De Cliente Com CPF E Senha |
| [ADR-015-hpa-cluster-autoscaling.md](docs/adr/ADR-015-hpa-cluster-autoscaling.md) | ADR-015: HPA e estratégia de escalabilidade do cluster |
| [ADR-016-logs-estruturados-correlation-id.md](docs/adr/ADR-016-logs-estruturados-correlation-id.md) | ADR-016: Logs estruturados e correlation ID |
| [ADR-017-postgresql-gerenciado.md](docs/adr/ADR-017-postgresql-gerenciado.md) | ADR-017: PostgreSQL Gerenciado Como Banco Corporativo |
| [ADR-018-validacao-jwt-cliente-externo.md](docs/adr/ADR-018-validacao-jwt-cliente-externo.md) | ADR-018: Validacao Do JWT Externo De Cliente |
| [ADR-019-infraestrutura-aws-terraform-kubernetes.md](docs/adr/ADR-019-infraestrutura-aws-terraform-kubernetes.md) | ADR-019: Infraestrutura AWS com Terraform e Kubernetes |
| [ADR-020-promocao-e-deploy-automatico.md](docs/adr/ADR-020-promocao-e-deploy-automatico.md) | Promoção por PR, deploy automático, fila por ambiente e preservação do destroy manual |

### Propostas técnicas — RFCs

Diretório: [docs/rfc/](docs/rfc/).

| Arquivo | O que encontrar |
|---|---|
| [RFC-001-aws-cloud.md](docs/rfc/RFC-001-aws-cloud.md) | RFC-001: Escolha Da AWS Como Cloud Alvo |
| [RFC-002-autenticacao-cpf-lambda.md](docs/rfc/RFC-002-autenticacao-cpf-lambda.md) | RFC-002: Autenticacao Externa Com CPF E Senha Na Lambda |
| [RFC-003-separacao-repositorios-github.md](docs/rfc/RFC-003-separacao-repositorios-github.md) | RFC-003: Separacao Em Quatro Repositorios |
| [RFC-004-observabilidade-new-relic.md](docs/rfc/RFC-004-observabilidade-new-relic.md) | RFC-004: Observabilidade com New Relic |
| [RFC-005-separacao-terraform-k8s-banco.md](docs/rfc/RFC-005-separacao-terraform-k8s-banco.md) | RFC-005: Separacao Do Terraform De Kubernetes E Banco |
| [RFC-006-postgresql-gerenciado.md](docs/rfc/RFC-006-postgresql-gerenciado.md) | PostgreSQL gerenciado e critérios de adoção |

### Banco de dados

Diretório: [docs/banco/](docs/banco/).

| Arquivo | O que encontrar |
|---|---|
| [README.md](docs/banco/README.md) | Apresentação e índice da área |
| [diagrama-er.puml](docs/banco/diagrama-er.puml) | Diagrama entidade-relacionamento do banco |
| [dicionario-dados.md](docs/banco/dicionario-dados.md) | Dicionario De Dados |
| [indices-performance.md](docs/banco/indices-performance.md) | Indices E Performance |
| [modelo-relacional.md](docs/banco/modelo-relacional.md) | Modelo Relacional |
| [plano-cluster-postgresql-gerenciado.md](docs/banco/plano-cluster-postgresql-gerenciado.md) | Plano Do PostgreSQL Gerenciado |

### Observabilidade e correlação

Diretório: [docs/observabilidade/](docs/observabilidade/).

| Arquivo | O que encontrar |
|---|---|
| [dashboards-alertas.md](docs/observabilidade/dashboards-alertas.md) | Dashboards, healthchecks e alertas |
| [logs-json-correlation-id.md](docs/observabilidade/logs-json-correlation-id.md) | Logs JSON e correlação |
| [metricas-negocio.md](docs/observabilidade/metricas-negocio.md) | Métricas de negócio |
| [new-relic.md](docs/observabilidade/new-relic.md) | New Relic |

### Operação dos ambientes

Diretório: [docs/operacao/](docs/operacao/).

| Arquivo | O que encontrar |
|---|---|
| [README.md](docs/operacao/README.md) | Apresentação e índice da área |

### Testes e relatórios

Diretório: [docs/testes/](docs/testes/).

| Arquivo | O que encontrar |
|---|---|
| [README.md](docs/testes/README.md) | Resultados por componente, cobertura JaCoCo e Jest, evidências da CI e acesso aos relatórios. |
| [cenarios-api.md](docs/testes/cenarios-api.md) | Inventário dos 402 casos executados na API, organizado pelas 56 suítes Surefire. |

### Arquivos da raiz

| Arquivo | O que encontrar |
|---|---|
| [README.md](README.md) | Guia de navegação do projeto e catálogo da documentação. |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de evolução da documentação. |
| [.gitignore](.gitignore) | Regras de exclusão de arquivos locais, evidências e artefatos de infraestrutura do versionamento. |

## Guias dos componentes

As justificativas da escolha do PostgreSQL estão na [ADR-003](docs/adr/ADR-003-postgresql.md); a adoção do serviço gerenciado Amazon RDS está na [ADR-017](docs/adr/ADR-017-postgresql-gerenciado.md).

| O que procurar | Onde encontrar |
|---|---|
| Cenários executados, quantidades e cobertura | [Testes e resultados](docs/testes/README.md) e [inventário de cenários da API](docs/testes/cenarios-api.md) |
| Execução local, configuração, testes e acesso ao Swagger/OpenAPI | [README da API](https://github.com/techdgconsulting/oficina-dgcar-api#readme) |
| Collection e exemplos de requisições | [Diretório postman/ da API](https://github.com/techdgconsulting/oficina-dgcar-api/tree/homolog/postman) |
| Collection Postman do Tech Challenge — Fase 3 | [Arquivo JSON para importar no Postman](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/postman/Oficina-DGCar-Tech-Challenge-Fase-3.postman_collection.json) |
| Relatórios de segurança Trivy | [Diretório ReportTRIVY/](https://github.com/techdgconsulting/oficina-dgcar-api/tree/homolog/docs/ReportTRIVY) e [relatório da imagem em JSON](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/docs/ReportTRIVY/trivy-image-report.json) |
| Versões das bibliotecas e correções verificadas com Trivy | [Stack e versões atuais — ADR-008](docs/adr/ADR-008-stack-tecnologico.md) e [atualizações e evidências de segurança — ADR-012](docs/adr/ADR-012-varreduras-seguranca-owasp-zap-trivy.md) |
| Relatórios de segurança OWASP ZAP | [Diretório ReportOWASP/](https://github.com/techdgconsulting/oficina-dgcar-api/tree/homolog/docs/ReportOWASP) e [relatório em HTML](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/docs/ReportOWASP/2026-10-19-ZAP-Report-.html) |
| Configuração, testes e deploy da autenticação externa | [README da Lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda#readme) |
| Provisionamento e operação do PostgreSQL | [README de infra-db](https://github.com/techdgconsulting/oficina-dgcar-infra-db#readme) |
| Provisionamento AWS, Kubernetes e operação dos ambientes | [README de infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s#readme) |

Para começar a leitura, consulte a [visão geral da arquitetura](docs/arquitetura/visao-geral.md) e siga os links da área que deseja conhecer.
