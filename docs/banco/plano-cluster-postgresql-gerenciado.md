# Plano Do PostgreSQL Gerenciado

O banco gerenciado foi definido como Amazon RDS PostgreSQL, provisionado por Terraform no repositorio `oficina-dgcar-infra-db`.

## Ambientes

| Ambiente | Uso | Configuracao |
|---|---|---|
| `homolog` | Demonstracao e validacao academica | Instancia economica, backup reduzido, acesso privado |
| `prod` | Ambiente produtivo conceitual | Backup automatico, protecao contra exclusao e sizing parametrizado |

## Seguranca

- RDS sem acesso publico.
- Acesso restrito por security groups.
- Credenciais armazenadas em GitHub Environment Secrets.
- Storage criptografado.
- Senhas de cliente armazenadas apenas como hash bcrypt.

## Backup

- Homologacao usa retencao reduzida por restricoes de laboratorio.
- Producao usa retencao automatica parametrizada.
- Remocoes controladas preservam snapshot final quando habilitado.

## Conectividade

Consumidores autorizados:

- aplicacao Spring Boot no EKS;
- Lambda Auth CPF + Senha em VPC;
- pipelines apenas durante operacoes controladas.

## Terraform

Responsabilidades do repo `oficina-dgcar-infra-db`:

- RDS PostgreSQL;
- subnet group;
- security group do banco;
- parameter group;
- outputs para API, Lambda e infra Kubernetes;
- state remoto independente.
