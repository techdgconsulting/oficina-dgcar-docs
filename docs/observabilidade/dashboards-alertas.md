# Dashboards, healthchecks e alertas

O Terraform do repositório `oficina-dgcar-infra-k8s` define dois dashboards e oito condições de alerta para cada ambiente configurado. Este documento cobre **homolog e prod**; os workflows específicos de homolog são identificados nas seções de operação.

| Recurso | Homolog | Prod |
|---|---|---|
| Dashboard operacional | `oficina-dgcar-homolog - API e Kubernetes` | `oficina-dgcar-prod - API e Kubernetes` |
| Dashboard de negócio | `oficina-dgcar-homolog - Negocio OS` | `oficina-dgcar-prod - Negocio OS` |
| Monitor externo | `oficina-dgcar-homolog - Health API` | `oficina-dgcar-prod - Health API` |
| Política de alertas | `oficina-dgcar-homolog - Observabilidade` | `oficina-dgcar-prod - Observabilidade` |

A configuração dos recursos não comprova, por si só, a chegada de telemetria em ambos os ambientes. As consultas e verificações devem usar a conta, aplicação e cluster correspondentes ao ambiente consultado.

## Dashboard API e Kubernetes: 14 widgets

O inventário abaixo corresponde a `terraform/operational.tf`. Os filtros de aplicação usam `appName` em `Transaction` e `app_name` em `OficinaOsEvent`, com valor `oficina-dgcar-api-<ambiente>`. As amostras Kubernetes usam o cluster `oficina-dgcar-<ambiente>-eks` e o namespace `oficina`.

| Widget | Finalidade e origem | Unidade e cálculo |
|---|---|---|
| Pods ativos (Running e Ready - ultimos 3 min) | Estado atual da API; `K8sPodSample`, pods `oficina-api-%` | Pods. Obtém `latest(status)` e `latest(isReady)` por pod e conta os que têm estado `Running` e readiness numérico `1` |
| Healthcheck externo (ultimo resultado - 5 min) | Resultado recente do monitor; `SyntheticCheck` | Estado textual. `latest(result)` para o monitor do ambiente |
| Uptime no periodo (%) | Disponibilidade observada pelo monitor; `SyntheticCheck` | Percentual de amostras com `result = 'SUCCESS'`; consulta com `SINCE 1 day ago` |
| Falhas no processamento de OS | Ocorrências nos fluxos de OS; `OficinaOsEvent` | Contagem de `FALHA_PROCESSAMENTO`, com `SINCE 1 day ago` |
| Latencia p95 (ms) | Latência da API; `Transaction` | `percentile(duration * 1000, 95)`, em milissegundos, em série temporal |
| Throughput por minuto | Volume de requisições; `Transaction` | `rate(count(*), 1 minute)`, em requisições por minuto, em série temporal |
| Erros HTTP por status | Distribuição de respostas de erro; `Transaction` | Contagem por `http.statusCode`, filtrando `numeric(http.statusCode) >= 400` |
| Endpoints mais lentos | Comparação das transações; `Transaction` | p95 e média de `duration * 1000` em ms, mais contagem de requisições; agrupamento por `name`, limite de 20 grupos |
| CPU por pod - consumo e limite (cores) | Uso e limite do container `oficina-api`; `K8sContainerSample` | `average(cpuUsedCores)` e `latest(cpuLimitCores)`, em cores, por pod e intervalo da série |
| Memoria por pod - consumo e limite (MiB) | Working set e limite do container `oficina-api`; `K8sContainerSample` | `average(memoryWorkingSetBytes) / 1048576` e `latest(memoryLimitBytes) / 1048576`, em MiB, por pod e intervalo |
| Restarts por pod | Contador de reinicializações; `K8sContainerSample`, container `oficina-api` | `max(restartCount)` por pod, limite de 20 grupos. É o maior contador observado, não o incremento de reinicializações no período |
| Falhas de OS ao longo do tempo | Evolução das falhas; `OficinaOsEvent` | Contagem de `FALHA_PROCESSAMENTO` em série temporal |
| Falhas de OS por fluxo e erro | Identificação do fluxo e da classe de erro; `OficinaOsEvent` | Contagem de `FALHA_PROCESSAMENTO`, agrupada por `fluxo` e `erro`, limite de 30 grupos |
| Logs estruturados e correlacao de requisicoes | Inspeção dos logs da API; `Log` | Registros com data/hora, nível, mensagem, método, rota, HTTP, duração em ms, `correlationId`, `trace.id` e pod; `SINCE 30 minutes ago`, limite de 100 registros |

Os widgets de pods ativos e health externo usam `ignore_time_range = true`: suas janelas ficam fixas em **3 minutos** e **5 minutos**, respectivamente. Isso evita que a seleção de um período histórico conte pods de rollouts anteriores como estado atual. Ausência de amostra não equivale a confirmação de saúde.

Os demais widgets acompanham o período efetivo do dashboard; a tabela registra os `SINCE` explícitos das consultas. As consultas sem `SINCE` não fixam uma janela própria no Terraform. O uptime mede resultados recebidos do monitor, não disponibilidade anterior à sua criação nem intervalos sem verificações.

As linhas de limite de CPU e memória vêm da telemetria do próprio container. Não usam valores fixos, requests ou capacidade total do nó. Se o limite estiver ausente na telemetria, a linha pode ficar ausente; isso não representa limite zero.

O dashboard **não contém grid de HPA nem card de pods desejados**. `FALHA_PROCESSAMENTO` inclui rejeições de negócio dos fluxos instrumentados, como HTTP 409 e 422; não representa exclusivamente erros internos 500.

### Filtros dos logs e recursos

| Variável | Aplicação |
|---|---|
| `pod` | CPU, memória, restarts e logs |
| `level` | Nível dos logs |
| `correlation` | `correlationId` dos logs |

As três variáveis usam `%` como padrão para todos os valores e comparação `LIKE`. O filtro de correlação aceita todos os registros quando está em `%`, inclusive os que não possuem `correlationId`.

A consulta de logs restringe `cluster_name`, `namespace_name = 'oficina'`, `container_name = 'oficina-api'` e `environment`. Ela apresenta campos do JSON coletado no stdout e o contexto Kubernetes. Para investigar, informe o `correlationId` devolvido pela API, confira o pod e abra o trace quando disponível. O filtro `correlation` não modifica os widgets APM. A pesquisa por `trace.id`, assim como a inspeção de `span.id` ou `stacktrace`, é feita na consulta ou na visualização completa de Logs; esses dois últimos campos não são colunas do widget.

## Dashboard Negocio OS: 7 widgets

O inventário corresponde a `terraform/observability.tf`. Os snapshots operacionais são filtrados por `app_name` do ambiente e `snapshot_version = 2`. As consultas de duração e de ocorrências filtram por `app_name`, sem exigir um campo de versão.

| Widget | Finalidade e origem | Unidade e regra de cálculo |
|---|---|---|
| Total de OS em aberto | Ordens ainda abertas; `OficinaOsOperationalSnapshot` | OS. Último estado por `numero_os`, excluindo `ENTREGUE` e `CANCELADA`; snapshots dos últimos 30 minutos |
| Status das OS | Distribuição do estado conhecido; `OficinaOsOperationalSnapshot` | OS por status. Último estado por ordem, seguido de contagem por status; últimos 30 minutos |
| Ordens de servico | Consulta das ordens; `OficinaOsOperationalSnapshot` | Uma linha por OS, com Cliente, Veiculo, Placa, Mecanico, Status, Data de entrega e Valor. Exclui canceladas, limite de 100 OS, últimos 30 minutos. Valor corresponde a `valor_total`, sem conversão monetária na consulta |
| Volume diario de ordens de servico | Criações por dia; `OficinaOsOperationalSnapshot` | `uniqueCount(numero_os)` por `data_criacao_dia`, com `dias_desde_criacao >= 0` e `< 14`. Usa snapshots dos últimos 30 minutos e até 14 grupos de dias |
| Produtividade por mecanico | Ordens finalizadas atribuídas a mecânicos; `OficinaOsOperationalSnapshot` | OS por nome do mecânico. Último status em `FINALIZADA`, `AGUARDANDO_RETIRADA` ou `ENTREGUE`, excluindo mecânicos `NAO_ATRIBUIDO` e `NAO_INFORMADO`; data de finalização dentro do período |
| Tempo medio de execucao por status | Duração dos intervalos encerrados; `OficinaOsStatusDurationSnapshot` | Minutos. Última duração por OS/status/início, depois `average(tempo_ms) / 60000`, para intervalos encerrados no período em `EM_DIAGNOSTICO`, `EM_EXECUCAO` e `FINALIZADA` |
| Erros e falhas nas integracoes | Ocorrências instrumentadas; `OficinaOsEvent` | Contagem por `evento` e `erro` de `FALHA_PROCESSAMENTO`, `FALHA_NOTIFICACAO` e `FALHA_PAGAMENTO` |

Produtividade, média por status e falhas usam `SINCE 1 day ago WITH TIMEZONE 'America/Sao_Paulo'`. Nas duas primeiras, o início do período é inclusivo e o fim exclusivo. A produtividade usa a data de finalização; a média usa o fim do intervalo. `FINALIZADA` mede da finalização até o pagamento aprovado. A data de entrega aparece somente quando a OS está entregue e possui entrega registrada.

`latest()` e `uniqueCount()` evitam que as republicações periódicas dos snapshots sejam interpretadas como novas OS ou novos intervalos. As regras completas, inclusive conversão de datas e cálculo dos limites do período, estão em [Métricas de negócio](metricas-negocio.md).

## Monitor externo e healthchecks

O recurso `newrelic_synthetics_monitor.api_health` é do tipo `SIMPLE`, está habilitado e executa **a cada minuto**, a partir da localização pública **US_EAST_1**. A URL é formada pelo endpoint do API Gateway do ambiente e `/actuator/health/readiness`.

A configuração usa GET (`bypass_head_request = true`), verifica o certificado SSL, trata redirecionamentos como falha e exige a string `"status":"UP"` no corpo. O resultado `SUCCESS` depende da verificação HTTP do monitor e dessas validações. O Terraform não define uma lista própria de códigos HTTP aceitos.

Esse monitor verifica o caminho público pelo API Gateway. O estado Ready dos containers é outra fonte: vem das amostras Kubernetes e usa valor numérico `1` para pronto e `0` para não pronto. Um container pronto não comprova, sozinho, a disponibilidade de todo o caminho externo.

## Oito condições de alerta

As condições pertencem à política `oficina-dgcar-<ambiente> - Observabilidade`, com `incident_preference = PER_CONDITION`. Todas estão habilitadas, usam limite crítico estático com operador `above` e têm `violation_time_limit_seconds = 3600`.

Na tabela, aplicação significa `oficina-dgcar-api-<ambiente>`; cluster significa `oficina-dgcar-<ambiente>-eks`, com namespace `oficina`.

| Condição | Fonte, filtro e cálculo | Limite crítico | Duração e ocorrência | Ausência de sinal configurada |
|---|---|---|---|---|
| API 5xx | `Transaction`: `appName` da aplicação e `http.statusCode >= 500`; `count(*)` | Maior que 0 | 300 s; `AT_LEAST_ONCE` | Sem configuração explícita de expiração ou preenchimento |
| API p95 alto | `Transaction`: `appName` da aplicação; `percentile(duration, 95)` | Maior que `new_relic_alert_p95_threshold_seconds`, padrão 2 segundos | 300 s; `ALL` | Sem configuração explícita |
| Health down | `K8sContainerSample`: cluster/namespace, `containerName = 'oficina-api'`, `isReady = 0`; `count(*)` | Maior que 0 | 300 s; `AT_LEAST_ONCE` | Sem configuração explícita |
| Pod reiniciando | `K8sContainerSample`: cluster/namespace; `sum(restartCountDelta)` | Maior que 0 | 300 s; `AT_LEAST_ONCE` | Sem configuração explícita |
| Falha processamento OS | `OficinaOsEvent`: `app_name` da aplicação e `evento = 'FALHA_PROCESSAMENTO'`; `count(*)` | Maior que 0 | 300 s; `AT_LEAST_ONCE` | Preenchimento estático com 0; sem expiração de sinal explícita |
| Falha notificacao | `OficinaOsEvent`: somente `evento = 'FALHA_NOTIFICACAO'`; `count(*)` | Maior que 0 | 300 s; `AT_LEAST_ONCE` | Sem configuração explícita |
| Falha pagamento | `OficinaOsEvent`: somente `evento = 'FALHA_PAGAMENTO'`; `count(*)` | Maior que 0 | 300 s; `AT_LEAST_ONCE` | Sem configuração explícita |
| Health externo API | `SyntheticCheck`: monitor do ambiente; contagem filtrada por `result = 'FAILED'` | Maior que 0 | 120 s; `ALL` | Expiração após 180 s abre violação; não fecha violações existentes por expiração |

`AT_LEAST_ONCE` exige que o limite seja ultrapassado ao menos uma vez no período de avaliação. `ALL` exige a condição ao longo de toda a duração configurada. A duração não garante abertura ou entrega de notificação exatamente nesse tempo: ingestão, agregação e atraso de avaliação também participam.

A condição de processamento usa agregação `cadence`, janela de 60 segundos, atraso de 60 segundos e preenchimento de lacunas com zero. Esse preenchimento permite recuperação quando deixam de ocorrer falhas; não é um alerta de perda de telemetria.

O health externo usa `event_flow`, janela de 60 segundos e atraso de 60 segundos. A condição crítica corresponde a duas janelas consecutivas de um minuto com falha. Separadamente, configura `expiration_duration = 180`, `open_violation_on_expiration = true` e `close_violations_on_expiration = false` para perda de sinal.

Os alertas de notificação e pagamento não filtram `app_name`; quando homolog e prod enviam dados à mesma conta, essas condições não isolam os eventos por ambiente. O alerta de restarts também é mais amplo que o widget: filtra cluster e namespace, sem restringir ao container `oficina-api`.

### Incidentes e notificações

As condições abrem incidentes no New Relic conforme suas regras. O Terraform analisado não provisiona destinatários, canais ou workflows de envio externo. Portanto, abertura de incidente não equivale a entrega de e-mail ou mensagem a uma pessoa.

## Workflows e validação

### Atualizar Dashboard Operacional Homolog

O arquivo `operational-homolog.yml` opera na branch e no ambiente `homolog`. Ele inicializa o state existente, executa `terraform fmt -check` e `terraform validate`, conecta ao cluster e gera um plano salvo com escopo direcionado.

| Modalidade de manutenção | Escopo e execução |
|---|---|
| `dashboard` | Padrão nos pushes dos caminhos monitorados. Planeja e aplica somente `newrelic_one_dashboard.operational` e valida as consultas antes do apply |
| `deploy` | Planeja o dashboard operacional, monitor externo, condições `external_health`, `os_processing_failure` e `health_down`, além de `helm_release.new_relic_kubernetes`; aplica o plano, aguarda o coletor e executa a verificação ao vivo |
| `verify` | Gera e valida o plano do escopo operacional, aguarda o coletor e executa a verificação ao vivo, sem `terraform apply` |

O validador `validate-operational.py plan` rejeita mudanças fora da lista permitida e ações de exclusão. Ele exige 14 consultas no dashboard, substitui as variáveis de filtro por `%` e executa cada consulta pela API NerdGraph antes do apply. O dashboard de negócio não pertence ao escopo operacional. Executar uma consulta sem erro comprova que ela foi aceita, mas não garante que existam amostras para todos os indicadores.

Na modalidade `deploy`, `redeploy_api=true` guarda a quantidade de réplicas, escala a API para zero para liberar espaço aos hooks do Helm, limpa os jobs de hook indicados no workflow e restaura a quantidade anterior ao final, inclusive pelo caminho de recuperação de falhas. Essa opção causa indisponibilidade temporária e não é usada em uma simples atualização de layout.

A verificação `live` implementada:

1. Compara a quantidade de pods Running/Ready no Kubernetes com o indicador de três minutos do New Relic.
2. Compara CPU e memória dos limites recebidos na telemetria com `resources.limits` dos containers ativos.
3. Confere no ConfigMap que o encaminhamento de logs pelo agente Java está desabilitado.
4. Aguarda um resultado externo `SUCCESS` com timestamp nos últimos cinco minutos.
5. Faz dois GETs a `/api-docs` pelo LoadBalancer do Service, com o mesmo `X-Correlation-Id`, e verifica o header devolvido. Essas chamadas não criam massa de negócio nem utilizam o API Gateway; o monitor externo é a verificação separada desse caminho.
6. Aguarda exatamente dois logs `http_request_completed`, dois `trace.id` distintos e os campos estruturados esperados, incluindo pod, método, rota, status e duração.
7. Aguarda duas transações APM com o mesmo `correlationId`. A validação relaciona logs e APM pelo identificador; não compara individualmente o `trace.id` de cada log com o de cada transação.

As verificações com espera repetem consultas a cada 15 segundos, com timeout padrão de 240 segundos. O workflow publica o link do dashboard no resumo. Os filtros do script de validação ao vivo estão fixados em homolog; essa execução não comprova telemetria de prod.

### Atualizar Dashboard Negocio Homolog

O workflow `.github/workflows/dashboard-homolog.yml` executa automaticamente por push na branch `homolog` quando há alterações em `terraform/observability.tf`, em qualquer arquivo de `scripts/observability/**` ou no próprio workflow. Nesse acionamento, segue o fluxo de atualização do dashboard de negócio (`business`). O filtro de scripts abrange toda a pasta de observabilidade, incluindo scripts usados pelo dashboard operacional.

Também permite execução manual por `workflow_dispatch`, com o input `scope` definido como `business` por padrão ou `inspect` para consulta em modo de leitura. O apply exige a branch `homolog`; `inspect` também pode ser acionado a partir de outra referência, mas consulta o ambiente `homolog`.

O arquivo `dashboard-homolog.yml` oferece os escopos `business` e `inspect`. Em `business`, inicializa o state, valida o Terraform e planeja somente `newrelic_one_dashboard.business`. O script `validate-business-dashboard.py` rejeita outras mudanças e exclusões antes do apply.

Quando há alteração no dashboard, o script executa suas consultas via NerdGraph, confere as colunas da tabela, verifica os intervalos de sete OS da massa histórica e compara produtividade com os dados consultados na API, em períodos de um e 14 dias. Também recalcula as médias a partir dos intervalos únicos. Essas verificações dependem da massa e do acesso à API configurados em homolog. Se o dashboard não muda no plano, o script dispensa a execução das consultas e a validação histórica.

O escopo `inspect` conecta ao cluster e executa `inspect-operational.py` em modo de leitura, sem planejar ou aplicar o dashboard.

### CI, provisionamento e HPA

O workflow **Validar Infra K8s** verifica formatação, sintaxe e plano sem refresh, renderiza manifests Kubernetes e executa os testes de proteção dos scripts operacionais e de HPA. A etapa de plano da CI desabilita os recursos New Relic; ela não substitui a validação das consultas pela NerdGraph nem as verificações ao vivo.

**Provisionar Ambiente Homolog** e **Provisionar Ambiente Prod** realizam o provisionamento completo dos respectivos ambientes, incluindo recursos de observabilidade habilitados e integração com os demais repositórios. Seu escopo é mais amplo que o de atualização de dashboard. A existência do provisionamento de prod não transforma os validadores específicos de homolog em validadores de produção. Para conferir prod, use seus dashboards, política, monitor, aplicação e contexto Kubernetes.

**Validar Escala HPA Homolog** é um workflow separado do dashboard. Configura o suporte ao HPA quando solicitado, protege o plano contra alterações de nós ou dashboards, executa a prova de escala e redução no mesmo nó, restaura a configuração do teste e chama a validação ao vivo de telemetria. As evidências são publicadas como artefato `hpa-scaling-evidence`. Esse teste não adiciona widgets de HPA ao dashboard.

Os planos direcionados dos workflows de manutenção usam `-target` para limitar o escopo da operação; não representam uma avaliação de todas as diferenças do ambiente. Os secrets e variáveis necessários estão descritos em [New Relic](new-relic.md).

## Fontes da implementação

- `terraform/operational.tf`: 14 widgets operacionais, monitor externo e condição de health externo.
- `terraform/observability.tf`: 7 widgets de negócio, política e outras 7 condições de alerta.
- `terraform/variables.tf`: parâmetros, incluindo o limite de latência p95.
- `.github/workflows/operational-homolog.yml`, `dashboard-homolog.yml`, `hpa-homolog.yml`, `ci.yml` e `provision-*.yml`.
- `scripts/observability/validate-operational.py` e `validate-business-dashboard.py`.
- [Logs estruturados e correlação](logs-json-correlation-id.md) e [métricas de negócio](metricas-negocio.md).
