# Justificativa Do PostgreSQL

O PostgreSQL foi mantido como banco relacional principal por aderir ao dominio da oficina mecanica, que possui entidades com relacionamentos fortes, integridade transacional e necessidade de consultas consistentes.

## Motivos Da Escolha

- Suporte transacional ACID para ordens de servico, orcamentos e pagamentos.
- Integridade referencial entre clientes, veiculos, ordens, itens, orcamentos e pagamentos.
- Indices flexiveis para consultas operacionais e metricas.
- Compatibilidade com Spring Boot, JPA/Hibernate e Flyway.
- Operacao gerenciada via Amazon RDS PostgreSQL.
- Facilidade de auditoria e modelagem relacional para avaliacao academica.

## Uso Gerenciado

O banco foi provisionado pelo repositorio `oficina-dgcar-infra-db` usando Terraform.

Recursos gerenciados:

- Amazon RDS PostgreSQL;
- DB subnet group;
- security group do banco;
- parameter group;
- backups parametrizados por ambiente;
- criptografia de storage;
- acesso privado restrito por security group.

## Relacao Com A Lambda Auth CPF

A Lambda `oficina-dgcar-auth-lambda` consulta a tabela `clientes` para:

- localizar cliente por CPF;
- validar existencia;
- validar senha por `senha_hash`;
- obter `clienteId`;
- validar status quando `status_cliente` estiver disponivel.

## Relacao Com A API Principal

A aplicacao `oficina-dgcar-api` usa o PostgreSQL para persistir:

- clientes;
- veiculos;
- ordens de servico;
- itens de OS;
- orcamentos;
- decisoes externas de orcamento;
- pagamentos;
- execucoes, diagnosticos, encerramentos e entregas;
- usuarios internos.
