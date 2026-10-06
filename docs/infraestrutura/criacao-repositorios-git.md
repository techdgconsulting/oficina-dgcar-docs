# Criacao Dos Repositorios Git

Este documento registra a preparacao dos quatro repositorios exigidos pelo Tech Challenge 3.

## Repositorios Criados

| Repositorio | Responsabilidade |
|---|---|
| `oficina-dgcar-auth-lambda` | Lambda de autenticacao externa por CPF e senha |
| `oficina-dgcar-infra-k8s` | Infraestrutura Kubernetes, EKS, ECR, API Gateway e manifests |
| `oficina-dgcar-infra-db` | Infraestrutura do banco PostgreSQL gerenciado |
| `oficina-dgcar-api` | Aplicacao principal Spring Boot |

## Organizacao Aplicada

Cada repositorio recebeu:

- `README.md` inicial;
- `.gitignore` adequado ao escopo;
- branch `main`;
- branch `homolog`;
- pipeline de validacao;
- environments `homolog` e `prod`.

## Protecao De Branch

As regras de protecao da `main` foram aplicadas nos quatro repositorios:

- Pull Request obrigatorio;
- aprovacao obrigatoria;
- check `validate` obrigatorio;
- branch atualizada antes do merge;
- conversas resolvidas antes do merge;
- historico linear;
- bloqueio de force push;
- bloqueio de exclusao da branch.

## Publicacao

Os repositorios foram publicados em:

- `https://github.com/techdgconsulting/oficina-dgcar-auth-lambda`
- `https://github.com/techdgconsulting/oficina-dgcar-infra-k8s`
- `https://github.com/techdgconsulting/oficina-dgcar-infra-db`
- `https://github.com/techdgconsulting/oficina-dgcar-api`

## Registro De Escopo

A preparacao dos repositorios estabeleceu a base para extracao de artefatos, pipelines e deploys separados, preservando o repositorio historico como origem da evolucao.
