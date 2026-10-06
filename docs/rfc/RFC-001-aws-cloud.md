# RFC-001: Escolha Da AWS Como Cloud Alvo

**Status:** Proposto  
**Data:** 2026-09-27  
**Contexto:** Tech Challenge Fase 3   
**Escopo:** Arquitetura cloud alvo

## Contexto

O projeto Oficina Mecanica DGCar ja possui uma base de infraestrutura em AWS, com Terraform, Amazon EKS, Amazon ECR, Amazon RDS PostgreSQL, Amazon S3 para state remoto e GitHub Actions. O novo desafio exige API Gateway, Function Serverless, banco gerenciado, Kubernetes escalavel, observabilidade e CI/CD completo em repositorios separados.

Esta RFC define a cloud alvo antes da separacao fisica dos repositorios e antes da implementacao dos novos componentes.

## Problema

A arquitetura precisa evoluir para um ambiente corporativo demonstravel, com seguranca, escalabilidade, alta disponibilidade, observabilidade e automacao. A escolha da cloud deve reduzir risco de retrabalho, aproveitar a infraestrutura ja documentada e atender aos requisitos obrigatorios da fase.

## Opcoes Consideradas

| Opcao | Pontos fortes | Limitacoes |
|---|---|---|
| AWS | Ja usada no projeto; possui EKS, RDS, ECR, API Gateway, Lambda, IAM e S3; boa integracao com Terraform | Exige cuidado com custos e permissoes IAM |
| Azure | Possui AKS, Azure Functions, API Management e PostgreSQL gerenciado | Exigiria migracao de toda a infraestrutura existente |
| Google Cloud | Possui GKE, Cloud Functions, API Gateway e Cloud SQL | Exigiria migracao e nova curva operacional |
| Local/Docker Compose | Baixo custo e simples para desenvolvimento | Nao atende plenamente requisitos de cloud, serverless, API Gateway e banco gerenciado |

## Decisao Proposta

Usar AWS como cloud alvo da fase.

## Justificativa

- O projeto ja possui Terraform para AWS.
- O ambiente atual ja contempla EKS, ECR e RDS PostgreSQL.
- AWS API Gateway e AWS Lambda atendem diretamente ao requisito de Gateway e Function Serverless.
- EKS permite manter a aplicacao principal no modelo Kubernetes ja existente.
- RDS PostgreSQL preserva a decisao relacional e o uso de Flyway.
- ECR centraliza imagens Docker consumidas pelo cluster.
- S3 permite manter state remoto do Terraform.
- IAM permite controle de acesso entre pipelines, Lambda, API Gateway, EKS e RDS.

## Impactos

- As proximas fases devem separar a infraestrutura AWS em repositorios e estados Terraform coerentes.
- Os custos de EKS, RDS, Load Balancer, API Gateway e Lambda precisam ser controlados.
- As permissoes IAM devem ser documentadas e minimizadas.
- Os diagramas e READMEs dos quatro repositorios devem assumir AWS como plataforma alvo.

## Riscos

- Custo continuo se os recursos nao forem destruidos apos demonstracao.
- Complexidade de IAM e conectividade entre Lambda e RDS.
- Dependencia de configuracao correta de VPC, subnets e security groups.
- Possivel aumento de tempo de deploy em pipelines de infraestrutura.

## Alternativas Descartadas

- **Azure:** tecnicamente viavel, mas geraria migracao desnecessaria.
- **Google Cloud:** tecnicamente viavel, mas com menor aderencia ao estado atual.
- **Somente local:** insuficiente para os requisitos obrigatorios.

## Relacao Com O Tech Challenge

Esta decisao apoia os requisitos de API Gateway, Function Serverless, banco gerenciado, Kubernetes escalavel, Terraform e deploy automatico em nuvem.
