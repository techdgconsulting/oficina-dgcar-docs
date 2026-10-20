# Testes e resultados de validação

Registro das evidências de execução conferidas. As quantidades abaixo vêm dos relatórios de execução e dos logs das pipelines indicadas. A [ADR-009](../adr/ADR-009-estrategia-testes.md) registra a estratégia; esta página reúne resultados, cenários e acesso aos relatórios.

## Resumo por componente

| Componente | Execução verificada | Resultado |
|---|---|---|
| API | [CI da PR #34](https://github.com/techdgconsulting/oficina-dgcar-api/actions/runs/39315344562), revisão `8a50bf0` | 402 testes, 56 suítes Surefire; zero falhas, erros ou testes ignorados. Build Docker também aprovado. |
| Lambda | [CI da PR #21](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda/actions/runs/39313724722), revisão `40b99fd` | 18 testes Jest em quatro suítes, todos aprovados. |
| Infraestrutura Kubernetes | [CI da PR #57](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/39314590579), revisão `77a353e` | Sete testes de proteção operacional e oito de suporte ao HPA aprovados, além das verificações Terraform, manifests e sintaxe shell. |
| Infraestrutura de banco | [CI da PR #29](https://github.com/techdgconsulting/oficina-dgcar-infra-db/actions/runs/39313064392), revisão `decfed5` | Validação Terraform aprovada; não é uma suíte de testes Java/Jest nem uma comprovação de conexão ao RDS. |

As quantidades de testes não incluem requisições de Postman, varreduras de segurança ou amostras de carga. Aprovação da CI não equivale à validação funcional de um deploy em produção.

## API: quantidades e cenários

O [inventário dos 402 casos executados](cenarios-api.md) lista cada suíte e o nome de cada caso registrado pelo Surefire, com link para o código da revisão testada. A contagem inclui invocações de testes parametrizados; não é a quantidade de anotações `@Test` ou arquivos Java. Há 57 arquivos Java em `src/test`, incluindo código de apoio, e 56 suítes nos XMLs desta execução.

| Pacote ou grupo | Casos executados |
|---|---:|
| `adapters.in.web.controller` | 127 |
| `adapters.out.notification` | 2 |
| `adapters.out.payment` | 3 |
| `adapters.out.persistence` | 3 |
| `adapters.out.persistence.mapper` | 2 |
| `adapters.out.security` | 8 |
| `application.exception` | 1 |
| `application.usecase` | 98 |
| `coverage` | 10 |
| `domain.model` | 68 |
| `domain.valueobject` | 46 |
| `infrastructure.client` | 6 |
| `infrastructure.demo` | 7 |
| `infrastructure.observability` | 11 |
| `infrastructure.security` | 9 |
| `Aplicação (inicialização)` | 1 |
| **Total** | **402** |

Os cenários cobrem:

- Clientes e veículos: cadastros, consultas, atualizações, validações e recursos inexistentes.
- Ordem de serviço: criação simples e completa, vínculo de cliente/veículo, orçamento, execução, pagamento, entrega, encerramento e transições de status permitidas ou rejeitadas.
- Catálogo e estoque: peças, serviços e regras de quantidade e valores.
- Segurança: login/JWT, autorização por perfil, acesso externo do cliente, negações 401/403 e respostas de erro sanitizadas.
- Decisão de orçamento: aprovação/recusa externa e validações do token.
- Integrações: ViaCEP, gateway de pagamento e notificações com dependências isoladas ou simuladas conforme o teste.
- Persistência e dashboard: mapeamento de itens fora de transação no chamador, massa histórica, snapshots e migrations para os indicadores de negócio.
- Observabilidade: geração/preservação do `correlationId`, retorno no header, contexto dos logs e eventos de negócio.
- Regressão de `/error`: acesso direto por GET, POST, PUT, PATCH, DELETE e HEAD retorna 404; erros encaminhados preservam status e não expõem detalhes internos.

### H2 e PostgreSQL real

Os slices de persistência usam H2 quando configurado pelo teste. O teste [BusinessDashboardMigrationTest](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/src/test/java/br/com/oficina/adapters/out/persistence/BusinessDashboardMigrationTest.java) usa **Testcontainers com PostgreSQL 16**, aplica o schema até V19 e depois as migrations seguintes, verificando preenchimento dos mecânicos sem sobrescrever uma atribuição existente nem inventar datas de entrada no status.

Esse teste está configurado com `disabledWithoutDocker=true`: pode ser ignorado quando Docker não está disponível. Na execução registrada aqui houve **zero testes ignorados**, e esse cenário consta como aprovado. A anotação do perfil `test` não descreve sozinha todos os bancos usados pela suíte.

## API: cobertura JaCoCo

Valores extraídos dos contadores do `jacoco.xml` do artefato da CI acima, e não de um percentual antigo ou de uma imagem de badge:

| Métrica | Cobertos | Não cobertos | Cobertura |
|---|---:|---:|---:|
| Instruções | 13419 | 599 | 95,73% |
| Ramificações (branches) | 480 | 158 | 75,24% |
| Linhas | 2645 | 122 | 95,59% |
| Complexidade | 996 | 172 | 85,27% |
| Métodos | 815 | 28 | 96,68% |
| Classes | 291 | 1 | 99,66% |

O [POM da revisão testada](https://github.com/techdgconsulting/oficina-dgcar-api/blob/8a50bf01c10971bccaacd5d42e1f9205f767a35b/pom.xml) exige **95% de cobertura de instruções no bundle**. A execução atingiu **95,73%** e passou no `jacoco:check`. O limite não é uma exigência de 95% para branches, linhas ou todas as classes individualmente. O POM configura a exclusão da classe de entrada da aplicação.

### Onde acessar os relatórios

Abra a [execução da API](https://github.com/techdgconsulting/oficina-dgcar-api/actions/runs/39315344562) e baixe o artefato [test-reports](https://github.com/techdgconsulting/oficina-dgcar-api/actions/runs/39315344562/artifacts/12218525039). O download requer acesso ao repositório no GitHub. Após extrair:

| Conteúdo do artefato | Uso |
|---|---|
| `site/jacoco/index.html` | Relatório HTML navegável por pacote, classe e linha. Abra o arquivo com toda a pasta extraída. |
| `site/jacoco/jacoco.xml` | Contadores usados para os percentuais desta página. |
| `site/jacoco/jacoco.csv` | Dados tabulares de cobertura. |
| `surefire-reports/TEST-*.xml` | Casos executados, tempo, falhas, erros e testes ignorados. |
| `surefire-reports/*.txt` | Resumo por suíte. |

Os artefatos seguem a retenção configurada no GitHub Actions. Os relatórios podem ser reproduzidos a partir do código e de uma nova execução.

Na raiz de `oficina-dgcar-api`, com Java/Maven e Docker para o teste PostgreSQL:

```powershell
mvn clean test
Invoke-Item 'target/site/jacoco/index.html'
```

Localmente, Surefire fica em `target/surefire-reports` e JaCoCo em `target/site/jacoco`. O workflow `app-cd.yml` publica essas duas pastas como `test-reports`, inclusive em tentativa de execução com falha.

### Allure

Os resultados brutos são gravados em `target/allure-results`. Para gerar a apresentação HTML com os resultados locais existentes:

```powershell
.\allure-report.ps1 -SkipTests
```

O script da API gera `target/allure-report/index.html`; sem `-SkipTests`, executa os testes antes. A pipeline consultada publica Surefire/JaCoCo, mas não publica esse HTML Allure no artefato `test-reports`. A geração de um HTML Allure novo não foi realizada nesta revisão documental.

## Lambda: cenários e cobertura Jest

A [execução da Lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda/actions/runs/39313724722) registrou:

| Suíte | Casos | Cenários |
|---|---:|---|
| `handler.test.js` | 9 | CPF inválido, cliente inexistente, senha ausente/incorreta, status bloqueado, emissão de JWT, JSON malformado, preservação do correlation ID e log de erro sem CPF completo. |
| `cpf.test.js` | 4 | Normalização, CPF válido, dígito inválido e sequência de dígitos repetidos. |
| `clientRepository.test.js` | 2 | Consulta pelo documento e rejeição de identificador SQL inseguro. |
| `observability.test.js` | 3 | Máscara de CPF, seleção/geração de correlation ID e classificação de erros. |
| **Total** | **18** | **Todos aprovados.** |

Cobertura global do Jest: **96,26% de statements**, **70,24% de branches**, **100% de funções** e **96,21% de linhas**. Essas métricas são da Lambda e não devem ser combinadas com os percentuais JaCoCo da API.

A CI executa `npm test` com `--coverage`, lint, auditoria de dependências de produção, empacotamento e validações Terraform. A cobertura está na tabela do passo `Run tests`; não há upload de um artefato de cobertura nesse workflow. Localmente, `npm test` gera `coverage/lcov-report/index.html` e `coverage/coverage-final.json`. As dependências de banco e assinatura são isoladas conforme os mocks de cada teste; isso não constitui uma chamada real ao Gateway ou ao RDS.

## Infraestrutura: cenários de proteção

Na [execução de infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/39314590579), os sete testes operacionais verificam rejeição de alterações fora do escopo, mudanças AWS indevidas, substituição de dashboard, exclusões permitidas na fase `retire`, recuperação do monitor, rejeição de sucesso antigo e persistência da falha quando não há recuperação.

Os oito testes de HPA verificam: preservação de IPs primários/ativos, rejeição de alterações em EC2/node group, rejeição de substituição destrutiva do Helm, aceitação do endereço contado do release, memória disponível para a segunda réplica, alteração apenas do drop-in de capacidade, restauração em falha de reinício e rejeição de nó sem suporte a drop-in.

A CI também verifica formatação, inicialização, validação e plano Terraform sem refresh, renderização dos manifests e sintaxe dos scripts shell. O plano usa o escopo e as credenciais de teste definidos pelo workflow; não executa o provisionamento nem comprova o estado da AWS. O mesmo limite se aplica à [validação de infra-db](https://github.com/techdgconsulting/oficina-dgcar-infra-db/actions/runs/39313064392).

## Testes funcionais, carga e segurança

| Tipo | Evidência ou roteiro | Alcance |
|---|---|---|
| Funcional via Postman | [Collection e guias](https://github.com/techdgconsulting/oficina-dgcar-api/tree/homolog/postman), incluindo `VALIDACAO-DASHBOARD-NEGOCIO.md` e `VALIDACAO-POSTMAN-OBSERVABILIDADE.md` | Descrevem preparação, asserções e comparação dos indicadores. Não foi localizado um relatório de Runner nesta revisão; o roteiro não é apresentado como execução comprovada. |
| Escala HPA com k6 | [Execução do ensaio HPA](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/38794638490), artefato `hpa-scaling-evidence`; [procedimento](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#hpa-e-capacidade) | Evidência de 1 → 2 pods Ready → 1 na mesma EC2 em homolog. Não comprova três réplicas ou carga em prod. |
| Trivy | [Relatórios Maven e imagem](https://github.com/techdgconsulting/oficina-dgcar-api/tree/homolog/docs/ReportTRIVY) | Zero achados HIGH/CRITICAL no filtro usado; não é um resultado para todas as severidades. |
| OWASP ZAP | [Relatório HTML do OWASP ZAP](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/docs/ReportOWASP/2026-10-19-ZAP-Report-.html) | Análise do ambiente local; o relatório deve ser interpretado pelo alvo, autenticação e regras da execução. |

Os relatórios de segurança complementam os testes automatizados; não medem cobertura de código. As evidências de segurança e carga correspondem às execuções referenciadas. Os controles da esteira são verificados separadamente e não alteram as métricas JaCoCo ou Jest da aplicação.

## Controles da esteira e deploy automático

A suíte de [controles de deploy](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/scripts/ci/test_deployment.py) contém **19 cenários**, executados na CI de API, Lambda, banco e plataforma contra o guard distribuído em cada componente. Os mesmos cenários não representam 76 comportamentos distintos.

Os casos verificam: compatibilidade entre branch e ambiente; rejeição de SHA inválido ou externo ao histórico protegido; autorização do coordenador, componente e commit; rejeição de execução pai encerrada ou de outro ambiente; encaminhamento da atualização isolada; bloqueio de planos com remoção, substituição, erro ou execução incompleta; e exigência de acionamento manual do destroy. Esses testes usam respostas simuladas do GitHub e planos Terraform de teste, sem destruir recursos.

A integração em homolog foi verificada pelas execuções reais:

| Componente | Coordenador | Worker e resultado |
|---|---|---|
| Plataforma | [Atualização automática da plataforma](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/39445707331) | CI, validação do plano salvo e apply concluídos. Provisionamento completo não executado. |
| Banco | [Pedido de atualização do banco](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/39445796589) | [Worker do banco](https://github.com/techdgconsulting/oficina-dgcar-infra-db/actions/runs/39445992889) concluído após autorização e validação do plano. |
| Lambda | [Pedido de atualização da Lambda](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/39445859723) | [Worker da Lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda/actions/runs/39446260067) concluído com testes, pacote e atualização da função. |
| API | [Pedido de atualização da API](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/39445985010) | [Worker da API](https://github.com/techdgconsulting/oficina-dgcar-api/actions/runs/39446600845) concluído com testes, imagem ECR e rollout no EKS. Readiness pelo Gateway respondeu HTTP 200 e status UP. |

Os workers executaram o SHA encaminhado pelo coordenador e não geraram novos pedidos de deploy. A [PR apenas documental de infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/pull/62) valida o filtro que evita apply por alteração de README. O destroy foi revisado pelos controles e pela configuração, sem execução real. Esses resultados são de homolog e não comprovam implantação ou funcionamento de prod. A decisão está na [ADR-020](../adr/ADR-020-promocao-e-deploy-automatico.md).
