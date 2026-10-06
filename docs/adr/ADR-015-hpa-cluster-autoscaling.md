# ADR-015: HPA E Estrategia De Escalabilidade Do Cluster

**Status:** Aceito  
**Data:** 2026-09-27  
**Autor:** Diego Gonzalez  
**Contexto do Projeto:** Sistema de Oficina Mecanica DGCar - Pos-graduacao FIAP

## Contexto

O projeto ja possui um Horizontal Pod Autoscaler para a aplicacao `oficina-api`, com metricas de CPU e memoria. O novo desafio reforca a necessidade de escalabilidade e alta disponibilidade em Kubernetes.

## Decisao

Manter HPA como mecanismo principal de escalabilidade horizontal da aplicacao e documentar a diferenca entre:

- **HPA:** escala a quantidade de pods da aplicacao conforme metricas de CPU/memoria.
- **Cluster Autoscaling / Node Scaling:** escala capacidade de nos do cluster quando os pods nao encontram recursos suficientes.

Nesta fase, o HPA permanece como decisao arquitetural permanente e o Cluster Autoscaling fica como evolucao recomendada para ambientes de maior carga.

## Configuracao Alvo Do HPA

| Item | Valor |
|---|---:|
| Minimo de replicas | 2 |
| Maximo de replicas | 3 |
| Target de CPU | 70% |
| Target de memoria | 75% |
| Janela de scale up | 60s |
| Janela de scale down | 300s |

## Justificativa

- Atende requisito de cluster Kubernetes com escalabilidade.
- Permite absorver aumento de carga na aplicacao.
- Mantem disponibilidade minima com mais de uma replica.
- Usa `resources.requests` do Deployment para calculo de utilizacao.
- Ja possui roteiro operacional de evidencia no projeto.

## Consequencias Positivas

- Escala automatica da API sob carga.
- Evidencia operacional clara para demonstracao.
- Menor intervencao manual durante variacao de demanda.
- Base para evoluir para autoscaling de nos.

## Consequencias Negativas

- Depende do Metrics Server.
- Nao escala o banco de dados.
- Se o node group nao tiver capacidade, novos pods podem ficar pendentes.
- Targets incorretos podem gerar escala excessiva ou insuficiente.

## Cluster Autoscaling

O Cluster Autoscaling devera ser avaliado nas proximas fases caso o ambiente precise aumentar capacidade de nodes automaticamente. Para a entrega academica, a decisao minima e demonstravel e manter HPA funcional e documentado.

## Relacao Com Outros Documentos

- `docs/infraestrutura/hpa-operacional.md`: roteiro de validacao e evidencias.
- `k8s/hpa.yaml`: manifesto declarativo do HPA.
- `RFC-004`: observabilidade com New Relic para acompanhar escalabilidade.
