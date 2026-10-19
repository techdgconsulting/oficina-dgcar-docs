# ADR-016: Logs estruturados e correlation ID

**Status:** Aceito
**Data da decisão:** 2026-09-27
**Revisão documental:** 2026-10-15
**Autor:** Diego Gonzalez
**Contexto:** Sistema de Oficina Mecânica DGCar — Pós-graduação FIAP

## Contexto e decisão

A investigação de uma requisição exige identificar seus logs e sua transação APM. Em homolog e prod, a API escreve JSON no stdout e utiliza o coletor Kubernetes como único caminho de encaminhamento desses logs ao New Relic.

O Java Agent continua responsável pelo APM. O deploy fixa `NEW_RELIC_APPLICATION_LOGGING_FORWARDING_ENABLED=false` e `NEW_RELIC_APPLICATION_LOGGING_LOCAL_DECORATING_ENABLED=false`, evitando duplicação pelo envio simultâneo do agente e do coletor.

## Formato e coleta da API

O Logback emite `timestamp`, `application`, `environment`, `level`, `logger`, `thread` e `message`, além dos campos do MDC. O filtro HTTP acrescenta `correlationId`, `requestMethod` e `requestUri`; na conclusão, acrescenta `statusCode` e `elapsedMs` e emite `http_request_completed`. Os dois últimos campos são strings no JSON.

O provider da API inclui os metadados disponibilizados pelo Java Agent, como `trace.id` e `span.id`, quando presentes. Registros com exceção podem conter `stacktrace`. Esses campos opcionais não são exigidos em todos os logs.

O coletor lê somente os arquivos dos containers da API no namespace `oficina`, filtra `application = oficina-mecanica-dgcar`, interpreta o JSON e preserva seus campos. Acrescenta contexto de pod, container, namespace e cluster. O campo bruto `log` é removido após a incorporação do JSON; labels e annotations não são coletados nessa configuração.

## Correlação implementada

A API remove espaços das extremidades e aceita identificadores de 1 a 128 caracteres em `[A-Za-z0-9._:-]`. Prioriza `X-Correlation-Id`, tenta `X-Request-Id` quando o primeiro está ausente ou inválido e gera UUID se nenhum for válido. Devolve o identificador em `X-Correlation-Id` nas respostas que passam pelo filtro.

O valor entra no MDC e em `NewRelic.addCustomParameter("correlationId", correlationId)`. Ao concluir, o filtro remove os cinco campos de MDC que administra, evitando reaproveitamento na próxima requisição da thread. Não há transferência automática de MDC para tarefas assíncronas implementada nesse filtro.

Pesquisar o mesmo `correlationId` relaciona logs e transações. Isso não equivale a criar um trace distribuído: chamadas separadas podem usar o mesmo identificador e ter traces distintos. O código analisado comprova leitura, registro e devolução do header, mas não garante propagação automática para chamadas externas nem continuidade de trace entre API Gateway, Lambda e API.

## Lambda Auth

A Lambda escreve JSON no CloudWatch com `timestamp`, `level` em minúsculas, `message` e `service`, acrescidos de `correlationId` e atributos do fluxo. O campo `cpf` contém `***.***.***-XX`, preservando somente os dois últimos dígitos, ou `NAO_INFORMADO` quando o valor não tem 11 dígitos após normalização.

Ela seleciona `X-Correlation-Id` preenchido ou, na ausência, `X-Request-Id`; valida sem remover espaços e gera UUID quando o valor selecionado é inválido. Um primeiro header preenchido e inválido não faz a Lambda tentar o segundo. O handler devolve `X-Correlation-Id` nas respostas que produz.

Não há MDC nessa implementação. O logger não inclui automaticamente `environment`, `trace.id`, `span.id` ou `stacktrace`. O log group identifica homolog ou prod. Não foi encontrada configuração de ingestão desses logs ou de APM da Lambda no New Relic.

## Consequências e proteção dos dados

O formato estruturado permite filtros por contexto HTTP e correlação com APM, mantendo um único caminho de ingestão da API. A operação depende do coletor, do agente para os metadados de trace e da disponibilidade de telemetria na janela consultada.

Senhas, tokens, CPF completo, credenciais e payloads sensíveis não pertencem aos exemplos nem aos identificadores de correlação. A máscara de CPF da Lambda não constitui sanitização genérica de todas as mensagens e exceções.

## Histórico da decisão

O registro de 27/09/2026 estabeleceu JSON e correlation ID como padrões. A revisão de 15/10/2026 preserva essa decisão e especifica o coletor único e os campos efetivamente implementados. A descrição original de propagação ampla entre componentes não é tratada como evidência de rastreamento distribuído entregue.

## Referências

- [Logs JSON e correlação: campos, exemplos e consultas](../observabilidade/logs-json-correlation-id.md).
- [Plataforma New Relic](../observabilidade/new-relic.md).
- API: `logback-spring.xml`, `CorrelationIdFilter.java`, `NewRelicLinkingJsonProvider.java` e `app-cd.yml`.
- Infraestrutura: `terraform/logging-filters.conf`; Lambda: `src/observability.js` e `src/handler.js`.
