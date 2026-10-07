#!/usr/bin/env bash
set -euo pipefail

environment="${1:-homolog}"
region="${AWS_REGION:-us-east-1}"
name="oficina-dgcar-${environment}-vpc"

aws ec2 describe-vpcs \
  --region "$region" \
  --filters "Name=tag:Name,Values=$name" "Name=tag:Project,Values=oficina-dgcar" "Name=tag:Environment,Values=$environment" \
  --query 'Vpcs[0].VpcId // ``' \
  --output text
