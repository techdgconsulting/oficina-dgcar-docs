# Arquitetura Alvo Tech Challenge 3

Este documento registra a consolidacao da arquitetura alvo da Oficina DGCar para o Tech Challenge 3.

## Decisoes Consolidadas

| Decisao | Resultado |
|---|---|
| Entrada oficial | Amazon API Gateway |
| Autenticacao externa | AWS Lambda com CPF e senha |
| Token externo | JWT `CLIENTE` separado do JWT interno |
| Validacao de token | API Gateway e aplicacao Spring Boot |
| Banco gerenciado | Amazon RDS PostgreSQL |
| Execucao da aplicacao | Amazon EKS |
| Infraestrutura como codigo | Terraform separado para DB e K8s |
| Observabilidade | New Relic, logs JSON e correlation-id |
| Repositorios tecnicos | API, Lambda, Infra DB e Infra K8s |

## Escopo Arquitetural

A arquitetura final coloca o API Gateway como entrada oficial. A rota `POST /auth/cpf` chama a Lambda Auth CPF + Senha, que valida CPF e senha, consulta o PostgreSQL e emite JWT externo com `tipo=CLIENTE`.

A aplicacao Spring Boot roda no EKS e valida tambem o JWT externo por defesa em profundidade. O cliente externo consulta sua OS pelo numero legivel, e a API compara o CPF da OS com o `sub` do token.

O banco PostgreSQL foi movido para Amazon RDS gerenciado, com acesso privado e regras de security group controladas por Terraform.

## Entregas Vinculadas

- Quatro repositorios tecnicos criados e protegidos.
- Terraform de banco separado do Terraform de Kubernetes.
- Lambda Auth CPF + Senha implementada.
- API Gateway integrado a Lambda e a API no EKS.
- JWT externo de cliente validado pela API.
- Documentacao arquitetural centralizada neste repositorio.

## Evolucoes Planejadas

- Completar dashboards e alertas New Relic.
- Fortalecer evidencias de logs JSON e correlation-id.
- Refinar o diagrama ER com base no schema final.
- Evoluir `status_cliente` quando a regra de negocio exigir bloqueio operacional de cliente.
