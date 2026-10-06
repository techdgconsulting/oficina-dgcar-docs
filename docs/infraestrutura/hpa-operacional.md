# Evidencia Operacional Do Horizontal Pod Autoscaler

Este documento complementa os manifests Kubernetes e registra como validar a configuracao e o comportamento do Horizontal Pod Autoscaler (HPA) no cluster EKS.

## Objetivo

Demonstrar, de forma reprodutivel, que a API `oficina-api` possui escalabilidade horizontal configurada no Kubernetes e que o autoscaling responde a metricas de CPU e memoria coletadas no cluster.

## Artefatos Envolvidos

| Artefato | Finalidade |
|---|---|
| `k8s/deployment.yaml` | Define o Deployment alvo do HPA, probes e requests/limits de CPU e memoria. |
| `k8s/hpa.yaml` | Define o HPA `oficina-api`, limites de replicas, metricas e comportamento de scale up/down. |
| `k8s/kustomization.yaml` | Inclui o HPA no conjunto aplicado por `kubectl apply -k k8s`. |
| `README.md` | Contem o roteiro manual de deploy e validacao no EKS. |

## Configuracao Atual

| Item | Valor | Evidencia |
|---|---:|---|
| API do recurso | `autoscaling/v2` | `k8s/hpa.yaml` |
| Alvo de escala | `Deployment/oficina-api` | `spec.scaleTargetRef` |
| Minimo de replicas | `2` | `spec.minReplicas` |
| Maximo de replicas | `3` | `spec.maxReplicas` |
| Target de CPU | `70%` | `metrics.resource.cpu.averageUtilization` |
| Target de memoria | `75%` | `metrics.resource.memory.averageUtilization` |
| Janela de scale up | `60s` | `behavior.scaleUp.stabilizationWindowSeconds` |
| Janela de scale down | `300s` | `behavior.scaleDown.stabilizationWindowSeconds` |

O `Deployment` tambem declara requests e limits, requisito pratico para o HPA calcular utilizacao relativa de recursos:

```yaml
resources:
  requests:
    cpu: 250m
    memory: 512Mi
  limits:
    cpu: 500m
    memory: 768Mi
```

## Pre-Requisitos Para O HPA Funcionar

1. Cluster EKS ativo e acessivel via `kubectl`.
2. Namespace `oficina` criado.
3. `Deployment/oficina-api` em estado `Available`.
4. Metrics Server instalado e retornando metricas.
5. Manifests aplicados com `kubectl apply -k k8s`.

Validacao dos pre-requisitos:

```bash
kubectl get nodes
kubectl get deployment oficina-api -n oficina
kubectl get pods -n oficina
kubectl top nodes
kubectl top pods -n oficina
```

Se `kubectl top` nao retornar metricas, instale ou valide o Metrics Server antes do teste:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl rollout status deployment/metrics-server -n kube-system
kubectl top nodes
```

## Evidencia 1 - HPA Criado No Cluster

Com os manifests aplicados:

```bash
kubectl apply -k k8s
kubectl get hpa oficina-api -n oficina
kubectl describe hpa oficina-api -n oficina
```

Saida esperada em `kubectl get hpa`:

```text
NAME          REFERENCE                TARGETS            MINPODS   MAXPODS   REPLICAS
oficina-api   Deployment/oficina-api   <cpu%>/<mem%>      2         3         2
```

Critério de aceite:

- `REFERENCE` aponta para `Deployment/oficina-api`.
- `MINPODS` e `MAXPODS` aparecem como `2` e `3`.
- `REPLICAS` inicia em `2` depois da estabilizacao.
- `TARGETS` deixa de aparecer como `<unknown>` quando o Metrics Server esta funcional.

## Evidencia 2 - Scale Up Sob Carga Controlada

Para demonstracao, reduza temporariamente o target de CPU para facilitar o acionamento do HPA:

```bash
kubectl patch hpa oficina-api -n oficina --type merge -p '{"spec":{"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":5}}},{"type":"Resource","resource":{"name":"memory","target":{"type":"Utilization","averageUtilization":75}}}]}}'
```

Gere carga interna contra o Service da API:

```bash
kubectl run hpa-load -n oficina --image=busybox:1.36 --restart=Never -- /bin/sh -c 'for i in $(seq 1 80); do while true; do wget -q -O- http://oficina-api/actuator/health >/dev/null; done & done; sleep 300'
```

No Git Bash do Windows, use:

```bash
MSYS_NO_PATHCONV=1 kubectl run hpa-load -n oficina --image=busybox:1.36 --restart=Never -- /bin/sh -c 'for i in $(seq 1 80); do while true; do wget -q -O- http://oficina-api/actuator/health >/dev/null; done & done; sleep 300'
```

Acompanhe o comportamento:

```bash
kubectl get hpa oficina-api -n oficina -w
kubectl get pods -n oficina -w
```

Saida esperada:

```text
NAME          REFERENCE                TARGETS      MINPODS   MAXPODS   REPLICAS
oficina-api   Deployment/oficina-api   12%/75%      2         3         3
```

Critério de aceite:

- A quantidade de replicas sobe de `2` para `3`.
- Um terceiro pod `oficina-api-*` fica em `Running`.
- O Deployment permanece disponivel durante o scale up.

## Evidencia 3 - Scale Down E Restauracao

Ao final do teste, remova a carga e restaure a configuracao normal:

```bash
kubectl delete pod hpa-load -n oficina --ignore-not-found
kubectl patch hpa oficina-api -n oficina --type merge -p '{"spec":{"minReplicas":2,"maxReplicas":3,"metrics":[{"type":"Resource","resource":{"name":"cpu","target":{"type":"Utilization","averageUtilization":70}}},{"type":"Resource","resource":{"name":"memory","target":{"type":"Utilization","averageUtilization":75}}}]}}'
kubectl get hpa oficina-api -n oficina
```

Depois da janela de estabilizacao de scale down (`300s`), a quantidade de replicas deve retornar para `2`, desde que nao exista carga relevante.

Critério de aceite:

- O pod de carga foi removido.
- O target de CPU voltou para `70%`.
- `REPLICAS` estabiliza em `2`.

## Evidencias

```bash
kubectl get hpa oficina-api -n oficina
kubectl describe hpa oficina-api -n oficina
kubectl top pods -n oficina
kubectl get deployment oficina-api -n oficinas
kubectl get pods -n oficina
```


## Observacao Arquitetural

O HPA escala a camada de aplicacao, nao o banco de dados. Como o projeto usa RDS PostgreSQL gerenciado, a escalabilidade da API melhora a capacidade de atendimento HTTP, enquanto limites de conexao, pooling e capacidade do banco continuam sendo responsabilidades de configuracao e observabilidade da camada de dados.
