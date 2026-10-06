# RFC-003: Separacao Em Quatro Repositorios

**Status:** Proposto  
**Data:** 2026-09-27  
**Contexto:** Tech Challenge - Estrutura de Repositorios e CI/CD  
**Escopo:** Organizacao de codigo, infraestrutura e pipelines

## Contexto

O reposititorio atual concentra aplicacao, infraestrutura, Kubernetes, documentacao e pipelines. O desafio exige quatro repositorios separados, cada um com CI/CD implementado e instrucoes claras.

## Problema

Um unico repositorio facilita o desenvolvimento inicial, mas dificulta separar responsabilidades, aplicar pipelines independentes e demonstrar maturidade operacional. A nova fase exige ownership explicito por dominio tecnico.

## Decisao Proposta

Separar o projeto em quatro repositorios:

| Repositorio | Responsabilidade principal |
|---|---|
| `oficina-dgcar-auth-lambda` | Function Serverless de autenticacao por CPF |
| `oficina-dgcar-infra-k8s` | Infraestrutura Kubernetes, API Gateway, EKS, ECR, HPA e manifests |
| `oficina-dgcar-infra-db` | Banco PostgreSQL gerenciado, rede de banco, parametros e outputs |
| `oficina-dgcar-api` | Aplicacao principal Spring Boot executando em Kubernetes |

O plano operacional de extracao controlada, incluindo matriz de origem/destino, dependencias entre repositorios, ordem recomendada, estrategia de branches e criterios para iniciar a separacao fisica, esta documentado em [`docs/infraestrutura/plano-separacao-repositorios-tc3.md`](../infraestrutura/plano-separacao-repositorios-tc3.md).

## Artefatos Esperados Por Repositorio

### `oficina-dgcar-auth-lambda`

- Codigo da Lambda Auth CPF.
- Testes automatizados.
- Definicao de empacotamento.
- Pipeline de build e deploy.
- README com contrato, variaveis e deploy.

### `oficina-dgcar-infra-k8s`

- Terraform do EKS, ECR, API Gateway e recursos relacionados.
- Manifests Kubernetes ou Kustomize/Helm.
- HPA e configuracao de escalabilidade.
- Pipeline de infraestrutura.
- README com desenho da infraestrutura.

### `oficina-dgcar-infra-db`

- Terraform do RDS PostgreSQL.
- Security groups, subnet group, parametros e outputs.
- Documentacao de backup, sizing e seguranca.
- Pipeline de infraestrutura.
- README com modelo operacional do banco.

### `oficina-dgcar-api`

- Aplicacao Spring Boot.
- Dockerfile.
- Testes, Swagger/OpenAPI e Postman.
- Pipeline de build, scan, push no ECR e deploy no EKS.
- README com execucao local, deploy e links de API.

## CI/CD Esperado

Cada repositorio deve possuir pipeline propria com:

- validacao em Pull Request;
- deploy automatico de homologacao;
- deploy automatico ou controlado de producao;
- secrets por ambiente;
- logs de execucao preservados como evidencia.

## Estrategia De Branches

| Branch | Papel |
|---|---|
| `main` | Producao, protegida e sem commits diretos |
| `homolog` | Deploy automatico de homologacao |
| feature branches | Desenvolvimento via Pull Request |

## Regras De Protecao

- `main` protegida.
- Pull Request obrigatorio.
- Checks obrigatorios antes do merge.
- Revisao obrigatoria, quando aplicavel.
- Segredos fora do repositorio.

## Estrategia De Transicao

1. Congelar o reposititorio atual como referencia historica.
2. Criar os quatro repositorios vazios com README inicial.
3. Extrair a aplicacao principal para `oficina-dgcar-api`.
4. Separar Terraform de banco para `oficina-dgcar-infra-db`.
5. Separar Kubernetes/API Gateway/EKS/ECR para `oficina-dgcar-infra-k8s`.
6. Criar `oficina-dgcar-auth-lambda`.
7. Ajustar pipelines e documentar dependencias entre repositorios.

## Riscos

- Duplicacao temporaria de configuracoes.
- Quebra de dependencias entre outputs Terraform.
- Dificuldade de sincronizar versoes entre repositorios.
- Aumento de trabalho operacional.

## Relacao Com O Tech Challenge

Esta RFC atende diretamente a exigencia de quatro repositorios separados, todos com CI/CD, README e deploy automatico.
