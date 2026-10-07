#!/usr/bin/env bash
set -euo pipefail

repo="${1:-}"
environment="${2:-}"
name="${3:-}"
value="${4:-}"

if [ -z "$repo" ] || [ -z "$environment" ] || [ -z "$name" ]; then
  echo "Usage: $0 owner/repo environment SECRET_NAME secret-value"
  exit 2
fi

if [ -z "${GH_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN nao configurado."
  exit 1
fi

gh secret set "$name" --repo "$repo" --env "$environment" --body "$value"
echo "$name publicado em $repo/$environment."
