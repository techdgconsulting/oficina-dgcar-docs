#!/usr/bin/env bash
set -euo pipefail

environment="${1:-homolog}"
region="${AWS_REGION:-us-east-1}"
prefix="oficina-dgcar-${environment}"
failed=0

check_empty() {
  local label="$1"
  local value="$2"
  if [ -n "$value" ] && [ "$value" != "None" ]; then
    echo "::error::$label ainda existe: $value"
    failed=1
  else
    echo "$label removido."
  fi
}

vpc_ids="$(aws ec2 describe-vpcs --region "$region" --filters "Name=tag:Name,Values=${prefix}-vpc" --query 'Vpcs[*].VpcId' --output text)"
check_empty "VPC" "$vpc_ids"

eks_clusters="$(aws eks list-clusters --region "$region" --query "clusters[?contains(@, '${prefix}-eks')]" --output text)"
check_empty "EKS" "$eks_clusters"

rds_instances="$(aws rds describe-db-instances --region "$region" --query "DBInstances[?DBInstanceIdentifier=='${prefix}-postgres'].DBInstanceIdentifier" --output text 2>/dev/null || true)"
check_empty "RDS" "$rds_instances"

lambda_functions="$(aws lambda list-functions --region "$region" --query "Functions[?FunctionName=='${prefix}-auth-cpf'].FunctionName" --output text)"
check_empty "Lambda" "$lambda_functions"

apis="$(aws apigatewayv2 get-apis --region "$region" --query "Items[?Name=='${prefix}-api-gateway'].ApiId" --output text)"
check_empty "API Gateway" "$apis"

if [ "$failed" -ne 0 ]; then
  exit 1
fi

echo "Ambiente $environment removido da AWS."
