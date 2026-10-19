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

O levantamento original registrou os itens abaixo. Esta lista preserva o histórico da decisão, não define pendências atuais. A modelagem está em [docs/banco](../banco), e a migration V18 da API já inclui `clientes.status_cliente`. A escolha do PostgreSQL pertence à [ADR-003](ADR-003-postgresql.md); esta ADR detalha o uso gerenciado, enquanto a [ADR-019](ADR-019-infraestrutura-aws-terraform-kubernetes.md) registra os fundamentos comuns da infraestrutura.

Itens do levantamento original:

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

## Proteção e retenção por ambiente

A configuração de homolog prioriza o uso temporário para validação: retenção automática zero, sem proteção contra exclusão e sem snapshot final. A configuração de prod prioriza a preservação dos dados: retenção automática de sete dias, proteção contra exclusão e snapshot final.

Essa distinção reduz o custo do ambiente de validação e protege os dados de produção. Como consequência, o procedimento de remoção de homolog não pode ser considerado equivalente ao de prod. Os comandos, a preparação da instância e as limitações atuais da automação ficam no [guia operacional de infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/docs/OPERACAO-AMBIENTE.md) e no [guia do banco](https://github.com/techdgconsulting/oficina-dgcar-infra-db/blob/homolog/docs/OPERACAO.md).

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
- `RFC-006`: escolha tecnica do PostgreSQL gerenciado como banco de dados.
- `RFC-005`: separacao do Terraform de banco e Kubernetes.
- `V1__criar_tabelas.sql` e migrations seguintes: evolucao versionada do schema.
