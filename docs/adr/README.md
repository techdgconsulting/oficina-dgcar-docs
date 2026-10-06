# ADRs

Architecture Decision Records do projeto Oficina DGCar.

As ADRs registram decisoes arquiteturais permanentes, com contexto, decisao e consequencias.

Principais decisoes para o Tech Challenge 3:

- API Gateway como entrada oficial.
- Lambda para autenticacao externa por CPF e senha.
- JWT externo `CLIENTE` separado do JWT interno.
- HPA para escalabilidade da aplicacao.
- Logs estruturados e correlation-id.
- PostgreSQL gerenciado.
- Validacao de JWT externo tambem na API Spring Boot.
