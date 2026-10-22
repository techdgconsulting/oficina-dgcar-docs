# ADR-020: Promoção por Pull Request e deploy automático por ambiente

**Status:** Aceito

## Contexto

O projeto exige main protegida, merges por Pull Request e deploy automático de homologação e produção. Os componentes possuem repositórios e states próprios, mas compartilham dependências de rede e execução. Gatilhos independentes podem competir com o provisionamento completo ou o destroy.

## Decisão

O fluxo é feature → PR para `homolog` → validação e deploy em homolog → PR de promoção para `main` → deploy em prod. A validação de uma PR para main exige que ela contenha o histórico atual de homolog, inclusive quando uma branch de release reconcilia ajustes exclusivos de produção. Main exige PR, check `validate`, uma aprovação de outra conta e histórico linear, com integração por squash; a proteção se aplica também aos administradores. A branch homolog não possui a mesma proteção nem revisão obrigatória configurada, embora o fluxo de trabalho utilize PRs. Uma aprovação de PR e uma eventual aprovação de GitHub Environment são controles distintos.

API, Lambda e banco encaminham automaticamente as mudanças relevantes ao coordenador do ambiente em infra-k8s, após a validação do componente. Infra-k8s valida e aplica mudanças da plataforma existente. Documentação não dispara provisionamento. O repositório docs também utiliza PR e proteção da main. Suas automações locais de infraestrutura permanecem fora do versionamento; a operação pertence a infra-k8s.

A fila por ambiente pertence a infra-k8s e é compartilhada por deploys, provisionamento completo, destroy e manutenção. Os workers executam o SHA solicitado e verificam o ambiente, o componente e a execução pai antes de acessar a AWS. Uma execução delegada não gera outro pedido de deploy. A fila comporta até 100 pedidos pendentes, conforme o GitHub Actions, e não garante ordem cronológica de commits. Cada execução registra seu SHA; reexecuções devem usar a revisão desejada da branch do ambiente.

O provisionamento completo permanece manual, na ordem rede/plataforma → banco → Lambda → integrações → API. Atualizações de componentes não acionam esse fluxo completo. O destroy permanece manual, com confirmação explícita, preparação da proteção do banco e liberação de dependências. Em homolog e prod, remove os recursos sem gerar snapshot final e limpa snapshots manuais e backups retidos da instância do ambiente. O backend S3 compartilhado do Terraform permanece fora do destroy dos ambientes.

O workflow selecionado define o ambiente, sem input `environment`. O provisionamento completo usa `component=all`: em homolog, branch `homolog` e confirmação `PROVISIONAR`; em prod, branch `main` e confirmação `PROVISIONAR_PROD`. A remoção usa `DESTRUIR` em homolog ou `DESTRUIR_PROD` em prod. Os formulários, referências aceitas e procedimentos ficam no README de infra-k8s. `run_smoke_tests` é opcional e desabilitado por padrão; verificações manuais após o deploy devem ser registradas separadamente dos testes executados pela CI.

Terraform mantém states e locks separados. Antes do apply, o workflow valida o módulo, salva o plano, bloqueia remoções e substituições e aplica exatamente o plano validado. Uma mudança bloqueada precisa de revisão e aprovação explícita em uma operação específica; a esteira não oferece um parâmetro para ignorar esse controle.

## Consequências

As atualizações ficam rastreáveis por ambiente, SHA e execução pai. A disponibilidade da fila e do token de automação passa a ser necessária aos deploys. Mudanças coordenadas em mais de um repositório continuam exigindo planejamento da sequência. Atualizações podem falhar se houver drift, recursos ausentes ou planos destrutivos; isso não dispara destroy nem recriação automática do ambiente.

Aprovações e regras de environments existentes permanecem válidas. O merge dispara o fluxo automaticamente, mas uma aprovação de environment, quando configurada, continua sendo respeitada. Validar homolog não comprova o estado de prod.

## Implementação e procedimentos

- [Coordenador, provisionamento, manutenção e destroy — infra-k8s](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#atualização-automática-de-ambientes-existentes).
- [Deploy da API](https://github.com/techdgconsulting/oficina-dgcar-api/blob/homolog/README.md#cicd-e-deploy).
- [Deploy da Lambda](https://github.com/techdgconsulting/oficina-dgcar-auth-lambda/blob/homolog/README.md#cicd-e-deploy).
- [Apply e proteção do banco](https://github.com/techdgconsulting/oficina-dgcar-infra-db/blob/homolog/README.md#ci-apply-e-orquestração).
- [Fluxo de deploy](../arquitetura/deploy-pipeline-flow.puml) e [provisionamento completo](../arquitetura/infra-provisioning-flow.puml).
- [Evidências de execução em homolog e produção](../testes/README.md#controles-da-esteira-e-deploy-automático).
- [Semântica da fila — GitHub Actions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency).
