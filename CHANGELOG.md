# Changelog

Historico resumido da evolucao do projeto Oficina Mecanica DGCar.

## Base Historica

- Implementacao inicial da API de oficina mecanica em Spring Boot.
- Cadastro de clientes, veiculos, servicos, pecas e ordens de servico.
- Autenticacao interna com JWT e perfis `ATENDENTE`, `MECANICO` e `GESTOR`.
- Uso de PostgreSQL, Flyway, Docker, Docker Compose e documentacao OpenAPI.
- Registro de ADRs, RFCs, diagramas e relatorios de seguranca no repositorio historico.

## Evolucao Para Operacao Em Nuvem

- Containerizacao da aplicacao.
- Criacao de manifests Kubernetes.
- Provisionamento inicial de infraestrutura AWS com Terraform.
- Uso de Amazon EKS, ECR, RDS PostgreSQL e S3 para state remoto.
- Pipelines GitHub Actions para validacao, build e deploy.

## Separacao Dos Repositorios

- Criacao dos quatro repositorios exigidos pelo Tech Challenge 3:
  - `oficina-dgcar-api`;
  - `oficina-dgcar-auth-lambda`;
  - `oficina-dgcar-infra-db`;
  - `oficina-dgcar-infra-k8s`.
- Preservacao do repositorio historico como origem da evolucao.
- Configuracao de branch protegida, PR obrigatorio, checks e environments `homolog` e `prod`.

## Infraestrutura De Banco

- Separacao do Terraform do RDS PostgreSQL em `oficina-dgcar-infra-db`.
- Criacao de subnet group, security group, parameter group e outputs.
- Uso de state remoto S3 com `use_lockfile=true`.
- Ajustes para ambiente de laboratorio AWS Free Tier:
  - `backup_retention_period=0` em homologacao;
  - `db.t3.micro` e `gp2` em homologacao.
- Publicacao automatizada de outputs do RDS para repos dependentes.

## Infraestrutura Kubernetes E Gateway

- Separacao do Terraform de EKS, ECR e API Gateway em `oficina-dgcar-infra-k8s`.
- Criacao do cluster EKS e do reposititorio ECR.
- Criacao do API Gateway HTTP como entrada oficial.
- Integracao `POST /auth/cpf` com Lambda Auth.
- Integracao `ANY /{proxy+}` com a aplicacao Spring Boot no EKS.
- Configuracao de access entry do EKS para o principal usado pelo GitHub Actions.

## Lambda Auth CPF E Senha

- Criacao da Lambda Auth em Node.js 20.
- Validacao de CPF.
- Consulta do cliente no PostgreSQL.
- Validacao de senha contra hash bcrypt armazenado em `clientes.senha_hash`.
- Emissao de JWT externo com `tipo=CLIENTE`.
- Separacao entre JWT externo de cliente e JWT interno de funcionarios.
- Provisionamento da infraestrutura AWS da Lambda via Terraform no proprio repositorio.

## Aplicacao Principal

- Extracao da aplicacao Spring Boot para `oficina-dgcar-api`.
- Validacao do JWT externo `CLIENTE` na aplicacao.
- Restricao de consulta de OS do cliente pelo CPF presente no `sub` do token.
- Consulta demonstravel por numero legivel da OS, sem expor `clienteId` como entrada do cliente externo.
- Preservacao da autenticacao interna de funcionarios.

## Observabilidade

- Planejamento da integracao com New Relic.
- Definicao de logs estruturados JSON.
- Definicao de correlation-id por requisicao.
- Definicao de dashboards e alertas para API, Kubernetes e metricas de negocio.

## Documentacao Central

- Criacao deste repositorio central de documentacao.
- Consolidacao de ADRs, RFCs, diagramas, documentacao de banco, observabilidade e evidencias.
- READMEs tecnicos mantidos focados no escopo de cada repositorio.
