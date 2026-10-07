#!/usr/bin/env bash
set -euo pipefail

region="${AWS_REGION:-us-east-1}"
vpc_id="${1:-}"
shift || true

if [ -z "$vpc_id" ]; then
  echo "Usage: $0 vpc-id sg-... [sg-...]"
  exit 2
fi

for sg_id in "$@"; do
  if [ -z "$sg_id" ]; then
    continue
  fi

  if [[ ! "$sg_id" =~ ^sg-[0-9a-fA-F]+$ ]]; then
    echo "::error::Security group invalido: $sg_id."
    exit 1
  fi

  sg_vpc="$(aws ec2 describe-security-groups \
    --region "$region" \
    --group-ids "$sg_id" \
    --query 'SecurityGroups[0].VpcId' \
    --output text)"

  if [ "$sg_vpc" != "$vpc_id" ]; then
    echo "::error::Security group $sg_id pertence a $sg_vpc, nao a $vpc_id."
    exit 1
  fi

  echo "Security group $sg_id validado na VPC $vpc_id."
done
