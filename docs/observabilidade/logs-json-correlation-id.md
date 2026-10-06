# Logs JSON E Correlation ID

A aplicacao deve produzir logs estruturados em JSON e propagar um identificador de correlacao por requisicao.

## Objetivos

- Rastrear uma chamada do API Gateway ate a API.
- Correlacionar erros com traces e metricas.
- Facilitar busca em New Relic.
- Evidenciar comportamento operacional durante a apresentacao.

## Campos Recomendados

```json
{
  "timestamp": "2026-10-06T10:00:00Z",
  "level": "INFO",
  "service": "oficina-dgcar-api",
  "correlationId": "uuid",
  "traceId": "trace-id",
  "method": "GET",
  "path": "/api/ordens-servico/numero/OS-2026-00001",
  "status": 200,
  "durationMs": 45
}
```

## Propagacao

- Se o cliente enviar `X-Correlation-Id`, o valor e reaproveitado.
- Se nao houver header, a API gera um novo UUID.
- O valor deve ser devolvido na resposta e registrado nos logs.
