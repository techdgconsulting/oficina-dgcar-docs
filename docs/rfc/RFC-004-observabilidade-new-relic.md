# RFC-004: Observabilidade com New Relic

**Status:** Aceito
**Data da decisão:** 2026-09-27
**Revisão documental:** 2026-10-15
**Contexto:** Tech Challenge — Monitoramento e observabilidade
**Escopo:** API no EKS, Kubernetes, indicadores de OS e disponibilidade pelo API Gateway; logs da Lambda no CloudWatch

## Contexto e decisão

Healthchecks isolados não explicam a duração das requisições, o consumo dos pods ou as falhas dos fluxos de OS. A solução utiliza New Relic para consolidar APM, telemetria Kubernetes, logs da API, indicadores de negócio, monitor externo e alertas.

A configuração atende homolog e prod com nomes e filtros por ambiente onde definidos nas consultas. Evidências de execução em homolog não comprovam automaticamente o estado de prod.

## Solução entregue

| Componente | implementação e escopo |
|---|---|
| APM da API | Java Agent na imagem Spring Boot, carregado por `JAVA_TOOL_OPTIONS`; transações, latência, throughput e erros HTTP |
| Logs da API | JSON no stdout, coletado pelo bundle Kubernetes; encaminhamento automático pelo Java Agent desabilitado |
| correlação | Header recebido ou UUID, MDC, resposta com `X-Correlation-Id`, atributo `correlationId` no APM e metadados `trace.id`/`span.id` quando disponíveis |
| Kubernetes | integrações do `nri-bundle`; pods Running/Ready, consumo e limites de CPU/memória, reinicializações |
| negócio | Eventos customizados de OS e snapshots operacionais e de duração, emitidos explicitamente pela API; instrumentos Micrometer também registrados |
| Disponibilidade externa | Monitor SIMPLE com GET no readiness pelo API Gateway a cada minuto, de US_EAST_1, validando SSL, ausência de redirecionamento e a string de status UP |
| Provisionamento | Terraform define dashboards, monitor e oito condições de alerta |
| HPA | CPU pelo Metrics Server; escala de pods validada em homolog no mesmo nó, conforme ADR-015 |
| Lambda Auth | Logs JSON e correlation ID no CloudWatch, com máscara de CPF; sem integração New Relic comprovada na configuração versionada |

## Dashboards e alertas

Os dashboards são `oficina-dgcar-<ambiente> - API e Kubernetes`, com 14 widgets, e `oficina-dgcar-<ambiente> - Negocio OS`, com 7 widgets.

O operacional apresenta estado dos pods, health externo, uptime, p95, throughput, erros HTTP, endpoints, CPU e memória com limites reais, restarts, falhas de processamento e logs correlacionados. Não contém grid de HPA ou card de pods desejados.

O de negócio apresenta OS em aberto, distribuição de status, tabela de OS com data de entrega, volume diário, produtividade por mecânico, média por status e falhas. As consultas usam eventos customizados e deduplicam snapshots; não somam diretamente counters Micrometer. `FALHA_PROCESSAMENTO` inclui rejeições de negócio HTTP 409/422, além de outras falhas instrumentadas.

A política `oficina-dgcar-<ambiente> - Observabilidade` contém API 5xx, API p95 alto, Health down, Pod reiniciando, Falha processamento OS, Falha notificacao, Falha pagamento e Health externo API. O alerta 5xx usa contagem, não taxa; o alerta de restart usa incremento do contador, sem exigir várias reinicializações. Notificação e pagamento não filtram `app_name` nas condições atuais e, portanto, não ficam isolados por ambiente quando compartilham a conta.

O Terraform não define destinatários externos. Incidentes do New Relic e entrega de notificações são responsabilidades distintas. O inventário completo, limites e procedimentos estão em [Dashboards, healthchecks e alertas](../observabilidade/dashboards-alertas.md).

## Limites do escopo comprovado

Não há métricas de negócio específicas de ViaCEP, alertas específicos de banco ou da autenticação Lambda, nem comprovação de APM ou ingestão dos logs da Lambda no New Relic. O monitor externo observa a resposta pelo API Gateway; isso não comprova instrumentação APM própria do Gateway.

A correlação por identificador permite localizar registros relacionados, mas não comprova um trace contínuo entre Gateway, Lambda, API e banco. A leitura e a devolução de headers estão implementadas nos componentes; propagação automática para integrações externas não é afirmada como funcionalidade entregue.

Readiness do container e readiness externo têm fontes distintas. A presença de probes de liveness no Kubernetes não constitui um widget ou alerta específico de liveness no New Relic.

## Validação e operação

A CI valida Terraform, manifests e testes de proteção de escopo. Os workflows de dashboards de homolog executam consultas pela NerdGraph antes de aplicar alterações, respeitando as condições de execução de cada validador. A validação operacional ao vivo compara pods e limites com Kubernetes, verifica o monitor externo e procura duas requisições a `/api-docs` com o mesmo correlation ID, dois traces distintos nos logs e duas transações APM.

O ensaio de HPA registra escala de 1 para 2 pods Ready e retorno a 1 na mesma EC2, com restauração da especificação original. Essa evidência é de homolog e não equivale a comprovar o máximo configurado de três pods. Os workflows específicos de homolog não são apresentados como validação automática de prod.

## Alternativas consideradas e histórico

A decisão de 27/09/2026 comparou New Relic, Prometheus com Grafana, CloudWatch e uso isolado do Actuator. New Relic foi escolhido pela reunião de APM, telemetria Kubernetes, consultas, dashboards e alertas. Prometheus/Grafana exigiam composição adicional para logs e traces; CloudWatch permaneceu como destino nativo dos logs da Lambda; Actuator fornece os endpoints de saúde, mas não substitui a plataforma de observabilidade.

A revisão de 15/10/2026 mantém essa escolha e delimita o inventário ao código, Terraform e evidências disponíveis. O escopo inicialmente discutido incluía métricas de ViaCEP e rastreamento entre todos os componentes; esses itens pertencem ao histórico da discussão, sem serem classificados como entregues ou como compromissos futuros.

## Referências

- [New Relic](../observabilidade/new-relic.md).
- [Logs estruturados e correlação](../observabilidade/logs-json-correlation-id.md).
- [métricas de negócio](../observabilidade/metricas-negocio.md).
- [ADR-015 — HPA](../adr/ADR-015-hpa-cluster-autoscaling.md).
- [ADR-016 — Logs](../adr/ADR-016-logs-estruturados-correlation-id.md).
