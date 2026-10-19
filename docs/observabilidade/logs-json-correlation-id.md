# Logs JSON e correlação

A API Spring Boot e a Lambda Auth emitem logs JSON e devolvem `X-Correlation-Id` nas respostas tratadas pelos respectivos componentes. Este documento cobre **homolog e prod**. Os exemplos são fictícios e não contêm credenciais ou dados reais de clientes.

## API: resolução do identificador

O `CorrelationIdFilter` executa no início do processamento HTTP e escolhe o identificador nesta ordem:

1. Lê `X-Correlation-Id`, remove espaços nas extremidades e valida o valor.
2. Se o valor estiver ausente ou inválido, faz a mesma validação em `X-Request-Id`.
3. Se nenhum dos dois for válido, gera um UUID.

A validação aceita de 1 a 128 caracteres, limitados a letras ASCII, números, ponto, sublinhado, dois-pontos e hífen: `^[A-Za-z0-9._:-]{1,128}$`. Espaços internos e caracteres de controle são rejeitados. Um identificador inválido é substituído; ele não causa rejeição da requisição.

O filtro devolve o valor escolhido no header `X-Correlation-Id`, inclusive quando a origem foi `X-Request-Id`. Essa devolução vale para as respostas que passam pela aplicação; uma resposta produzida antes dela, por exemplo pelo API Gateway, não é produzida por esse filtro.

## MDC, conclusão da requisição e APM

O filtro adiciona `correlationId`, `requestMethod` e `requestUri` ao MDC, o contexto de diagnóstico associado à thread. O encoder JSON inclui esses campos nos logs emitidos durante o processamento nessa thread.

No bloco `finally`, o filtro calcula a duração em milissegundos, consulta o status da resposta e acrescenta `statusCode` e `elapsedMs`. Em seguida, emite `http_request_completed` e remove do MDC os cinco campos que administra. A limpeza evita que o contexto permaneça quando a thread atende outra requisição; ela não apaga indiscriminadamente campos de outros componentes.

`statusCode` representa o status disponível na resposta no momento do registro. `statusCode` e `elapsedMs` são strings no JSON, pois são inseridos no MDC como texto. Logs emitidos antes da conclusão podem não conter esses dois campos. O filtro não implementa transferência automática do MDC para outras threads ou tarefas assíncronas.

A API também chama `NewRelic.addCustomParameter("correlationId", correlationId)`, associando o identificador à transação APM quando o agente está ativo. O `NewRelicLinkingJsonProvider` acrescenta os metadados disponibilizados pelo agente, incluindo `trace.id` e `span.id` quando presentes. A configuração do Logback inclui `stacktrace` quando o registro contém uma exceção.

## Campos e exemplo da API

| Campo | Origem e significado |
|---|---|
| `timestamp` | Data e hora do registro em UTC |
| `application` | `spring.application.name`, com padrão `oficina-mecanica-dgcar` |
| `environment` | `NEW_RELIC_ENVIRONMENT`; na ausência, `SPRING_PROFILES_ACTIVE` e depois `local` |
| `level`, `logger`, `thread`, `message` | Nível, classe emissora, thread e mensagem do Logback |
| `correlationId` | Identificador selecionado pelo filtro |
| `requestMethod`, `requestUri` | Método HTTP e URI obtidos da requisição; a URI não inclui a query string |
| `statusCode`, `elapsedMs` | Status e duração registrados ao concluir o filtro |
| `trace.id`, `span.id` | Identificadores fornecidos pelo Java Agent quando disponíveis |
| `stacktrace` | Pilha da exceção, quando anexada ao registro |

Exemplo fictício de conclusão de requisição em homolog, com metadados de trace disponíveis:

```json
{
  "timestamp": "2026-10-15T12:00:00.000Z",
  "application": "oficina-mecanica-dgcar",
  "environment": "homolog",
  "level": "INFO",
  "logger": "br.com.oficina.infrastructure.observability.CorrelationIdFilter",
  "thread": "http-nio-8080-exec-1",
  "message": "http_request_completed",
  "correlationId": "exemplo-os-001",
  "requestMethod": "GET",
  "requestUri": "/api/ordens-servico",
  "statusCode": "200",
  "elapsedMs": "45",
  "trace.id": "0123456789abcdef0123456789abcdef",
  "span.id": "0123456789abcdef"
}
```

Em prod, o campo `environment` recebe `prod`. O nome `application` permanece o da aplicação; ele não deve ser confundido com `appName` das transações APM, que segue `oficina-dgcar-api-<ambiente>`.

O registro de conclusão não recebe uma exceção como argumento e, portanto, não inclui `stacktrace` por si só. Em um log que contém exceção, esse campo é uma string com a pilha e quebras de linha escapadas no JSON. Não se deve exigir `stacktrace`, `trace.id` ou `span.id` em todos os registros.

## Coleta no Kubernetes

O Logback escreve JSON no stdout. O coletor `newrelic-logging` lê os arquivos `/var/log/containers/oficina-api-*_oficina_oficina-api-*.log` e filtra `application = oficina-mecanica-dgcar`.

O filtro Kubernetes usa `Merge_Log On` para incorporar os campos do JSON e `Keep_Log Off` para remover a cópia bruta do campo `log`. Os campos estruturados da aplicação, inclusive MDC e stacktrace, são preservados. Os metadados Kubernetes são movidos para o nível principal, permitindo consultar `pod_name`, `container_name` e `namespace_name`; o coletor acrescenta `cluster_name`. Labels e annotations não são incluídos por essa configuração.

O Java Agent mantém `NEW_RELIC_APPLICATION_LOGGING_FORWARDING_ENABLED=false` e `NEW_RELIC_APPLICATION_LOGGING_LOCAL_DECORATING_ENABLED=false`. O envio ocorre pelo coletor Kubernetes, evitando duplicação por encaminhamento simultâneo do agente. A inclusão explícita dos metadados de trace no JSON continua sendo feita pela API.

## Localização de uma requisição

Use o `X-Correlation-Id` devolvido na resposta. No New Relic, escolha a janela da requisição e substitua `<ambiente>` por `homolog` ou `prod` nas consultas. O exemplo abaixo usa um identificador fictício; substitua-o pelo identificador procurado.

```sql
FROM Log
SELECT timestamp, message, correlationId, requestMethod, requestUri,
       statusCode, elapsedMs, `trace.id`, `span.id`, stacktrace, pod_name
WHERE cluster_name = 'oficina-dgcar-<ambiente>-eks'
  AND namespace_name = 'oficina'
  AND container_name = 'oficina-api'
  AND environment = '<ambiente>'
  AND correlationId = 'exemplo-os-001'
SINCE 30 minutes ago LIMIT 100
```

Para localizar as transações APM relacionadas:

```sql
FROM Transaction
SELECT timestamp, name, duration, correlationId
WHERE appName = 'oficina-dgcar-api-<ambiente>'
  AND correlationId = 'exemplo-os-001'
SINCE 30 minutes ago LIMIT 100
```

Se houver `trace.id`, use o vínculo do log com o trace no New Relic ou filtre os logs por esse campo. Para conferir o registro de conclusão, acrescente `message = 'http_request_completed'` à consulta de logs. O número de logs com um identificador pode ser maior que o número de requisições, pois uma requisição pode emitir várias mensagens.

## Lambda Auth

A Lambda possui formato e resolução de identificador próprios, definidos em `src/observability.js`. A busca dos headers ignora diferenças entre maiúsculas e minúsculas. Ela seleciona `X-Correlation-Id` quando preenchido ou, na ausência de valor, `X-Request-Id`, e então valida o valor selecionado com `^[a-zA-Z0-9._:-]{1,128}$`.

Diferentemente da API, a Lambda não remove espaços nas extremidades. Se `X-Correlation-Id` estiver preenchido, mas for inválido, ela gera UUID sem tentar o outro header. Na ausência de um valor válido selecionado, usa `crypto.randomUUID()`. O handler passa o identificador aos logs e o devolve em `X-Correlation-Id` nas respostas de sucesso e erro que produz. Não há uso de MDC nessa implementação.

Os campos básicos são `timestamp`, `level`, `message` e `service`. O nível é escrito em minúsculas (`info`, `warn` ou `error`) e o serviço é `oficina-dgcar-auth-lambda`. O handler acrescenta `correlationId`, `cpf` mascarado e, conforme o fluxo, `reason`, `clienteId` ou `status`. Falhas internas incluem `errorType`, `errorName` e `errorMessage`. As mensagens utilizadas são `auth_cpf_success`, `auth_cpf_failed` e `auth_cpf_lambda_failure`.

A máscara remove os caracteres não numéricos do CPF. Quando restam 11 dígitos, mantém apenas os dois últimos no formato `***.***.***-XX`; nos demais casos, retorna `NAO_INFORMADO`.

Exemplo fictício de falha de validação:

```json
{
  "timestamp": "2026-10-15T12:00:00.000Z",
  "level": "warn",
  "message": "auth_cpf_failed",
  "service": "oficina-dgcar-auth-lambda",
  "correlationId": "exemplo-auth-001",
  "cpf": "NAO_INFORMADO",
  "reason": "CPF_INVALIDO"
}
```

O logger da Lambda não acrescenta automaticamente `environment`, campos HTTP, `trace.id`, `span.id` ou `stacktrace`. O ambiente é identificado pelo log group do CloudWatch: `/aws/lambda/oficina-dgcar-homolog-auth-cpf` ou `/aws/lambda/oficina-dgcar-prod-auth-cpf`.

Selecione o log group correspondente e consulte no CloudWatch Logs Insights:

```text
fields @timestamp, message, correlationId, level, reason, errorType
| filter correlationId = "exemplo-auth-001"
| sort @timestamp asc
| limit 100
```

A emissão de JSON no CloudWatch não comprova ingestão no New Relic. A configuração versionada analisada não contém agente, extensão ou encaminhamento dos logs da Lambda para o New Relic.

## Correlação e rastreamento distribuído

`correlationId` é um atributo usado para localizar registros relacionados. Se um cliente enviar o mesmo identificador em chamadas separadas à Lambda e à API, os componentes podem registrá-lo e devolvê-lo conforme suas regras de validação. Isso permite pesquisa pelo identificador, mas não cria automaticamente um trace distribuído.

`trace.id` e `span.id` pertencem ao contexto de rastreamento disponibilizado pelo Java Agent. O mesmo `correlationId` pode aparecer em diferentes transações e traces. A implementação analisada comprova a leitura dos headers recebidos, sua associação aos logs e ao APM da API e a devolução na resposta. Não comprova propagação automática de `X-Correlation-Id` em chamadas de saída, continuidade de trace entre Lambda e API ou transporte do MDC entre threads.

## Cuidados com os registros

Não inclua senhas, tokens, CPF completo, payloads de autenticação ou dados reais de clientes em exemplos, identificadores de correlação ou comandos de consulta compartilhados. A máscara de CPF descrita acima pertence ao logger da Lambda; ela não é um sanitizador genérico de mensagens de erro ou de todos os logs da API.

## Referências

- [Plataforma New Relic e configuração por ambiente](new-relic.md).
- API: `CorrelationIdFilter.java`, `NewRelicLinkingJsonProvider.java` e `src/main/resources/logback-spring.xml` no repositório `oficina-dgcar-api`.
- Coleta: `terraform/main.tf` e `terraform/logging-filters.conf` no repositório `oficina-dgcar-infra-k8s`.
- Lambda: `src/observability.js` e `src/handler.js` no repositório `oficina-dgcar-auth-lambda`.
