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

## Operacao Do Ambiente AWS

O ambiente academico foi operado com provisionamento manual protegido por GitHub Environments. Essa decisao evita criacao acidental de recursos pagos e preserva aprovacao humana antes de qualquer `apply`, deploy ou destroy.

### Provisionamento Completo

A ordem operacional para subir o ambiente em `homolog` ficou definida assim:

1. `oficina-dgcar-infra-k8s`: executar `Infra K8s` com `action=apply` para criar rede, EKS, ECR e API Gateway base, ainda sem rotas dependentes da Lambda ou da aplicacao.
2. `oficina-dgcar-infra-db`: executar `Infra DB` com `action=apply` para criar o RDS PostgreSQL na rede publicada pelo repo Kubernetes.
3. `oficina-dgcar-auth-lambda`: executar `Auth CPF Lambda` com `action=apply-infra` para criar a Lambda Auth CPF + Senha, IAM, Log Group e security group.
4. `oficina-dgcar-infra-db`: executar novo `apply` para liberar o PostgreSQL ao security group publicado pela Lambda.
5. `oficina-dgcar-auth-lambda`: executar `Auth CPF Lambda` com `action=deploy-code` para publicar o pacote da funcao.
6. `oficina-dgcar-infra-k8s`: executar novo `apply` para criar ou atualizar a integracao `POST /auth/cpf` do API Gateway com a Lambda.
7. `oficina-dgcar-api`: executar `App CI/CD - Build, Test and Deploy` com `action=deploy` para publicar a aplicacao no EKS.
8. `oficina-dgcar-infra-k8s`: registrar `API_BACKEND_URL` no environment `homolog` com o endpoint HTTP publicado pelo Service da API.
9. `oficina-dgcar-infra-k8s`: executar novo `apply` para criar a rota proxy `ANY /{proxy+}` apontando para o backend Kubernetes.

Essa ordem respeita as dependencias entre repositorios: a Lambda precisa da rede e do banco; o banco precisa conhecer o security group da Lambda; o Gateway precisa conhecer os outputs da Lambda para `/auth/cpf`; e a rota proxy da API depende do endpoint HTTP publicado depois do deploy da aplicacao.

### Validacao Funcional

Depois do provisionamento, a validacao demonstravel usa:

1. health da aplicacao no EKS;
2. `POST /auth/cpf` com CPF e senha validos;
3. JWT `CLIENTE` retornado pela Lambda;
4. consulta protegida da OS por numero usando `Authorization: Bearer <accessToken>`;
5. chamadas negativas sem token, com token invalido e com OS de outro cliente.

### Teardown Completo

A ordem operacional para destruir o ambiente academico ficou definida assim:

1. `oficina-dgcar-api`: remover workloads da aplicacao ou executar o fluxo de deploy/limpeza disponivel para retirar pods, service e Load Balancer.
2. `oficina-dgcar-auth-lambda`: executar destroy da infraestrutura da Lambda quando a action estiver disponivel, removendo Lambda, Log Group, IAM e security group.
3. `oficina-dgcar-infra-k8s`: executar `Destroy Infra K8s` com `confirm_destroy=DESTROY` para remover EKS, API Gateway, ECR, VPC, subnets, rotas e recursos Kubernetes auxiliares.
4. `oficina-dgcar-infra-db`: executar destroy do RDS PostgreSQL por ultimo, removendo a instancia, subnet group, parameter group e security group do banco.

O banco fica por ultimo porque API e Lambda dependem dele durante validacoes. O repo `infra-k8s` executa limpeza especifica de Load Balancers e security groups orfaos antes de destruir a VPC, reduzindo falhas por dependencia presa na AWS.

## Fonte De Verdade

Este repositorio e a fonte principal para documentacao arquitetural do Tech Challenge 3.

Os READMEs dos repositorios tecnicos documentam apenas o escopo de execucao, deploy, variaveis e operacao especifica de cada componente.

O repositorio `mvp-posfiap-oficina-mecanica` permanece preservado como origem historica da evolucao do projeto.
