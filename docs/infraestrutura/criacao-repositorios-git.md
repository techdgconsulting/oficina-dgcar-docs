# Etapa 2 - Criação Dos Repositórios Git

## Objetivo

Registrar a preparação inicial dos quatro repositórios Git exigidos pelo Tech Challenge 3.

## Repositórios Preparados Localmente

| Repositório | Responsabilidade |
|---|---|
| `oficina-dgcar-auth-lambda` | Lambda de autenticação externa por CPF. |
| `oficina-dgcar-infra-k8s` | Infraestrutura Kubernetes, EKS, ECR, API Gateway e manifests. |
| `oficina-dgcar-infra-db` | Infraestrutura de banco gerenciado PostgreSQL. |
| `oficina-dgcar-api` | Aplicação principal Spring Boot. |

## Estrutura Inicial Criada

Cada repositório local contém:

- `README.md` base.
- `.gitignore` adequado ao escopo.
- `.github/workflows/ci.yml` com validação mínima de estrutura.
- branch `main`.
- branch `homolog`.

## Publicação No GitHub

As branches `main` e `homolog` foram publicadas nos quatro repositórios remotos:

- `https://github.com/techdgconsulting/oficina-dgcar-auth-lambda`
- `https://github.com/techdgconsulting/oficina-dgcar-infra-k8s`
- `https://github.com/techdgconsulting/oficina-dgcar-infra-db`
- `https://github.com/techdgconsulting/oficina-dgcar-api`

## Proteção De Branch E Ambientes

As regras de proteção da branch `main` foram aplicadas nos quatro repositórios:

- Pull Request obrigatório.
- 1 aprovação obrigatória.
- Status check obrigatório `validate`.
- Branch atualizada antes do merge.
- Conversas resolvidas antes do merge.
- Histórico linear obrigatório.
- Administradores incluídos nas regras.
- Force push não permitido.
- Exclusão da branch não permitida.

Os GitHub Environments `homolog` e `prod` foram criados nos quatro repositórios. O environment `prod` possui aprovação obrigatória por reviewer.

## Ações Pendentes No GitHub

Para cada repositório remoto:

1. Configurar secrets conforme o README de cada repositório.
2. Configurar variables não sensíveis conforme necessidade de cada pipeline.
3. Revisar manualmente, na interface do GitHub, se os reviewers de `prod` estão adequados para o grupo.

## Comandos Sugeridos Após Criar Os Remotes

Caso seja necessário refazer a publicação, executar dentro de cada repositório local:

```bash
git push -u origin main
git push -u origin homolog
```

## Confirmação De Escopo

Esta etapa preparou a base local dos repositórios. Não houve extração de código Java, Terraform, Kubernetes, Postman, Dockerfile ou pipelines existentes do repositório histórico.
