# ADR-017: PostgreSQL Gerenciado Como Banco Corporativo

**Status:** Aceito  
**Data:** 2026-09-27  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

O projeto ja utiliza PostgreSQL como banco principal e Amazon RDS PostgreSQL como banco gerenciado em nuvem. O novo desafio exige melhorar e documentar a modelagem do banco de dados, garantindo consistencia e performance.

## Decisao

Manter PostgreSQL gerenciado via Amazon RDS como banco corporativo da solucao.

## Justificativa

- O dominio possui relacionamentos fortes entre cliente, veiculo, ordem de servico, itens, orcamento, pagamento, execucao, entrega e encerramento.
- O modelo exige integridade referencial e transacoes.
- PostgreSQL oferece indices, constraints, transacoes ACID e otimizador maduro.
- RDS reduz esforco operacional de provisionamento, patching, storage e backups.
- A aplicacao ja usa Flyway para evolucao versionada do schema.
- A base atual ja possui indices para consultas frequentes.

## Impacto Na Modelagem

As proximas fases devem produzir:

- diagrama ER;
- dicionario de dados;
- justificativa formal de entidades e relacionamentos;
- revisao de indices;
- analise de consultas de fila operacional e metricas;
- avaliacao de campo de status do cliente para autenticacao por CPF e senha;
- documentacao de cardinalidades.

## Aspectos Operacionais

O banco gerenciado deve considerar:

- backup;
- criptografia em repouso;
- acesso apenas por redes e security groups autorizados;
- parametros de conexao controlados por segredo;
- monitoramento de conexoes, CPU, memoria e storage;
- estrategia de migracao via Flyway.

## Consequencias Positivas

- Mantem consistencia transacional do dominio.
- Reduz risco de perda de integridade.
- Facilita consultas relacionais e metricas.
- Aproveita conhecimento e artefatos existentes.
- Atende requisito de banco gerenciado.

## Consequencias Negativas

- Custo continuo em nuvem.
- Escalabilidade horizontal do banco e mais limitada que em modelos NoSQL.
- Exige cuidado com pool de conexoes, indices e queries.
- A Lambda Auth CPF + Senha precisa de conectividade segura com o banco.

## Alternativas Consideradas

| Alternativa | Motivo da nao escolha |
|---|---|
| DynamoDB | Bom para escala chave-valor, mas menos aderente ao modelo relacional atual |
| MySQL gerenciado | Viavel, mas o projeto ja esta modelado e testado com PostgreSQL |
| Banco em container no cluster | Menor maturidade operacional e nao atende tao bem banco gerenciado |
| H2 | Adequado apenas para dev/test, nao para producao |

## Relacao Com Outros Documentos

- `ADR-003`: decisao original por PostgreSQL.
- `RFC-005`: separacao do Terraform de banco e Kubernetes.
- `V1__criar_tabelas.sql` e migrations seguintes: evolucao versionada do schema.
