#!/bin/bash

set -e

echo "🔍 Fetching resource IDs..."

# Retrieve VPCs based on CIDRs (adjust if needed)
REQ_VPC_ID=$(aws ec2 describe-vpcs --filters Name=cidr,Values=10.0.0.0/16 --query 'Vpcs[0].VpcId' --output text)
ACC_VPC_ID=$(aws ec2 describe-vpcs --filters Name=cidr,Values=10.1.0.0/16 --query 'Vpcs[0].VpcId' --output text)

# Subnets
REQ_SUBNET_ID=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$REQ_VPC_ID --query 'Subnets[0].SubnetId' --output text)
ACC_SUBNET_ID=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$ACC_VPC_ID --query 'Subnets[0].SubnetId' --output text)

# Route Tables (excluding main)
REQ_RT_ID=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$REQ_VPC_ID \
  --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId" --output text)

ACC_RT_ID=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$ACC_VPC_ID \
  --query "RouteTables[?Associations[?Main==\`false\`]].RouteTableId" --output text)

# Internet Gateways
REQ_IGW_ID=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$REQ_VPC_ID --query 'InternetGateways[0].InternetGatewayId' --output text)
ACC_IGW_ID=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$ACC_VPC_ID --query 'InternetGateways[0].InternetGatewayId' --output text)

# VPC Peering
PEER_ID=$(aws ec2 describe-vpc-peering-connections \
  --filters Name=requester-vpc-info.vpc-id,Values=$REQ_VPC_ID \
  --query 'VpcPeeringConnections[0].VpcPeeringConnectionId' --output text)

# Security Group (optional cleanup)
SG_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$REQ_VPC_ID Name=group-name,Values=VPCPeeringSG --query 'SecurityGroups[0].GroupId' --output text)

# EC2 Instances
REQ_EC2_ID=$(aws ec2 describe-instances --filters Name=vpc-id,Values=$REQ_VPC_ID Name=tag:Name,Values=Requester-EC2 --query 'Reservations[0].Instances[0].InstanceId' --output text)
ACC_EC2_ID=$(aws ec2 describe-instances --filters Name=vpc-id,Values=$ACC_VPC_ID Name=tag:Name,Values=Accepter-EC2 --query 'Reservations[0].Instances[0].InstanceId' --output text)

# IAM Role Cleanup (for EC2 access)
IAM_ROLE_NAME="EC2SSMRole"
ROLE_EXISTS=$(aws iam get-role --role-name $IAM_ROLE_NAME --query 'Role.RoleName' --output text || echo "None")

# Check if EC2 instance IDs are valid before terminating
if [[ "$REQ_EC2_ID" != "None" && "$ACC_EC2_ID" != "None" ]]; then
  echo "⚠️ Terminating EC2 instances..."
  aws ec2 terminate-instances --instance-ids $REQ_EC2_ID $ACC_EC2_ID
  aws ec2 wait instance-terminated --instance-ids $REQ_EC2_ID $ACC_EC2_ID
else
  echo "⚠️ One or both EC2 instances do not exist. Skipping termination."
fi

echo "🔌 Deleting routes, detaching IGWs..."
aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --route-table-ids $REQ_RT_ID --query 'RouteTables[0].Associations[0].RouteTableAssociationId' --output text) || true
aws ec2 disassociate-route-table --association-id $(aws ec2 describe-route-tables --route-table-ids $ACC_RT_ID --query 'RouteTables[0].Associations[0].RouteTableAssociationId' --output text) || true

aws ec2 delete-route-table --route-table-id $REQ_RT_ID
aws ec2 delete-route-table --route-table-id $ACC_RT_ID

aws ec2 detach-internet-gateway --internet-gateway-id $REQ_IGW_ID --vpc-id $REQ_VPC_ID
aws ec2 detach-internet-gateway --internet-gateway-id $ACC_IGW_ID --vpc-id $ACC_VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $REQ_IGW_ID
aws ec2 delete-internet-gateway --internet-gateway-id $ACC_IGW_ID

echo "🔁 Deleting VPC Peering Connection..."
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $PEER_ID

echo "🧹 Deleting Subnets, Security Groups, VPCs..."
aws ec2 delete-subnet --subnet-id $REQ_SUBNET_ID
aws ec2 delete-subnet --subnet-id $ACC_SUBNET_ID

if [ "$SG_ID" != "None" ]; then
  aws ec2 delete-security-group --group-id $SG_ID
fi

aws ec2 delete-vpc --vpc-id $REQ_VPC_ID
aws ec2 delete-vpc --vpc-id $ACC_VPC_ID

# IAM Role and Policies Cleanup
if [ "$ROLE_EXISTS" != "None" ]; then
  echo "🛠️ Deleting IAM role and associated policies..."

  # Detach policies from role
  aws iam detach-role-policy --role-name $IAM_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2RoleforSSM
  aws iam detach-role-policy --role-name $IAM_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
  
  # Delete the IAM role
  aws iam delete-role --role-name $IAM_ROLE_NAME
  echo "IAM Role $IAM_ROLE_NAME and policies deleted."
else
  echo "IAM Role $IAM_ROLE_NAME does not exist, skipping deletion."
fi

echo "✅ Cleanup Complete!"
