#!/usr/bin/env bash
set -euo pipefail

region="${AWS_REGION:-us-east-1}"

missing=()
for key in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
  if [ -z "${!key:-}" ]; then
    missing+=("$key")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "::error::Secrets AWS ausentes: ${missing[*]}."
  exit 1
fi

account_id="$(aws sts get-caller-identity --query Account --output text --region "$region")"
echo "Credenciais AWS validadas na conta $account_id em $region."
