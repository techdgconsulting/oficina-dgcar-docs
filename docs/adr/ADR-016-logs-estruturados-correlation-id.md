# ADR-016: Logs Estruturados E Correlation-Id

**Status:** Aceito  
**Data:** 2026-09-27  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

O novo desafio exige logs estruturados em JSON, correlacao entre requisicoes, dashboards e visibilidade de falhas em tempo real. A arquitetura alvo inclui API Gateway, Lambda e aplicacao no EKS, portanto uma requisicao pode atravessar multiplos componentes antes de concluir.

## Decisao

Padronizar logs estruturados em JSON e propagar `correlationId` entre API Gateway, Lambda e aplicacao principal.

## Padrao Proposto

Cada log operacional relevante deve conter:

- `timestamp`;
- `level`;
- `service`;
- `environment`;
- `correlationId`;
- `traceId`, quando disponivel;
- `event`;
- identificadores tecnicos nao sensiveis;
- mensagem sanitizada.

Exemplo:

```json
{
  "timestamp": "2026-09-27T10:00:00-03:00",
  "level": "INFO",
  "service": "oficina-api",
  "environment": "homolog",
  "correlationId": "req-123",
  "event": "ORDEM_SERVICO_CRIADA",
  "ordemServicoId": 100
}
```

## Propagacao

- API Gateway deve receber ou gerar o correlation-id.
- Lambda deve registrar e repassar o correlation-id.
- Aplicacao principal deve ler o header de correlacao e inclui-lo no contexto de log.
- Chamadas para integracoes externas devem propagar o correlation-id quando possivel.

## Justificativa

- Facilita diagnostico de falhas.
- Permite correlacionar uma mesma jornada entre Gateway, Lambda, aplicacao e banco.
- Atende requisito de logs estruturados e correlacao.
- Melhora a qualidade dos dashboards e alertas no New Relic.

## Dados Que Nao Devem Ser Logados

- CPF completo.
- Senhas.
- JWT.
- Segredos de ambiente.
- Credenciais de banco, SMTP ou AWS.
- Payload completo de requisicoes sensiveis.

## Consequencias Positivas

- Observabilidade mais forte.
- Melhor investigacao de incidentes.
- Menor tempo para identificar gargalos.
- Evidencia clara para a demonstracao do Tech Challenge.

## Consequencias Negativas

- Exige alteracoes futuras na aplicacao e Lambda.
- Pode aumentar volume de logs.
- Exige cuidado para nao registrar dados sensiveis.

## Relacao Com Outros Documentos

- `RFC-004`: observabilidade com New Relic.
- `ADR-013`: API Gateway como entrada oficial.
- `ADR-014`: Lambda Auth CPF.
