#!/usr/bin/env bash
set -euo pipefail

vpc_id="${1:-}"
region="${AWS_REGION:-us-east-1}"

if [ -z "$vpc_id" ]; then
  echo "Usage: $0 vpc-id"
  exit 2
fi

echo "Limpando dependencias removiveis da VPC $vpc_id."

classic_lbs="$(aws elb describe-load-balancers \
  --region "$region" \
  --query "LoadBalancerDescriptions[?VPCId=='$vpc_id'].LoadBalancerName" \
  --output text)"
for lb_name in $classic_lbs; do
  echo "Removendo Classic Load Balancer $lb_name."
  aws elb delete-load-balancer --region "$region" --load-balancer-name "$lb_name"
done

v2_lbs="$(aws elbv2 describe-load-balancers \
  --region "$region" \
  --query "LoadBalancers[?VpcId=='$vpc_id'].LoadBalancerArn" \
  --output text)"
for lb_arn in $v2_lbs; do
  echo "Removendo ELBv2 $lb_arn."
  aws elbv2 delete-load-balancer --region "$region" --load-balancer-arn "$lb_arn"
done

endpoint_ids="$(aws ec2 describe-vpc-endpoints \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "VpcEndpoints[*].VpcEndpointId" \
  --output text)"
if [ -n "$endpoint_ids" ]; then
  echo "Removendo VPC endpoints: $endpoint_ids."
  aws ec2 delete-vpc-endpoints --region "$region" --vpc-endpoint-ids $endpoint_ids >/dev/null
fi

sleep 30

sg_ids="$(aws ec2 describe-security-groups \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "SecurityGroups[?GroupName!='default' && (starts_with(GroupName, 'k8s-elb-') || starts_with(GroupName, 'eks-cluster-sg-') || contains(Description, 'Kubernetes ELB') || contains(Description, 'EKS created security group'))].GroupId" \
  --output text)"

for sg_id in $sg_ids; do
  enis="$(aws ec2 describe-network-interfaces \
    --region "$region" \
    --filters "Name=group-id,Values=$sg_id" \
    --query "NetworkInterfaces[*].NetworkInterfaceId" \
    --output text)"

  if [ -z "$enis" ]; then
    echo "Removendo security group residual $sg_id."
    aws ec2 delete-security-group --region "$region" --group-id "$sg_id" || true
  else
    echo "Security group $sg_id preservado porque ainda possui ENIs: $enis."
  fi
done
