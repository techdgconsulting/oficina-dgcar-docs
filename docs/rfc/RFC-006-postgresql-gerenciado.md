# RFC-006: Escolha Do PostgreSQL Gerenciado Como Banco De Dados

**Status:** Aceito  
**Data:** 2026-10-10  
**Contexto:** Tech Challenge - Banco de dados e modelagem relacional  
**Escopo:** Persistencia, modelo relacional e operacao gerenciada

## Contexto

A Oficina DGCar possui um dominio operacional com entidades altamente relacionadas: clientes, veiculos, ordens de servico, itens, diagnosticos, execucoes, orcamentos, decisoes externas, pagamentos, entregas e encerramentos.

O Tech Challenge exige justificativa formal para a escolha do banco de dados, ajustes no modelo relacional, diagramas ER e explicacao dos relacionamentos. A solucao tambem precisa operar em nuvem com banco gerenciado, integracao com a API Spring Boot no EKS e consulta pela Lambda Auth CPF + Senha.

## Problema

O banco de dados precisa atender simultaneamente a:

- integridade referencial entre entidades do ciclo de atendimento;
- transacoes consistentes para OS, orcamento, pagamento, entrega e encerramento;
- consultas por documento do cliente na autenticacao externa;
- consultas por numero legivel de OS para jornada do cliente;
- indices para fila operacional, metricas e rastreabilidade;
- operacao em nuvem com backup, criptografia, acesso privado e provisionamento por Terraform;
- evolucao controlada de schema por migrations versionadas.

## Opcoes Consideradas

| Opcao | Pontos fortes | Limitacoes |
|---|---|---|
| Amazon RDS PostgreSQL | Banco relacional gerenciado, ACID, FKs, indices, compatibilidade com Spring/JPA/Flyway e operacao privada em VPC | Custo continuo e necessidade de controlar conexoes, storage e parametros |
| PostgreSQL em container no Kubernetes | Mantem compatibilidade com PostgreSQL e reduz diferenca de dialeto | Aumenta responsabilidade operacional de backup, storage persistente, restore e disponibilidade |
| MySQL gerenciado | Relacional e gerenciado | Menor aderencia ao historico do projeto e exigiria migracao de dialeto/testes |
| DynamoDB | Escala horizontal e operacao gerenciada | Menos aderente ao modelo relacional com transacoes, cardinalidades e integridade referencial forte |
| H2 | Simples para testes rapidos | Nao representa banco de producao, constraints e dialeto PostgreSQL de forma suficiente |

## Decisao

Usar **Amazon RDS PostgreSQL** como banco de dados gerenciado da solucao, mantendo PostgreSQL como banco relacional principal do dominio.

O schema fisico permanece versionado por migrations Flyway no repositorio `oficina-dgcar-api`. A infraestrutura do banco fica isolada no repositorio `oficina-dgcar-infra-db`, com Terraform, state remoto proprio, subnet group, security group, parameter group e outputs controlados.

## Justificativa

- O dominio da oficina possui relacionamentos fortes e exige integridade referencial.
- Ordens de servico, orcamentos e pagamentos exigem consistencia transacional.
- PostgreSQL oferece suporte maduro a FKs, constraints, indices e tipos numericos adequados para valores monetarios.
- A aplicacao Spring Boot ja usa JPA/Hibernate e Flyway, reduzindo risco de migracao.
- RDS reduz a carga operacional de patching, backup, storage, criptografia e disponibilidade.
- O acesso privado por VPC e security groups atende a separacao entre API, Lambda e banco.
- O modelo relacional permite evidenciar claramente cardinalidades, dicionario de dados e diagrama ER.

## Ajustes No Modelo Relacional

Os ajustes relevantes do Tech Challenge foram registrados por migrations Flyway:

| Migration | Ajuste | Finalidade |
|---|---|---|
| `V8`/`V9` | `ordens_servico.numero` | Consulta externa por numero legivel, sem expor ID interno. |
| `V10` | `itens_os.estoque_reduzido` | Controle de baixa de estoque por item. |
| `V11` | `orcamentos.data_aprovacao` e `execucoes.mecanico_nome` | KPIs e auditoria operacional. |
| `V12` | `ordens_servico.atendente_nome` | Rastreabilidade da abertura da OS. |
| `V16` | `orcamento_decisao_cliente` | Aprovacao ou recusa externa por token opaco. |
| `V17` | `clientes.senha_hash` | Autenticacao externa por CPF e senha. |
| `V18` | `clientes.status_cliente` | Controle de cliente apto ou bloqueado para autenticacao externa. |

## Impactos

- A API principal e a Lambda Auth CPF + Senha compartilham o mesmo banco, com acesso controlado por rede e credenciais.
- As alteracoes de schema devem continuar sendo feitas por migration Flyway.
- O Terraform do banco permanece separado do Terraform de Kubernetes, conforme `RFC-005`.
- O diagrama ER, dicionario de dados e modelo relacional devem acompanhar as migrations efetivamente entregues.
- O monitoramento deve acompanhar conexoes, CPU, memoria, storage, latencia de consultas e erros de integracao.

## Riscos

- Custo continuo do RDS em ambiente academico se o teardown nao for executado.
- Pool de conexoes mal dimensionado pode afetar API e Lambda.
- Security groups incorretos podem bloquear API/Lambda ou expor acesso indevido.
- Divergencia entre H2 em testes rapidos e PostgreSQL real pode esconder diferencas de dialeto.
- Migrations sem revisao podem gerar incompatibilidade com dados existentes.

## Controles Aplicados

- RDS sem acesso publico.
- Storage criptografado.
- Credenciais mantidas em GitHub Environment Secrets.
- Acesso liberado apenas para workloads autorizados por security group.
- Flyway habilitado na aplicacao para versionar schema.
- Diagrama ER e dicionario de dados alinhados as migrations.
- Teardown operacional documentado para reduzir custo em ambiente academico.

## Relacao Com O Tech Challenge

Esta RFC cobre a decisao tecnica de banco de dados solicitada na documentacao arquitetural. Ela complementa as ADRs permanentes de PostgreSQL e PostgreSQL gerenciado, alem dos artefatos de modelagem relacional.

## Relacao Com Outros Documentos

- [`ADR-003`](../adr/ADR-003-postgresql.md): decisao original por PostgreSQL.
- [`ADR-017`](../adr/ADR-017-postgresql-gerenciado.md): decisao arquitetural permanente por PostgreSQL gerenciado.
- [`RFC-005`](./RFC-005-separacao-terraform-k8s-banco.md): separacao do Terraform de banco e Kubernetes.
- [`justificativa-postgresql.md`](../banco/justificativa-postgresql.md): justificativa formal do banco.
- [`modelo-relacional.md`](../banco/modelo-relacional.md): relacionamentos e ajustes do schema.
- [`diagrama-er.puml`](../banco/diagrama-er.puml): diagrama ER do schema entregue.
