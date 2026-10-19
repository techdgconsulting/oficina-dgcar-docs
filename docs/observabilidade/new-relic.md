# New Relic

O New Relic reúne a telemetria da API Spring Boot, do Kubernetes e dos fluxos de ordens de serviço da Oficina DGCar. A plataforma permite acompanhar latência, throughput, erros, disponibilidade externa, pods ativos, CPU, memória, logs da API e indicadores de negócio.

## Origem da telemetria

Este documento cobre **homolog e prod**. Os nomes abaixo seguem a configuração por ambiente; a presença de dados deve ser verificada no ambiente consultado.

| Recurso | Homolog | Prod |
|---|---|---|
| Aplicação APM | `oficina-dgcar-api-homolog` | `oficina-dgcar-api-prod` |
| Cluster | `oficina-dgcar-homolog-eks` | `oficina-dgcar-prod-eks` |
| Dashboard operacional | `oficina-dgcar-homolog - API e Kubernetes` | `oficina-dgcar-prod - API e Kubernetes` |
| Dashboard de negócio | `oficina-dgcar-homolog - Negocio OS` | `oficina-dgcar-prod - Negocio OS` |
| Monitor externo | `oficina-dgcar-homolog - Health API` | `oficina-dgcar-prod - Health API` |
| Política de alertas | `oficina-dgcar-homolog - Observabilidade` | `oficina-dgcar-prod - Observabilidade` |

| Origem | Coleta | Informação |
|---|---|---|
| API Spring Boot | New Relic Java Agent | Transações APM, duração das requisições, erros e traces |
| Kubernetes | Integrações do chart Helm `nri-bundle` | Estado dos pods, reinicializações, consumo e limites de recursos |
| stdout JSON da API | Coletor `newrelic-logging` do Kubernetes | Logs estruturados com MDC, stacktrace e contexto do pod |
| Fluxos de OS | Eventos customizados enviados pela API | Criação, mudanças de status, duração por status e falhas |
| Readiness público | New Relic Synthetics | Disponibilidade pelo API Gateway e histórico de verificações |

O Java Agent está incluído na imagem da API e é carregado por `JAVA_TOOL_OPTIONS`, com `-javaagent:/app/newrelic/newrelic.jar`. A aplicação APM recebe o nome `oficina-dgcar-api-<ambiente>`, conforme a tabela acima.

O Terraform instala o `nri-bundle`, com as integrações de infraestrutura, metadados Kubernetes, kube-state-metrics e eventos do cluster. A integração `nri-prometheus` permanece desabilitada. Os indicadores de negócio utilizam eventos customizados; sua disponibilidade não depende de scraping dos contadores Micrometer.

## Logs JSON da API e correlação

O Logback escreve JSON no stdout da API, incluindo timestamp, nível, mensagem, logger, thread, ambiente, campos do MDC e stacktrace quando há exceção. O filtro HTTP registra `correlationId`, método, URI, status e duração. O identificador vem de um `X-Correlation-Id` válido, de `X-Request-Id` válido ou é gerado pela API, e retorna no header `X-Correlation-Id`.

O coletor lê os arquivos `/var/log/containers/oficina-api-*_oficina_oficina-api-*.log` e mantém os registros cujo campo `application` é `oficina-mecanica-dgcar`. Ele interpreta o JSON, preserva os campos da aplicação e acrescenta contexto de pod, container, namespace e cluster. A ingestão de logs está restrita à API.

O workflow de deploy fixa:

```text
NEW_RELIC_APPLICATION_LOGGING_FORWARDING_ENABLED=false
NEW_RELIC_APPLICATION_LOGGING_LOCAL_DECORATING_ENABLED=false
```

Os logs chegam pelo coletor Kubernetes, evitando o envio duplicado pelo Java Agent. A API inclui metadados de vínculo do agente, como `trace.id` e `span.id`, quando disponíveis, e adiciona `correlationId` à transação APM. Registros fora de uma transação podem não conter identificadores de trace.

## Eventos de negócio

Além dos instrumentos Micrometer, a API publica eventos explicitamente pela API do Java Agent. Os dashboards consultam principalmente:

| Evento | Uso |
|---|---|
| `OficinaOsEvent` | Eventos `OS_CRIADA`, `STATUS_ALTERADO`, `TEMPO_STATUS`, `FALHA_PROCESSAMENTO`, `FALHA_NOTIFICACAO` e `FALHA_PAGAMENTO` |
| `OficinaOsOperationalSnapshot` | Estado de cada OS, com status, cliente, veículo, mecânico, valor e datas do atendimento |
| `OficinaOsStatusDurationSnapshot` | Intervalos concluídos em cada status, usados no cálculo do tempo médio por status |

Esses eventos incluem `app_name` para identificar a aplicação e o ambiente. Os snapshots operacionais são emitidos na criação e nas mudanças de status, além da publicação periódica com atraso inicial de 30 segundos e intervalo de 60 segundos entre execuções. A consulta de estado utiliza o último snapshot de cada OS; contar todos os snapshots produziria uma quantidade incorreta de ordens.

A atualização dos gráficos depende da emissão, da ingestão no New Relic e da janela da consulta. Não há garantia de atualização instantânea após uma requisição.

## Dashboards, monitor externo e alertas

O repositório `oficina-dgcar-infra-k8s` provisiona esses recursos com o provider Terraform `newrelic`. Os dois dashboards seguem o padrão `<projeto>-<ambiente> - <nome>`:

- **API e Kubernetes**: saúde da API, pods Running/Ready, latência, throughput, erros, endpoints, recursos por pod com seus limites, reinicializações, falhas de processamento e logs correlacionados.
- **Negocio OS**: indicadores e consultas sobre ordens de serviço.

Os nomes completos dos dashboards de homolog e prod estão na tabela de recursos por ambiente.

O monitor `oficina-dgcar-<ambiente> - Health API` consulta `/actuator/health/readiness` pelo API Gateway do respectivo ambiente a cada minuto. Executa GET, valida o certificado SSL e procura `"status":"UP"` na resposta. O uptime representa o percentual de verificações bem-sucedidas desse monitor.

A política `oficina-dgcar-<ambiente> - Observabilidade` reúne condições para erros HTTP 5xx, latência p95, health da aplicação, reinicializações de pods, falhas de processamento de OS, notificações, pagamentos e disponibilidade externa. Os limites e as janelas de avaliação estão definidos no Terraform. A configuração analisada não provisiona destinos externos de notificação; a abertura de um incidente não implica envio de e-mail.

## Variáveis e secrets

As variáveis e os secrets são configurados nos ambientes `homolog` e `prod` do GitHub Actions, conforme o destino do deploy. Os valores das credenciais não devem constar na documentação ou em arquivos versionados.

### API

| Nome | Origem e finalidade |
|---|---|
| `NEW_RELIC_LICENSE_KEY` | Secret para ingestão da telemetria do agente, injetado no Secret Kubernetes |
| `NEW_RELIC_APP_NAME` | Variável opcional; padrão do deploy: `oficina-dgcar-api-<ambiente>` |
| `NEW_RELIC_ENVIRONMENT` | Variável opcional; por padrão, acompanha o ambiente do deploy |
| `JAVA_TOOL_OPTIONS` | Variável opcional; o padrão carrega o Java Agent incluído na imagem |
| `NEW_RELIC_LOG_FILE_NAME` | Variável opcional; padrão `STDOUT`, referente aos logs internos do agente |

Os parâmetros de application logging apresentados acima são fixados como `false` pelo deploy. `NEW_RELIC_LOG_FILE_NAME` não habilita o encaminhamento dos logs da aplicação.

### Infraestrutura

| GitHub Actions | Variável Terraform | Finalidade |
|---|---|---|
| Secret `NEW_RELIC_LICENSE_KEY` | `new_relic_license_key` | Ingestão pelo bundle Kubernetes |
| Secret `NEW_RELIC_API_KEY` | `new_relic_api_key` | User API Key para provisionamento e consultas NerdGraph |
| Secret ou variável `NEW_RELIC_ACCOUNT_ID` | `new_relic_account_id` | Conta dos dashboards, monitor e alertas |

O workflow fornece esses valores ao Terraform com o prefixo `TF_VAR_`. A User API Key é uma credencial de gerenciamento e consulta; não é a license key de ingestão e não é necessária no runtime da API.

As opções do Terraform incluem `enable_new_relic_kubernetes`, `enable_new_relic_observability`, `new_relic_region`, `new_relic_namespace`, `new_relic_release_name`, `new_relic_chart_version` e `new_relic_alert_p95_threshold_seconds`. A criação dos recursos de observabilidade depende da opção habilitada, do account ID e da API key preenchidos. Os padrões estão em `terraform/variables.tf` no repositório de infraestrutura.

## Consulta e verificação

1. No APM, selecione `oficina-dgcar-api-<ambiente>` e confira transações recentes, duração e erros após executar requisições à API do ambiente escolhido.
2. No Kubernetes, confira os pods de `oficina-dgcar-<ambiente>-eks` e compare estado, consumo e limites com o cluster. Confira o contexto com `kubectl config current-context`; no contexto correspondente ao ambiente, use `kubectl get pods -n oficina` para a aplicação e `kubectl get pods -n newrelic` para os componentes de coleta.
3. No Synthetics, confira os resultados de `oficina-dgcar-<ambiente> - Health API`. Uma resposta local do pod não substitui a verificação pelo API Gateway.
4. Abra os dois dashboards e selecione uma janela que inclua a execução da massa de dados. Ausência de eventos na janela não comprova ausência de ordens no banco.
5. Em Logs, procure o `correlationId` de uma chamada autenticada e confira os campos JSON, o pod e o vínculo com a transação APM.

Nas consultas NRQL abaixo, substitua `<ambiente>` por `homolog` ou `prod` antes de executar. Utilize o mesmo ambiente nos filtros de aplicação, cluster e logs.

```sql
FROM Transaction
SELECT count(*), percentile(duration * 1000, 95)
WHERE appName = 'oficina-dgcar-api-<ambiente>'
SINCE 30 minutes ago
```

```sql
FROM Log
SELECT timestamp, message, correlationId, `trace.id`, pod_name
WHERE cluster_name = 'oficina-dgcar-<ambiente>-eks'
  AND namespace_name = 'oficina'
  AND container_name = 'oficina-api'
  AND environment = '<ambiente>'
  AND correlationId = 'validacao-observabilidade'
SINCE 30 minutes ago LIMIT 100
```

```sql
FROM OficinaOsEvent
SELECT count(*)
WHERE app_name = 'oficina-dgcar-api-<ambiente>'
FACET evento
SINCE 30 minutes ago
```

```sql
FROM OficinaOsOperationalSnapshot
SELECT uniqueCount(numero_os)
WHERE app_name = 'oficina-dgcar-api-<ambiente>'
  AND snapshot_version = 2
SINCE 30 minutes ago
```

Para conferir a correlação, envie duas requisições autenticadas a `GET /api/ordens-servico` com o mesmo `X-Correlation-Id`. Localize os dois registros `http_request_completed` e suas transações APM. O mesmo `correlationId` permite agrupá-los, mas não significa que as duas requisições compartilham um único trace. Confira também se cada requisição possui apenas um registro de conclusão ingerido.

O workflow **Atualizar Dashboard Operacional Homolog**, no repositório de infraestrutura, é específico de **homolog** e oferece execução com `phase=verify` e `redeploy_api=false`. Nessa modalidade, valida o plano e as consultas via NerdGraph sem aplicar o Terraform. A verificação ao vivo compara pods e limites com o Kubernetes, verifica o monitor externo e executa duas chamadas autenticadas para conferir logs, transações APM e ausência de duplicação. Esse workflow não valida prod; para prod, os procedimentos de consulta acima utilizam os recursos e o contexto de produção.

Se não houver dados, confira a janela consultada, o nome da aplicação e o ambiente, a presença da license key, o carregamento do agente e a saúde do coletor, sem expor os secrets.

## Logs da Lambda Auth

A Lambda Auth emite JSON por `console.log` e `console.error`, com campos como timestamp, nível, mensagem, serviço e `correlationId`. O Terraform provisiona o log group `/aws/lambda/<projeto>-<ambiente>-auth-cpf`, com retenção definida por `log_retention_days`, e a função possui permissão para escrever no CloudWatch Logs.

Emitir JSON no CloudWatch não significa ingerir esses registros no New Relic. A configuração versionada analisada da Lambda não inclui extensão ou agente New Relic, assinatura do log group ou encaminhador para essa plataforma. O coletor Kubernetes descrito neste documento atende à API e não coleta logs da Lambda. Os logs da Lambda são consultados no CloudWatch; não há comprovação, nesses repositórios, de sua ingestão ou instrumentação APM no New Relic.

## Referências da implementação

Os links abaixo apontam para a branch `homolog` usada na análise da configuração compartilhada pelos ambientes. Eles não constituem evidência de execução ou de telemetria recebida em prod.

- [Coleta Kubernetes e Helm](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/terraform/main.tf) e [filtros de logs](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/terraform/logging-filters.conf).
- [Dashboard operacional e monitor externo](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/terraform/operational.tf) e [indicadores de negócio e alertas](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/terraform/observability.tf).
- [Deploy e configuração do Java Agent](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/.github/workflows/app-cd.yml) e [configuração JSON do Logback](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/src/main/resources/logback-spring.xml).
- [Emissão de logs da Lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda/blob/homolog/src/observability.js).
