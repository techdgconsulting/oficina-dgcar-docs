# ADR-015: HPA e estratégia de escalabilidade do cluster

**Status:** Aceito
**Data da decisão:** 2026-09-27
**Revisão documental:** 2026-10-15
**Autor:** Diego Gonzalez
**Contexto:** Sistema de Oficina Mecânica DGCar — Pós-graduação FIAP

## Contexto e decisão

A API utiliza o Horizontal Pod Autoscaler para ajustar a quantidade de pods conforme a utilização de CPU. O HPA altera réplicas do Deployment `oficina-api`, no namespace `oficina`; o scheduler posiciona os pods na capacidade disponível do cluster. A criação de outra EC2 não é requisito para aumentar de um para dois pods.

O Metrics Server fornece as métricas de recursos pela API `metrics.k8s.io`. O New Relic acompanha a operação, mas não fornece a métrica de CPU consumida por esse HPA. Não há Cluster Autoscaler ou Karpenter na solução analisada. Escala de pods e escala de nós são mecanismos distintos.

## Configuração implementada

Os parâmetros abaixo estão presentes tanto no manifesto de infraestrutura quanto no HPA gerado pelo workflow da API, utilizado nos ambientes homolog e prod.

| Parâmetro | Valor |
|---|---|
| API Kubernetes | `autoscaling/v2` |
| mínimo de réplicas | 1 |
| máximo de réplicas | 3 |
| métrica | CPU, `Resource` / `Utilization` |
| Alvo | 70% do request de CPU |
| Request de CPU da API | `250m` (0,25 core) |
| Limit de CPU da API | `500m` (0,5 core) |
| Request de memória da API | `512Mi` |
| Limit de memória da API | `768Mi` |

O alvo de 70% corresponde a 175m de CPU por réplica em relação ao request de 250m. Não é 70% do limit de 500m nem da CPU total da EC2. O controlador considera as métricas e suas regras de tolerância e estabilização; superar esse valor em uma amostra isolada não garante escala imediata. A memória é monitorada e limita o agendamento, mas não é métrica de escala nesse HPA.

## Diferença entre manifesto e deploy da API

| Origem | Comportamento declarado |
|---|---|
| `oficina-dgcar-infra-k8s/k8s/hpa.yaml` | `scaleUp`: estabilização de 60 s, política de 100% em 60 s; `scaleDown`: estabilização de 300 s, política de 50% em 60 s |
| `oficina-dgcar-api/.github/workflows/app-cd.yml` | Define mínimo, máximo e alvo de CPU, mas não declara `spec.behavior` |

Não existe uma única janela explicitamente configurada pelas duas fontes. Quando `behavior` não está no recurso aplicado, o controlador usa seus padrões; em um recurso existente, o resultado também depende do histórico de aplicação e da gestão dos campos. A configuração efetiva é conferida com `kubectl get hpa oficina-api -n oficina -o yaml`. Não se deve atribuir automaticamente a estabilização de 60 s do manifesto ao deploy do workflow.

## Capacidade do nó e rede dos pods

O Terraform habilita prefix delegation no VPC CNI, com `ENABLE_PREFIX_DELEGATION=true`, `WARM_PREFIX_TARGET=1` e `WARM_IP_TARGET=2`. Essa configuração amplia a disponibilidade de endereços para pods sem exigir outro nó.

Um Job de configuração instala o drop-in `99-oficina-pod-capacity.conf` no kubelet AL2023, com `maxPods=17`, e reinicia o kubelet na mesma EC2. O script verifica o suporte a drop-ins, não reescreve a configuração base e restaura o arquivo anterior se a operação falhar. O Job utiliza acesso privilegiado ao host para essa manutenção, sem token de ServiceAccount.

`maxPods=17` é o teto de pods do nó, incluindo workloads de sistema. Não significa capacidade para 17 réplicas da API. CPU, memória, IPs e requests dos demais containers continuam limitando o agendamento. O ajuste persiste no disco desse nó; a substituição da instância exige conferir novamente sua configuração.

O Metrics Server é instalado pelo Helm, com uma réplica e resolução de métricas de 15 s. Seus requests são 25m/32Mi e limits 200m/128Mi. A configuração de capacidade e o Metrics Server estão em `terraform/hpa.tf`.

## Evidência e limites da decisão

A [execução 38794638490 em homolog](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/actions/runs/38794638490), de 15/10/2026, registrou **1 → 2 pods Ready → 1 na mesma EC2**, com restauração da configuração original e verificação New Relic.

O máximo configurado de três réplicas não equivale à capacidade demonstrada: o ensaio comprovou duas réplicas prontas em homolog. Não comprovou três réplicas simultâneas, capacidade equivalente em prod ou disponibilidade diante da perda do único nó. Os procedimentos, critérios de aprovação e artefatos de evidência ficam no [guia de validação do HPA](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#hpa-e-capacidade).

## Consequências

A API escala dentro da capacidade disponível sem depender da criação de outra máquina. A decisão exige métricas válidas e requests coerentes; pods podem ficar Pending quando falta capacidade. O HPA não escala o banco nem elimina o ponto único de falha de um cluster com um único worker.

## Histórico da decisão

O registro original de 27/09/2026 descrevia mínimo de duas réplicas, alvo de memória de 75% e uma possibilidade de escala de nós. A revisão de 15/10/2026 mantém a decisão de usar HPA e registra a configuração entregue: mínimo 1, máximo 3 e CPU a 70%. As referências anteriores permanecem aqui como histórico, não como configuração vigente ou funcionalidade entregue.

## Referências

- [operação e validação do HPA](https://github.com/techdgconsulting/oficina-dgcar-infra-k8s/blob/homolog/README.md#hpa-e-capacidade).
- [RFC-004 — Observabilidade](../rfc/RFC-004-observabilidade-new-relic.md).
- Infraestrutura: `k8s/hpa.yaml`, `k8s/deployment.yaml`, `terraform/hpa.tf`, `terraform/node-pod-capacity.py` e `scripts/hpa/`.
- API: `.github/workflows/app-cd.yml`.
