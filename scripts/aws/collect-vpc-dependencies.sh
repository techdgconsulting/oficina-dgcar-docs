#!/usr/bin/env bash
set -euo pipefail

vpc_id="${1:-}"
region="${AWS_REGION:-us-east-1}"

if [ -z "$vpc_id" ]; then
  echo "Usage: $0 vpc-id"
  exit 2
fi

echo "## Dependencias da VPC $vpc_id"

echo "### ENIs"
aws ec2 describe-network-interfaces \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "NetworkInterfaces[*].{Id:NetworkInterfaceId,Status:Status,Description:Description,RequesterManaged:RequesterManaged,Subnet:SubnetId,Groups:Groups[*].GroupId}" \
  --output table

echo "### Security Groups"
aws ec2 describe-security-groups \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "SecurityGroups[*].{Id:GroupId,Name:GroupName,Description:Description}" \
  --output table

echo "### Load Balancers V2"
aws elbv2 describe-load-balancers \
  --region "$region" \
  --query "LoadBalancers[?VpcId=='$vpc_id'].{Arn:LoadBalancerArn,Name:LoadBalancerName,State:State.Code}" \
  --output table

echo "### Classic Load Balancers"
aws elb describe-load-balancers \
  --region "$region" \
  --query "LoadBalancerDescriptions[?VPCId=='$vpc_id'].{Name:LoadBalancerName,DNS:DNSName}" \
  --output table

echo "### NAT Gateways"
aws ec2 describe-nat-gateways \
  --region "$region" \
  --filter "Name=vpc-id,Values=$vpc_id" \
  --query "NatGateways[*].{Id:NatGatewayId,State:State,Subnet:SubnetId}" \
  --output table

echo "### VPC Endpoints"
aws ec2 describe-vpc-endpoints \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "VpcEndpoints[*].{Id:VpcEndpointId,State:State,Service:ServiceName}" \
  --output table

echo "### Internet Gateways"
aws ec2 describe-internet-gateways \
  --region "$region" \
  --filters "Name=attachment.vpc-id,Values=$vpc_id" \
  --query "InternetGateways[*].{Id:InternetGatewayId,Attachments:Attachments}" \
  --output table

echo "### Subnets"
aws ec2 describe-subnets \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "Subnets[*].{Id:SubnetId,State:State,Cidr:CidrBlock,Az:AvailabilityZone}" \
  --output table

echo "### Route Tables"
aws ec2 describe-route-tables \
  --region "$region" \
  --filters "Name=vpc-id,Values=$vpc_id" \
  --query "RouteTables[*].{Id:RouteTableId,Associations:Associations[*].RouteTableAssociationId}" \
  --output table
