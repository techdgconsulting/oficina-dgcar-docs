# Métricas de negócio

Os indicadores de ordens de serviço são instrumentados na API e consultados no New Relic. Este documento cobre **homolog e prod**, nos dashboards `oficina-dgcar-homolog - Negocio OS` e `oficina-dgcar-prod - Negocio OS`. As regras descritas correspondem às consultas de `terraform/observability.tf` do repositório de infraestrutura.

## Micrometer e eventos New Relic

A implementação `OrdemServicoMicrometerMetrics` utiliza dois mecanismos: registra counters e timer no `MeterRegistry` do Micrometer e envia eventos customizados por `NewRelic.getAgent().getInsights().recordCustomEvent(...)`. As consultas atuais do dashboard usam os eventos customizados, não `sum()` dos counters Micrometer.

| Instrumento Micrometer | Tipo | Evento correspondente em `OficinaOsEvent` |
|---|---|---|
| `oficina_os_criada_total` | Counter | `OS_CRIADA` |
| `oficina_os_status_alterado_total` | Counter | `STATUS_ALTERADO` |
| `oficina_os_tempo_status` | Timer | `TEMPO_STATUS`, quando a duração informada é válida |
| `oficina_os_processamento_falha_total` | Counter | `FALHA_PROCESSAMENTO` |
| `oficina_os_notificacao_falha_total` | Counter | `FALHA_NOTIFICACAO` |
| `oficina_os_pagamento_falha_total` | Counter | `FALHA_PAGAMENTO` |

As tags variam por instrumento: origem e status na criação; fluxo, status e mecânico nas transições; fluxo e classe do erro no processamento; tipo/status/erro nas notificações; motivo/erro nos pagamentos. A integração `nri-prometheus` está desabilitada no bundle Kubernetes. A alimentação desses indicadores não depende de scraping dos instrumentos Micrometer.

## Eventos publicados e uso efetivo

| Tipo de evento | Conteúdo | Uso nas consultas implementadas |
|---|---|---|
| `OficinaOsEvent` | Discriminador `evento`, `app_name`, `metrics_version = 2` e atributos da ocorrência | Falhas nos dashboards e alertas. Criação, mudança de status e `TEMPO_STATUS` continuam sendo emitidos, mas não são a fonte atual do volume diário, do estado das OS ou da média por status |
| `OficinaOsOperationalSnapshot` | Número da OS, estado, cliente, veículo, placa, mecânico, valor e datas; `app_name` e `snapshot_version = 2` | Total em aberto, distribuição de status, tabela de OS, volume diário e produtividade |
| `OficinaOsStatusDurationSnapshot` | `numero_os`, `status`, `inicio_ms`, `fim_ms`, `tempo_ms` e `app_name` | Tempo médio dos intervalos encerrados e persistidos |
| `OficinaOsStatusSnapshot` | `status` e `quantidade`, agregados pelo repositório | Continua publicado pelo agendador, mas não é utilizado pelas consultas atuais dos dashboards e alertas analisados |

`OficinaOsStatusSnapshot` não inclui `app_name` nem versão. Ele não oferece o mesmo filtro de ambiente dos eventos utilizados pelo dashboard. `OficinaOsStatusDurationSnapshot` também não possui campo de versão; suas consultas filtram pela aplicação.

## Publicação durante os fluxos e pelo agendador

Os fluxos instrumentados de criação publicam `OS_CRIADA` e o snapshot operacional. O registro das mudanças de status publica `STATUS_ALTERADO`, a duração observada do status anterior quando válida e um novo snapshot operacional. Os tratamentos de falhas publicam os eventos correspondentes a processamento, notificação ou pagamento.

O `OrdemServicoStatusSnapshotPublisher` executa com estas propriedades:

| Propriedade | Padrão configurado |
|---|---|
| `observability.business-snapshot-initial-delay-ms` | `30000`: atraso inicial de 30 segundos |
| `observability.business-snapshot-delay-ms` | `60000`: intervalo de 60 segundos após o término de uma execução até o início da próxima |

A configuração usa `fixedDelay`, não uma execução em horário fixo a cada minuto. A duração da publicação e o tempo de ingestão no New Relic também influenciam a atualização dos gráficos.

A cada execução, o publicador consulta quantidades por status e percorre as OS persistidas. Para cada ordem, publica o estado operacional e, quando existem os dados necessários, os intervalos encerrados de diagnóstico, execução e finalização. A falha na publicação de uma OS é registrada em log e não interrompe as demais. Uma falha na consulta geral impede a publicação daquela rodada.

Os intervalos persistidos são republicados pelo agendador, inclusive quando a operação ocorreu antes da inicialização da aplicação. Isso difere dos eventos de ocorrência, que registram a execução dos fluxos instrumentados. Múltiplos pods também podem publicar snapshots da mesma OS; por isso as consultas precisam eliminar repetições.

## Identificação, versões e repetição

As consultas do dashboard filtram `app_name = 'oficina-dgcar-api-<ambiente>'`, com `<ambiente>` igual a `homolog` ou `prod`. Esse atributo vem de `NEW_RELIC_APP_NAME`. Nas consultas sobre o snapshot operacional, também se exige `snapshot_version = 2`.

O evento `OficinaOsEvent` carrega `metrics_version = 2`, mas as consultas atuais de falhas não filtram esse campo. Não se deve atribuir um filtro de versão a consultas que não o possuem.

A repetição dos snapshots é tratada de acordo com o indicador:

- `latest(...) FACET numero_os` obtém os últimos valores conhecidos por OS na janela consultada. A consulta externa conta essas ordens, em vez de contar cada publicação.
- `uniqueCount(numero_os)` conta OS distintas no agrupamento por data de criação.
- Para durações, `latest(tempo_ms)` e `latest(fim_ms)` são agrupados por `numero_os`, `status` e `inicio_ms`, identificando o intervalo antes de calcular a média.

Uma contagem direta de todos os eventos de snapshot cresce a cada republicação e não representa o total de ordens. Já `count(*)` sobre `OficinaOsEvent` mede ocorrências, sem deduplicação por OS.

## Regras dos indicadores

### Total de OS em aberto

A consulta obtém o último estado de cada OS e conta aquelas cujo status não é `ENTREGUE` nem `CANCELADA`. Assim, uma OS `FINALIZADA` ou `AGUARDANDO_RETIRADA` ainda pertence ao total em aberto. A janela definida no Terraform é de 30 minutos para os snapshots recebidos.

### Status das OS

Usa o último estado conhecido de cada ordem e agrupa a contagem por `status`, incluindo as entregues e canceladas. A janela padrão da consulta também é de 30 minutos. Esse gráfico representa o estado observado, não a quantidade de transições ocorridas no período.

### Volume diário de ordens de serviço

Agrupa `uniqueCount(numero_os)` por `data_criacao_dia`. O filtro exige `dias_desde_criacao >= 0` e `< 14`, cobrindo o dia atual e os 13 dias anteriores, com limite de 14 grupos. Não há exclusão por status.

A consulta lê snapshots recebidos nos últimos 30 minutos. O recorte de 14 dias é aplicado à data de criação armazenada nesses snapshots, e não ao timestamp de ingestão. Assim, uma OS criada há uma semana pode aparecer no dia correto quando seu snapshot é publicado agora. A consulta não preenche explicitamente com zero os dias sem eventos correspondentes.

### Tabela de ordens de serviço

A tabela utiliza os últimos valores por `numero_os`, exclui `CANCELADA` e mostra até 100 ordens, com janela de 30 minutos. As colunas definidas são:

| Coluna | Campo de origem |
|---|---|
| OS | `numero_os` |
| Cliente | `cliente_nome` |
| Veiculo | `veiculo` |
| Placa | `placa` |
| Mecanico | `mecanico_nome` |
| Status | `status` |
| Data de entrega | `data_entrega` |
| Valor | `valor_total` |

`data_entrega` é publicada no formato `dd/MM/yyyy HH:mm:ss` somente para OS `ENTREGUE` com entrega registrada. Nos demais casos, o valor publicado é vazio, evitando que `latest()` reaproveite uma data antiga. A consulta não define colunas de timestamp de ingestão ou tempo em minutos.

### Produtividade por mecânico

A consulta considera uma OS por número, com o último status e o último nome de mecânico presentes nos snapshots. Conta somente ordens que atendem simultaneamente a estas condições:

- Status `FINALIZADA`, `AGUARDANDO_RETIRADA` ou `ENTREGUE`.
- Mecânico diferente de `NAO_ATRIBUIDO` e `NAO_INFORMADO`.
- `data_finalizacao_ms` maior ou igual ao início do período e menor que seu fim.

O agrupamento é pelo nome do mecânico, não por seu ID. A consulta utiliza `SINCE 1 day ago` e `WITH TIMEZONE 'America/Sao_Paulo'`. Ela conta OS finalizadas no período, sem contar novamente uma ordem por ter sido paga ou entregue. Não utiliza o campo `finalizada_hoje` como filtro e não equivale a contar apenas desde a meia-noite.

### Tempo médio de execução por status

Utiliza `OficinaOsStatusDurationSnapshot`, com intervalos encerrados reconstruídos a partir dos dados persistidos:

| Status do intervalo | Início | Fim |
|---|---|---|
| `EM_DIAGNOSTICO` | Data do diagnóstico da execução | Primeira data de criação de orçamento que não seja anterior ao diagnóstico |
| `EM_EXECUCAO` | Início do período de execução | Fim do período de execução |
| `FINALIZADA` | Data de finalização da OS | Data do pagamento, quando o pagamento está `APROVADO` |

O intervalo `FINALIZADA` mede a espera entre a finalização e o pagamento aprovado, não o tempo até a entrega. Intervalos sem início, sem fim ou com fim anterior ao início não são publicados; duração zero é aceita.

Depois de eliminar republicações do mesmo intervalo, a consulta seleciona os que terminaram no período (`fim_ms >= periodo_inicio` e `< periodo_fim`) e calcula `average(tempo_ms) / 60000`, em minutos, por status. Um intervalo iniciado antes do período pode participar se terminou dentro dele. A janela definida é `SINCE 1 day ago`, com fuso `America/Sao_Paulo`. Não é um cronômetro das ordens ainda em andamento.

### Erros e falhas nas integrações

A tabela conta eventos `FALHA_PROCESSAMENTO`, `FALHA_NOTIFICACAO` e `FALHA_PAGAMENTO`, agrupados por `evento` e `erro`, com filtro de aplicação e janela de um dia. O atributo `erro` contém o nome simples da classe da exceção ou `NAO_INFORMADO` quando não há exceção associada.

`FALHA_PROCESSAMENTO` também contabiliza rejeições de negócio capturadas nos fluxos instrumentados, como tentativa de finalizar uma OS em estado incompatível (HTTP 409) ou gerar orçamento sem itens (HTTP 422). Portanto, não é um indicador exclusivo de erros internos HTTP 500 nem uma contagem de todas as respostas HTTP de erro da API.

Falhas de notificação incluem situações de envio e ausência de dados necessários. Falhas de pagamento incluem recusa do gateway e exceções no processamento. Uma mesma operação pode emitir mais de uma categoria: o tratamento de exceção no registro de pagamento, por exemplo, registra falha de processamento e de pagamento. O total de ocorrências não representa necessariamente operações ou OS distintas.

Não há, nessa instrumentação de negócio, métricas específicas de ViaCEP ou da autenticação da Lambda. O título do widget não deve ser interpretado como cobertura de todas as integrações do sistema.

## Janelas, datas e fuso horário

Há duas referências temporais: o timestamp do evento recebido pelo New Relic e a data de negócio contida no snapshot. Os filtros `SINCE` delimitam os eventos consultados; os campos de criação, finalização e encerramento delimitam as operações representadas por eles.

A API interpreta os `LocalDateTime` persistidos no fuso padrão da JVM e os converte para `America/Sao_Paulo` ao montar `data_criacao_dia`, `dias_desde_criacao`, `finalizada_hoje` e a data de entrega formatada. Os campos terminados em `_ms` representam epoch em milissegundos, calculado a partir do fuso da JVM.

Produtividade e duração usam os limites `periodo_inicio` e `periodo_fim` calculados na consulta interna. O Terraform define `periodo_fim` com `aggregationendtime()` e calcula o início subtraindo `round(count(*) / rate(count(*), 1 second) * 1000)`. As comparações são inclusivas no início e exclusivas no fim. Essas consultas e a de falhas declaram `WITH TIMEZONE 'America/Sao_Paulo'`.

As janelas aqui descritas são as gravadas no Terraform. Ao comparar um resultado no dashboard, confira também o período efetivo selecionado na interface. Uma janela sem snapshots pode deixar os widgets vazios mesmo quando existem OS no banco; a republicação periódica e a ingestão precisam estar funcionando.

## Consulta e verificação por ambiente

Substitua `<ambiente>` por `homolog` ou `prod`. Para conferir a presença dos snapshots e comparar publicações com ordens distintas:

```sql
FROM OficinaOsOperationalSnapshot
SELECT count(*) AS 'Snapshots', uniqueCount(numero_os) AS 'OS distintas'
WHERE app_name = 'oficina-dgcar-api-<ambiente>'
  AND snapshot_version = 2
SINCE 30 minutes ago
```

Para conferir as categorias emitidas nos fluxos:

```sql
FROM OficinaOsEvent
SELECT count(*)
WHERE app_name = 'oficina-dgcar-api-<ambiente>'
FACET evento
SINCE 1 day ago
WITH TIMEZONE 'America/Sao_Paulo'
```

Compare os resultados com ordens conhecidas do ambiente, considerando status atual, mecânico atribuído e datas persistidas. A validação de um ambiente não comprova a ingestão do outro.

O dashboard de negócio e o alerta de processamento filtram pela aplicação. As condições de alerta de notificação e pagamento em `observability.tf`, porém, filtram apenas pelo tipo de evento, sem `app_name`. Essa diferença da configuração atual impede afirmar que todos os alertas de negócio estão isolados por ambiente.

## Referências

- [Plataforma de observabilidade](new-relic.md) e [logs estruturados e correlação](logs-json-correlation-id.md).
- API: `OrdemServicoMicrometerMetrics.java`, `OrdemServicoStatusSnapshotPublisher.java` e casos de uso de OS, notificações e pagamento.
- Infraestrutura: `terraform/observability.tf`, fonte das regras dos sete widgets de negócio e das condições de alerta descritas.
