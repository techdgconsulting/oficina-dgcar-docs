# RFC-005: Separacao Do Terraform De Kubernetes E Banco

**Status:** Proposto  
**Data:** 2026-09-27  
**Contexto:** Tech Challenge - Infraestrutura como Codigo  
**Escopo:** Estados Terraform e dependencias entre repositorios

## Contexto

O projeto atual possui Terraform para provisionar recursos de infraestrutura em uma estrutura unica. A nova fase exige quatro repositorios e separa explicitamente infraestrutura Kubernetes e infraestrutura de banco de dados gerenciado.

## Problema

Manter EKS, ECR, API Gateway, RDS e recursos relacionados em um unico estado Terraform cria acoplamento operacional. Alteracoes no cluster nao deveriam exigir alteracoes no banco, e alteracoes no banco nao deveriam expor o cluster a risco desnecessario.

## Decisao Proposta

Separar a infraestrutura em pelo menos dois estados Terraform:

| Estado | Repositorio | Responsabilidade |
|---|---|---|
| Banco | `oficina-dgcar-infra-db` | RDS PostgreSQL, subnet group, parametros, security group de banco e outputs de conexao |
| Kubernetes | `oficina-dgcar-infra-k8s` | EKS, ECR, API Gateway, integracoes, HPA/manifests e permissao de deploy |

## Responsabilidades Do Estado De Banco

- Criar RDS PostgreSQL gerenciado.
- Configurar subnets privadas e subnet group, quando aplicavel.
- Configurar security group do banco.
- Configurar parametros de backup, storage e versionamento.
- Expor outputs necessarios de conexao sem expor senha.

## Responsabilidades Do Estado Kubernetes

- Criar EKS e node groups.
- Criar ECR.
- Criar API Gateway e integracoes.
- Criar permissoes para pipelines e workloads.
- Aplicar ou preparar manifests Kubernetes.
- Integrar com outputs do banco.

## Outputs Compartilhados

| Origem | Output | Consumidor |
|---|---|---|
| Banco | endpoint RDS | Aplicacao / infra-k8s |
| Banco | porta | Aplicacao / infra-k8s |
| Banco | nome do banco | Aplicacao / infra-k8s |
| Banco | security group do banco | Infra-k8s, se houver regras cruzadas |
| Kubernetes | ECR repository URL | Aplicacao |
| Kubernetes | cluster name | Aplicacao |
| Kubernetes | API Gateway URL | Lambda / README / demonstracao |

## Dependencias Entre Estados

O estado Kubernetes pode consumir outputs do estado de banco por `terraform_remote_state` ou por variaveis injetadas pela pipeline. Para reduzir acoplamento, a estrategia preferencial sera passar outputs necessarios via pipeline e documentar claramente as dependencias.

## Riscos

- Ordem de criacao mais importante.
- Necessidade de gerenciar dois backends remotos.
- Possivel drift se outputs forem copiados manualmente.
- Permissoes IAM separadas exigem mais cuidado.

## Estrategia De Migracao

1. Mapear recursos atuais por dominio: banco, cluster, imagem, gateway e aplicacao.
2. Extrair recursos de banco para `oficina-dgcar-infra-db`.
3. Extrair recursos de cluster/API Gateway/ECR para `oficina-dgcar-infra-k8s`.
4. Definir outputs e variaveis compartilhadas.
5. Ajustar pipelines para aplicar banco antes do cluster quando necessario.
6. Documentar rollback e destroy de cada estado.

## Relacao Com O Tech Challenge

Esta separacao atende a exigencia de repositorios independentes para infraestrutura Kubernetes e infraestrutura de banco de dados gerenciado.
