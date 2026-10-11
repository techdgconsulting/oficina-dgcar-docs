# ADR-019: Infraestrutura AWS Com Terraform E Kubernetes

**Status:** Aceito  
**Data:** 2026-10-10  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

A solucao evoluiu de um ambiente local para uma arquitetura em nuvem com entrada por API Gateway, autenticacao externa por Lambda, aplicacao Spring Boot executada em Kubernetes e banco PostgreSQL gerenciado.

Essa evolucao exige infraestrutura reprodutivel, separacao clara de responsabilidades, protecao de segredos, deploy automatizavel e capacidade de destruir o ambiente academico para controle de custo.

## Decisao

Adotar AWS como provedor de nuvem, Terraform como mecanismo de provisionamento e Amazon EKS como plataforma Kubernetes para execucao da aplicacao principal.

A infraestrutura fica organizada em repositorios tecnicos separados:

| Repositorio | Responsabilidade |
|---|---|
| `oficina-dgcar-infra-db` | Amazon RDS PostgreSQL, parametros, rede e outputs de banco |
| `oficina-dgcar-infra-k8s` | EKS, ECR, API Gateway, integracoes, manifests Kubernetes e HPA |
| `oficina-dgcar-api` | Aplicacao Spring Boot, imagem Docker, testes, Swagger/OpenAPI e Postman |
| `oficina-dgcar-auth-lambda` | Lambda de autenticacao externa por CPF e senha |

## Decisoes Complementares

- Usar backend remoto para o estado Terraform.
- Separar estado Terraform de banco e estado Terraform de Kubernetes.
- Executar a aplicacao principal em pods Kubernetes no EKS.
- Publicar imagens da aplicacao no Amazon ECR.
- Usar API Gateway como entrada oficial externa.
- Manter RDS PostgreSQL como banco gerenciado.
- Externalizar configuracoes por variaveis, ConfigMaps e Secrets.
- Usar HPA para escalabilidade horizontal da aplicacao.
- Usar pipelines GitHub Actions com environments protegidos para provisionamento, deploy e teardown.

## Justificativa

A separacao entre banco, Kubernetes, aplicacao e Lambda reduz acoplamento operacional e facilita demonstrar ownership tecnico por repositorio.

O Terraform permite reprodutibilidade e rastreabilidade da infraestrutura. O EKS atende ao requisito de execucao em Kubernetes com escalabilidade via HPA. O RDS reduz a carga operacional do banco e preserva compatibilidade com o modelo relacional PostgreSQL existente.

## Consequencias Positivas

- Infraestrutura versionada e reprodutivel.
- Responsabilidades claras entre repositorios.
- Deploy e teardown automatizaveis.
- Entrada externa padronizada por API Gateway.
- Banco gerenciado com menor operacao manual.
- Escalabilidade horizontal da API por HPA.

## Consequencias Negativas

- Mais repositorios e pipelines para coordenar.
- Dependencia de outputs entre estados Terraform.
- Maior cuidado com segredos e environments.
- Custo operacional maior que execucao local.

## Relacao Com Outros Documentos

- [RFC-001](../rfc/RFC-001-aws-cloud.md): escolha da AWS como cloud alvo.
- [RFC-003](../rfc/RFC-003-separacao-repositorios-github.md): separacao em repositorios especializados.
- [RFC-005](../rfc/RFC-005-separacao-terraform-k8s-banco.md): separacao dos estados Terraform.
- [ADR-013](ADR-013-api-gateway-entrada-oficial.md): API Gateway como entrada oficial.
- [ADR-015](ADR-015-hpa-cluster-autoscaling.md): HPA e estrategia de escalabilidade.
- [ADR-017](ADR-017-postgresql-gerenciado.md): PostgreSQL gerenciado como banco corporativo.
