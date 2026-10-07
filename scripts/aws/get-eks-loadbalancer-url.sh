#!/usr/bin/env bash
set -euo pipefail

cluster_name="${1:-}"
namespace="${2:-oficina}"
service="${3:-oficina-api}"
region="${AWS_REGION:-us-east-1}"

if [ -z "$cluster_name" ]; then
  echo "Usage: $0 eks-cluster-name [namespace] [service]"
  exit 2
fi

aws eks update-kubeconfig --region "$region" --name "$cluster_name" >/dev/null

for attempt in $(seq 1 30); do
  hostname="$(kubectl get svc "$service" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"
  ip="$(kubectl get svc "$service" -n "$namespace" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  backend="${hostname:-$ip}"

  if [ -n "$backend" ]; then
    echo "http://$backend"
    exit 0
  fi

  echo "Aguardando LoadBalancer $namespace/$service ($attempt/30)." >&2
  sleep 10
done

echo "::error::LoadBalancer $namespace/$service nao publicou endpoint."
exit 1
