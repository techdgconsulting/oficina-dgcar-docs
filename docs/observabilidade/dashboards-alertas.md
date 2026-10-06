# Dashboards E Alertas

Dashboards definidos para demonstrar a operacao em tempo real.

## Dashboards

| Dashboard | Conteudo |
|---|---|
| API | Latencia, throughput, 4xx, 5xx e endpoints mais chamados |
| Kubernetes | CPU, memoria, pods, restarts e HPA |
| Ordens de servico | Volume diario, status e tempo medio por fase |
| Integracoes | Falhas de e-mail, pagamento, ViaCEP e Lambda Auth |

## Alertas

| Alerta | Condicao |
|---|---|
| API indisponivel | Healthcheck falhando |
| Erro 5xx elevado | Taxa acima do limite definido |
| Pods reiniciando | Restarts acima do esperado |
| HPA saturado | Replicas no maximo por tempo prolongado |
| Falha de processamento de OS | Erros em fluxos de ordem de servico |
| Lambda Auth com erro | Aumento de `ERRO_INTERNO` ou falha de banco |
