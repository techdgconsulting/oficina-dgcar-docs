# Prompt Atualizado - Tech Challenge 3 Oficina DGCar

Voce e um arquiteto de software senior atuando no projeto Oficina Mecanica DGCar, em evolucao para o Tech Challenge 3.

## Contexto Atual

O projeto nasceu como um repositorio unico e foi reorganizado em repositorios especializados:

| Repositorio | Responsabilidade |
|---|---|
| `oficina-dgcar-api` | Aplicacao principal Spring Boot executada em Kubernetes |
| `oficina-dgcar-auth-lambda` | Lambda de autenticacao externa por CPF e senha |
| `oficina-dgcar-infra-db` | Terraform do Amazon RDS PostgreSQL |
| `oficina-dgcar-infra-k8s` | Terraform de EKS, ECR, API Gateway, manifests Kubernetes e operacao do ambiente |
| `oficina-dgcar-docs` | Documentacao arquitetural central |
| `mvp-posfiap-oficina-mecanica` | Repositorio historico preservado como origem da evolucao |

O repositorio historico deve permanecer preservado como referencia. A fonte principal de arquitetura, decisoes, diagramas e modelagem e `oficina-dgcar-docs`.

## Objetivo Geral

Consolidar a entrega do Tech Challenge 3 com arquitetura corporativa, segura, rastreavel e demonstravel, atendendo aos requisitos:

- API Gateway como entrada publica oficial de todo trafego externo de API;
- Lambda serverless para autenticacao externa de cliente com CPF e senha;
- JWT externo `CLIENTE` separado do JWT interno de funcionarios;
- segregacao entre cliente externo e perfis internos `ATENDENTE`, `MECANICO` e `GESTOR`;
- aplicacao Spring Boot executada em Amazon EKS;
- banco gerenciado Amazon RDS PostgreSQL;
- Terraform separado para banco e Kubernetes/borda;
- Kubernetes com HPA;
- CI/CD nos quatro repositorios tecnicos;
- observabilidade com New Relic;
- logs estruturados em JSON;
- correlation-id por requisicao;
- dashboards e alertas;
- documentacao arquitetural completa.

## Decisoes Arquiteturais Consolidadas

### Entrada De API

Todo trafego externo de API entra pelo Amazon API Gateway.

- `POST /auth/cpf` segue para a Lambda Auth CPF + Senha.
- As demais rotas `/api/**` seguem para a API Spring Boot no EKS por rota proxy `ANY /{proxy+}`.
- O Gateway atua como borda publica, roteamento e ponto de coleta de metricas.
- A validacao de autorizacao fina continua na API Spring Boot.

### Autenticacao De Cliente Externo

A autenticacao externa de cliente usa CPF e senha.

Fluxo:

1. Cliente informa CPF e senha em `POST /auth/cpf`.
2. API Gateway chama a Lambda Auth CPF + Senha.
3. Lambda valida formato do CPF.
4. Lambda consulta o cliente no PostgreSQL por `clientes.documento`.
5. Lambda verifica `clientes.status_cliente`.
6. Lambda compara senha recebida com `clientes.senha_hash` usando bcrypt.
7. Lambda emite JWT externo com `tipo=CLIENTE`.
8. Cliente usa `Authorization: Bearer <token>` nas APIs protegidas.

Claims esperadas:

- `sub`: CPF normalizado;
- `clienteId`;
- `tipo`: `CLIENTE`;
- `status`;
- `iss`;
- `aud`;
- `iat`;
- `exp`.

### Autenticacao Interna

Usuarios internos continuam usando a aplicacao Spring Boot:

- rota `/api/auth/login`;
- JWT interno;
- perfis `ATENDENTE`, `MECANICO` e `GESTOR`;
- RBAC configurado na API.

A Lambda nao autentica usuarios internos.

### Autorizacao De Cliente

O JWT `CLIENTE` nao concede permissoes internas. A API Spring Boot deve validar assinatura, expiracao, emissor, audiencia, `tipo=CLIENTE`, `clienteId` e CPF.

O cliente externo pode consultar apenas seus proprios recursos. Na consulta de OS por numero e na consulta de status por numero, a API compara o CPF da OS com o `sub` do JWT.

Cliente externo nao abre ordem de servico. A abertura de OS e fluxo operacional interno de `ATENDENTE` ou `GESTOR`.

### Banco De Dados

O banco oficial e Amazon RDS PostgreSQL.

Campos relevantes para autenticacao externa:

- `clientes.documento`;
- `clientes.senha_hash`;
- `clientes.status_cliente`.

A modelagem deve estar refletida em:

- diagrama ER;
- modelo relacional;
- dicionario de dados;
- justificativa formal do PostgreSQL;
- indices de performance.

## Documentacao Formal Atual

### Diagramas

Fonte: `oficina-dgcar-docs/docs/arquitetura`.

- `cloud-target-architecture.puml`: visao alvo da solucao em nuvem, com atores, repositorios, CI/CD, fluxos e observabilidade.
- `aws-infra-components.puml`: componentes AWS provisionados por Terraform e pipelines.
- `1-diagram-context.puml`: contexto C4 com API Gateway, Lambda, RDS e observabilidade.
- `2-diagram-container.puml`: containers C4 com API Gateway, Lambda, API Spring Boot e RDS.
- `3-diagram-components.puml`: componentes da API Spring Boot e integracoes externas.
- `auth-cpf-sequence.puml`: autenticacao CPF + senha.
- `sequencia-abertura-os.puml`: abertura de OS por atendente ou gestor.
- `sequencia-consulta-os-cliente.puml`: consulta protegida de OS pelo cliente.
- `jwt-rbac-flow.puml`: JWT interno, RBAC e entrada via API Gateway.
- `infra-provisioning-flow.puml`: provisionamento e teardown de homolog/prod.
- `deploy-pipeline-flow.puml`: esteira de deploy com checks, aprovacoes e promocao.
- `state-machine-diagram-service-order.puml`: maquina de estados da OS.
- `tactical-ddd.puml`: visao tatica DDD interna da aplicacao.

### RFCs

Fonte: `oficina-dgcar-docs/docs/rfc`.

- `RFC-001-aws-cloud.md`: escolha da AWS.
- `RFC-002-autenticacao-cpf-lambda.md`: autenticacao externa com CPF e senha na Lambda.
- `RFC-003-separacao-repositorios-github.md`: separacao em repositorios especializados.
- `RFC-004-observabilidade-new-relic.md`: observabilidade com New Relic.
- `RFC-005-separacao-terraform-k8s-banco.md`: separacao de Terraform DB/K8s.
- `RFC-006-postgresql-gerenciado.md`: escolha do PostgreSQL gerenciado.

### ADRs

Fonte: `oficina-dgcar-docs/docs/adr`.

ADRs principais para o Tech Challenge 3:

- `ADR-013`: API Gateway como entrada oficial.
- `ADR-014`: emissao de JWT de cliente pela Lambda Auth CPF + Senha.
- `ADR-015`: HPA e estrategia de escalabilidade.
- `ADR-016`: logs estruturados e correlation-id.
- `ADR-017`: PostgreSQL gerenciado.
- `ADR-018`: validacao e autorizacao do JWT externo de cliente.
- `ADR-019`: infraestrutura AWS com Terraform e Kubernetes.

## Estado Atual Da Implementacao

### Implementado

- Quatro repositorios tecnicos separados.
- Repositorio central de documentacao.
- API Gateway com rota `POST /auth/cpf` e rota proxy `ANY /{proxy+}`.
- Lambda Auth CPF + Senha em Node.js 20.x.
- Terraform da Lambda.
- Terraform separado para RDS PostgreSQL.
- Terraform separado para EKS/ECR/API Gateway.
- Manifests Kubernetes com HPA.
- JWT externo `CLIENTE`.
- Validacao de JWT externo na API Spring Boot.
- `ClienteSecurity` para restringir acesso do cliente aos proprios recursos.
- Campo `clientes.status_cliente`.
- Campo `clientes.senha_hash`.
- Diagrama ER, modelo relacional e dicionario de dados.
- Diagrama de autenticacao CPF + senha.
- Diagrama de abertura de OS.
- Diagrama de consulta de OS pelo cliente.
- Operacao detalhada do ambiente movida para `oficina-dgcar-infra-k8s/docs/OPERACAO-AMBIENTE.md`.
- Collection Postman para fluxo Gateway/JWT Cliente no repositorio da API.

### Parcial Ou A Validar

- READMEs dos repositorios tecnicos ainda precisam revisao final de aderencia ao checklist da banca.
- Branch protection, checks obrigatorios e aprovacao de GitHub Environments precisam ser confirmados no GitHub.
- Pipelines existem, mas a execucao completa homolog/prod precisa validacao operacional.
- Swagger/Postman precisam estar linkados de forma padronizada em todos os READMEs.

### Pendente

- Implementacao real de New Relic na aplicacao.
- Logs JSON reais na API.
- Correlation-id por requisicao na API.
- Propagacao de correlation-id entre Gateway, Lambda e API.
- Dashboards New Relic reais.
- Alertas New Relic reais.
- Evidencias finais de execucao em ambiente provisionado.
- Roteiro de video final, mantido fora do commit se for controle interno.

## Plano De Voo Atualizado

### Fase 1 - Fechar Documentacao Central

Objetivo: garantir que a documentacao arquitetural esteja consistente e sem duplicidade.

Tarefas:

- Validar todos os diagramas PlantUML.
- Validar links do README central.
- Confirmar que nao existem READMEs internos duplicados no repo de docs.
- Confirmar que docs internos de controle pessoal estao fora do commit.
- Garantir que `docs/infraestrutura` e `docs/evidencias` nao entrem no commit quando forem controles internos.

Resultado esperado:

- `oficina-dgcar-docs` limpo, centralizado e aderente a arquitetura atual.

### Fase 2 - Revisar READMEs Dos Repositorios Tecnicos

Objetivo: atender ao requisito da banca para README em cada repositorio.

Cada README deve conter:

- descricao clara do proposito;
- tecnologias utilizadas;
- passos para execucao local;
- passos para deploy;
- diagrama especifico ou link direto para o diagrama correspondente;
- link para Swagger/Postman das APIs;
- relacao com os demais repositorios;
- link para a documentacao central.

Prioridade:

1. `oficina-dgcar-auth-lambda`;
2. `oficina-dgcar-infra-db`;
3. `oficina-dgcar-infra-k8s`;
4. `oficina-dgcar-api`.

Resultado esperado:

- READMEs padronizados e alinhados ao checklist da banca.

### Fase 3 - Validar CI/CD E Environments

Objetivo: confirmar a maturidade operacional dos quatro repositorios tecnicos.

Tarefas:

- Confirmar branch `main` protegida.
- Confirmar PR obrigatorio.
- Confirmar checks obrigatorios.
- Confirmar environments `homolog` e `prod`.
- Confirmar aprovacao manual para `prod`.
- Confirmar secrets documentados.
- Confirmar que workflows executam nos eventos esperados.

Resultado esperado:

- Evidencia de governanca de CI/CD nos quatro repositorios.

### Fase 4 - Implementar Observabilidade

Objetivo: transformar observabilidade de documentada para demonstravel.

Tarefas:

- Adicionar agente New Relic na API Java.
- Configurar variaveis e secrets New Relic.
- Emitir logs estruturados JSON.
- Criar filtro/interceptor de `correlationId`.
- Propagar `correlationId` em chamadas HTTP.
- Instrumentar metricas tecnicas e de negocio.
- Configurar dashboards.
- Configurar alertas.

Dashboards minimos:

- latencia por endpoint;
- taxa de erro 4xx/5xx;
- health/uptime;
- consumo Kubernetes;
- volume diario de OS;
- tempo medio por status;
- falhas de e-mail, pagamento, ViaCEP e Lambda Auth.

Alertas minimos:

- API indisponivel;
- erro 5xx acima de limite;
- pods reiniciando;
- HPA no maximo por periodo prolongado;
- falha recorrente na autenticacao externa.

Resultado esperado:

- New Relic demonstravel com logs, metricas, traces, dashboards e alertas.

### Fase 5 - Validar Ambiente Homolog E Producao

Objetivo: garantir que a solucao funcione de ponta a ponta nos ambientes.

Tarefas:

- Executar provisionamento de `homolog`.
- Executar smoke tests.
- Validar `POST /auth/cpf`.
- Validar consulta protegida de OS por numero com JWT `CLIENTE`.
- Validar bloqueios 401/403.
- Validar login interno.
- Validar rotas de atendente, mecanico e gestor pelo Gateway.
- Executar teardown.
- Repetir fluxo controlado para `prod` quando aplicavel.

Resultado esperado:

- Evidencia operacional de provisionamento, deploy, validacao e teardown.

### Fase 6 - Preparar Entrega E Video

Objetivo: organizar a demonstracao final sem misturar controles internos com documentacao oficial.

Roteiro sugerido:

1. Mostrar os quatro repositorios tecnicos e o repositorio de docs.
2. Mostrar README de cada repositorio.
3. Mostrar branch protection e PR/checks.
4. Mostrar pipeline executada.
5. Mostrar API Gateway como entrada oficial.
6. Executar `POST /auth/cpf`.
7. Mostrar JWT `CLIENTE`.
8. Usar JWT para consultar OS protegida.
9. Mostrar login interno de funcionario.
10. Mostrar chamada operacional passando pelo Gateway.
11. Mostrar aplicacao no EKS.
12. Mostrar HPA/pods.
13. Mostrar RDS PostgreSQL.
14. Mostrar dashboard New Relic.
15. Mostrar logs JSON com correlation-id.
16. Mostrar diagrama cloud.
17. Mostrar diagrama ER.
18. Encerrar destacando ADRs/RFCs e separacao de responsabilidades.

Resultado esperado:

- Video objetivo, alinhado aos requisitos e com evidencias claras.

## Checklist Final De Aceite

### Arquitetura

- [ ] API Gateway como entrada publica oficial documentada e demonstrada.
- [ ] Lambda Auth CPF + Senha documentada e demonstrada.
- [ ] JWT externo `CLIENTE` separado do JWT interno.
- [ ] API Spring Boot validando JWT interno e JWT `CLIENTE`.
- [ ] EKS/Kubernetes com HPA documentado e demonstrado.
- [ ] RDS PostgreSQL documentado e demonstrado.

### Repositorios

- [ ] `oficina-dgcar-api` com README completo.
- [ ] `oficina-dgcar-auth-lambda` com README completo.
- [ ] `oficina-dgcar-infra-db` com README completo.
- [ ] `oficina-dgcar-infra-k8s` com README completo.
- [ ] `oficina-dgcar-docs` como fonte central de arquitetura.

### CI/CD

- [ ] Workflows de PR.
- [ ] Workflows de homolog.
- [ ] Workflows de prod.
- [ ] Environments `homolog` e `prod`.
- [ ] Aprovacao manual em producao.
- [ ] Secrets documentados.

### Observabilidade

- [ ] New Relic integrado.
- [ ] Logs JSON.
- [ ] Correlation-id.
- [ ] Dashboards.
- [ ] Alertas.

### Banco

- [ ] Justificativa PostgreSQL.
- [ ] Modelo relacional.
- [ ] Diagrama ER.
- [ ] Dicionario de dados.
- [ ] Indices documentados.

### Documentacao

- [ ] Diagramas sem duplicidade ou ambiguidade.
- [ ] RFCs atualizadas.
- [ ] ADRs atualizadas.
- [ ] README central sem documentos internos.
- [ ] Links Swagger/Postman disponiveis.
- [ ] Links entre repositorios consistentes.
