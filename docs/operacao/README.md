# Operação

Este índice aponta para os procedimentos mantidos nos repositórios responsáveis pela execução de cada componente. As decisões e suas justificativas ficam nas ADRs; os comandos, parâmetros e workflows ficam nos guias técnicos.

| Assunto | Guia técnico | Decisão arquitetural |
|---|---|---|
| Provisionamento, verificação e remoção dos ambientes AWS | [Operação do ambiente — infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#provisionamento-completo) | [ADR-019 — Infraestrutura AWS](../adr/ADR-019-infraestrutura-aws-terraform-kubernetes.md) |
| Configuração, ensaio e evidências do HPA | [Validação do HPA — infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#hpa-e-capacidade) | [ADR-015 — Escalabilidade](../adr/ADR-015-hpa-cluster-autoscaling.md) |
| Operação do PostgreSQL gerenciado | [Operação do banco — infra-db](https://github.com/techdgconsulting/oficina-dgcar-infra-db/blob/homolog/README.md) | [ADR-017 — PostgreSQL gerenciado](../adr/ADR-017-postgresql-gerenciado.md) |
| Configuração e deploy da autenticação externa | [README da Lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda#readme) | [ADR-014 — Lambda Auth](../adr/ADR-014-lambda-autenticacao-cliente-cpf.md) |
| Execução, testes e deploy da API | [README da API](https://github.com/techdgconsulting/oficina-dgcar-api#readme) | [ADR-008 — Stack](../adr/ADR-008-stack-tecnologico.md) |

Os guias de infraestrutura contêm os critérios de validação, os resultados registrados e os links das execuções. Consulte também a [documentação de observabilidade](../observabilidade/) para logs, métricas, dashboards e alertas.
