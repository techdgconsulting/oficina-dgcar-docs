# Banco De Dados

Documentação da modelagem do banco de dados da Oficina DGCar.

A escolha do PostgreSQL e suas justificativas estão na [ADR-003](../adr/ADR-003-postgresql.md). A adoção do Amazon RDS e os critérios de operação gerenciada estão na [ADR-017](../adr/ADR-017-postgresql-gerenciado.md).

Conteudo:

- modelo relacional e cardinalidades;
- dicionario de dados;
- indices de performance;
- plano de cluster externo gerenciado;
- relacao do banco com a API principal e a Lambda Auth CPF + Senha.

Documentos principais:

- [modelo-relacional.md](modelo-relacional.md)
- [dicionario-dados.md](dicionario-dados.md)
- [indices-performance.md](indices-performance.md)
- [plano-cluster-postgresql-gerenciado.md](plano-cluster-postgresql-gerenciado.md)
- [diagrama-er.puml](diagrama-er.puml)
