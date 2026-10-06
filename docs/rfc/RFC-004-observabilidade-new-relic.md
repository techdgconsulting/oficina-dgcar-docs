# RFC-004: Observabilidade Com New Relic

**Status:** Proposto  
**Data:** 2026-09-27  
**Contexto:** Tech Challenge - Monitoramento e Observabilidade  
**Escopo:** Aplicacao, Kubernetes, API Gateway e Lambda

## Contexto

O projeto atual possui Spring Boot Actuator com health checks, readiness e liveness. A nova fase exige visibilidade total sobre funcionamento do sistema, incluindo latencia, consumo de recursos, uptime, alertas, logs estruturados, correlation-id e dashboards de negocio.

## Problema

Health checks isolados nao sao suficientes para detectar gargalos, falhas de integracao, aumento de erro, degradacao de latencia ou problemas no processamento de ordens de servico. A operacao precisa de telemetria consolidada.

## Decisao Proposta

Usar New Relic como plataforma de observabilidade da arquitetura alvo.

## Alternativas Consideradas

| Opcao | Pontos fortes | Limitacoes |
|---|---|---|
| New Relic | APM, logs, dashboards, alertas, Kubernetes integration e traces em uma plataforma | Exige conta, chaves e configuracao de agentes |
| Prometheus + Grafana | Solucao aberta e poderosa para metricas | Maior esforco operacional para logs, traces e alertas integrados |
| CloudWatch | Integracao nativa AWS | Dashboards e APM podem exigir mais composicao manual |
| Apenas Actuator | Simples e ja existente | Nao atende dashboards, alertas e rastreabilidade completa |

## Itens A Monitorar

- Latencia das APIs por endpoint.
- Erros HTTP 4xx e 5xx.
- Consumo de CPU e memoria dos pods Kubernetes.
- Restarts de pods.
- Status de readiness/liveness.
- Uptime da API.
- Falhas em processamento de ordens de servico.
- Falhas em integracoes externas como SMTP, ViaCEP e gateway de pagamento.
- Logs estruturados em JSON.
- Correlation-id por requisicao.
- Traces entre API Gateway, Lambda e aplicacao.

## Dashboards Propostos

| Dashboard | Indicadores |
|---|---|
| Operacao da API | Latencia, throughput, erros, endpoints mais chamados |
| Kubernetes | CPU, memoria, replicas, restarts, HPA |
| Ordens de Servico | Volume diario de OS, OS por status, tempo medio por status |
| Integracoes | Falhas em SMTP, ViaCEP, pagamento e autenticacao |
| Autenticacao CPF | Tentativas, sucesso, falha, latencia da Lambda |

## Alertas Propostos

- API indisponivel.
- Taxa de erro 5xx acima de limite.
- Latencia p95 acima de limite.
- Pod reiniciando repetidamente.
- HPA no maximo por periodo prolongado.
- Falha recorrente no processamento de ordens de servico.
- Falha recorrente na Lambda Auth CPF + Senha.
- Banco com conexoes proximas do limite.

## Logs Estruturados E Correlation-Id

Os logs devem ser emitidos em JSON com campos padronizados, por exemplo:

```json
{
  "timestamp": "2026-09-27T10:00:00-03:00",
  "level": "INFO",
  "service": "oficina-api",
  "correlationId": "abc-123",
  "event": "ORDEM_SERVICO_CRIADA",
  "ordemServicoId": 10
}
```

O `correlationId` deve ser recebido do API Gateway quando existir, propagado para Lambda e aplicacao, e gerado na borda quando ausente.

## Dados Sensiveis Que Nao Devem Ir Para Logs

- CPF completo.
- Senhas.
- JWT.
- Segredos de SMTP, banco ou AWS.
- Dados de cartao ou pagamento sensivel.
- Corpo completo de requisicoes autenticadas.

## Relacao Com O Tech Challenge

Esta proposta cobre latencia, recursos Kubernetes, healthchecks, uptime, alertas, logs estruturados, correlation-id, dashboards de OS e falhas em integracoes.
