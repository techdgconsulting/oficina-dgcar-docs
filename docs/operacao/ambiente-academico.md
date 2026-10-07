# Ambiente Academico AWS

Este documento concentra a operacao do ambiente academico da Oficina DGCar Tech Challenge 3.

O provisionamento e o teardown sao executados por workflows orquestrados no repositorio `oficina-dgcar-docs`. Os workflows tecnicos dos demais repositorios continuam existindo, mas a operacao principal passa pelo repositorio central.

## Workflows Operacionais

| Operacao | Repositorio | Workflow | Confirmacao |
|---|---|---|---|
| Provisionamento completo | `oficina-dgcar-docs` | `Provisionar Ambiente Academico` | `PROVISIONAR` |
| Teardown completo | `oficina-dgcar-docs` | `Destruir Ambiente Academico` | `DESTRUIR` |

## Secrets Do Orquestrador

Configurar os secrets abaixo no environment `homolog` do repositorio `oficina-dgcar-docs`.

| Secret | Uso |
|---|---|
| `GH_AUTOMATION_TOKEN` | Dispara workflows e consulta execucoes nos repositorios tecnicos |

O token `GH_AUTOMATION_TOKEN` precisa de permissao para:

- disparar workflows nos repositorios tecnicos;
- consultar execucoes de workflows;
- gravar secrets de environment quando os workflows tecnicos publicam outputs.

As credenciais AWS permanecem nos environments dos repositorios tecnicos. O orquestrador nao duplica `AWS_ACCESS_KEY_ID` nem `AWS_SECRET_ACCESS_KEY`; ele dispara os workflows que ja possuem essas credenciais.

## Secrets Da Validacao Funcional

Os secrets abaixo sao usados somente quando o input `run_smoke_tests=true` e existe massa de dados no banco.

| Secret | Uso |
|---|---|
| `GATEWAY_BASE_URL` | URL do API Gateway usada pelos smoke tests |
| `CLIENT_TEST_CPF` | CPF de cliente existente no banco |
| `CLIENT_TEST_PASSWORD` | Senha desse cliente |
| `CLIENT_TEST_OS_NUMBER` | Numero de OS pertencente ao CPF autenticado |

O provisionamento de infraestrutura nao depende desses valores.

## Provisionamento Completo

Execucao:

```text
Actions -> Provisionar Ambiente Academico
environment=homolog
confirm=PROVISIONAR
run_smoke_tests=false
```

Fluxo executado:

1. Valida credenciais AWS e acesso aos quatro repositorios tecnicos.
2. Executa `oficina-dgcar-infra-k8s` com workflow `Infra K8s`, `action=apply`, criando VPC, EKS, ECR e API Gateway base.
3. Executa `oficina-dgcar-infra-db` com workflow `Managed Database Terraform`, `action=apply`, criando o RDS PostgreSQL.
4. Executa `oficina-dgcar-auth-lambda` com workflow `Auth CPF Lambda`, `action=apply-infra`, criando Lambda, IAM, Log Group e security group.
5. Executa novo apply do banco para liberar PostgreSQL ao security group real da Lambda.
6. Executa `oficina-dgcar-auth-lambda` com `action=deploy-code`, publicando o pacote da funcao.
7. Executa novo apply do `oficina-dgcar-infra-k8s`, criando a rota `POST /auth/cpf`.
8. Executa `oficina-dgcar-api` com workflow `App CI/CD - Build, Test and Deploy`, publicando a aplicacao no EKS.
9. Executa novo apply do `oficina-dgcar-infra-k8s`, criando a rota proxy `ANY /{proxy+}`.
10. Resolve o endpoint do API Gateway.
11. Executa smoke tests quando `run_smoke_tests=true`:
    - autenticacao por CPF e senha;
    - consulta protegida por numero de OS com JWT;
    - bloqueio de consulta sem JWT.
12. Publica resumo da operacao no job summary.

## Teardown Completo

Execucao:

```text
Actions -> Destruir Ambiente Academico
environment=homolog
confirm=DESTRUIR
```

Fluxo executado:

1. Valida credenciais AWS e acesso aos workflows.
2. Resolve a VPC do environment por tags do projeto.
3. Executa `oficina-dgcar-infra-k8s` com workflow `Destroy Infra K8s`, `action=cleanup-workloads`, removendo workloads Kubernetes e Load Balancers.
4. Executa `oficina-dgcar-infra-db` com workflow `Managed Database Terraform`, `action=destroy`.
5. O destroy do banco persiste a configuracao academica antes da remocao:
   - `deletion_protection=false`;
   - `skip_final_snapshot=true`;
   - `backup_retention_period=0`;
   - `db_instance_class=db.t3.micro`;
   - `db_storage_type=gp2`.
6. Executa `oficina-dgcar-auth-lambda` com workflow `Auth CPF Lambda`, `action=destroy-infra`.
7. Aguarda liberacao de ENIs gerenciadas.
8. Lista dependencias restantes da VPC:
   - ENIs;
   - security groups;
   - Load Balancers;
   - NAT Gateways;
   - VPC endpoints;
   - Internet Gateways;
   - subnets;
   - route tables.
9. Remove dependencias seguras:
   - Load Balancers restantes;
   - VPC endpoints da VPC alvo;
   - security groups residuais de Kubernetes/EKS sem ENI.
10. Executa `oficina-dgcar-infra-k8s` com workflow `Destroy Infra K8s`, `action=destroy`.
11. Se o destroy final falhar, executa novo diagnostico de VPC, limpa dependencias removiveis e tenta o destroy final mais uma vez.
12. Valida que os recursos principais nao existem mais:
   - VPC;
   - EKS;
   - RDS;
   - Lambda;
   - API Gateway.
13. Publica resumo da operacao no job summary.

## Falhas Tratadas Pela Automacao

| Falha historica | Tratamento implementado |
|---|---|
| API Gateway com URI invalida | Rotas dependentes sao aplicadas depois dos outputs reais da Lambda e da API |
| RDS bloqueado por Free Tier | `homolog` usa `backup_retention_period=0`, `db.t3.micro` e `gp2` |
| RDS com snapshot final duplicado | `homolog` usa `skip_final_snapshot=true` |
| RDS com deletion protection | `homolog` persiste `deletion_protection=false` antes do destroy |
| Lambda destroy sem pacote ZIP | Workflow da Lambda empacota antes do destroy |
| Secret `AUTH_LAMBDA_*` ausente | Limpeza idempotente registra ausencia e continua |
| Backend S3 com parametro depreciado | Workflows usam `use_lockfile=true` |
| AWS region ausente | Jobs usam `AWS_REGION` com fallback operacional `us-east-1` |
| Kubectl sem credenciais | Workflows atualizam kubeconfig antes de operar o cluster |
| VPC com SG residual de EKS | Scripts removem SGs residuais sem ENI antes do destroy final |

## Evidencias Para O Video

Coletar no final do provisionamento:

- job summary do workflow `Provisionar Ambiente Academico`;
- endpoint do API Gateway;
- resposta `200` de `POST /auth/cpf`;
- JWT `CLIENTE` retornado;
- consulta protegida por numero de OS;
- dashboard do EKS;
- RDS criado;
- Lambda criada;
- API Gateway com rotas `POST /auth/cpf` e `ANY /{proxy+}`.

Coletar no final do teardown:

- job summary do workflow `Destruir Ambiente Academico`;
- validacao de ausencia de VPC, EKS, RDS, Lambda e API Gateway;
- diagnostico sem dependencias residuais.
