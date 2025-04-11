#!/bin/bash

set -e

# ========== CONFIG ========== #
AMI_ID="ami-0100e595e1cc1ff7f" # Amazon Linux 2 (adjust per region)
INSTANCE_TYPE="t3.micro"
IAM_INSTANCE_PROFILE="EC2SSMRole" # IAM role name for EC2 instances
KEY_NAME="testkey" # Updated Key Pair name

# ========== IAM ROLE & POLICIES ========== #

# Check if IAM Role exists
EXISTING_ROLE=$(aws iam get-role --role-name $IAM_INSTANCE_PROFILE --query 'Role.RoleName' --output text || echo "")

if [ -z "$EXISTING_ROLE" ]; then
    echo "The IAM role $IAM_INSTANCE_PROFILE does not exist. Creating it..."

    # Trust Policy
    TRUST_POLICY='{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }'

    # Create IAM Role
    aws iam create-role --role-name $IAM_INSTANCE_PROFILE --assume-role-policy-document "$TRUST_POLICY"

    # Attach the necessary policies for EC2 and SSM access
    aws iam attach-role-policy --role-name $IAM_INSTANCE_PROFILE --policy-arn arn:aws:iam::aws:policy/AmazonEC2RoleforSSM
    aws iam attach-role-policy --role-name $IAM_INSTANCE_PROFILE --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore

    echo "IAM role $IAM_INSTANCE_PROFILE created and necessary policies attached."
else
    echo "IAM role $IAM_INSTANCE_PROFILE already exists."
fi

# ========== VPC CREATION ========== #
REQ_VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
ACC_VPC_ID=$(aws ec2 create-vpc --cidr-block 10.1.0.0/16 --query 'Vpc.VpcId' --output text)

aws ec2 modify-vpc-attribute --vpc-id $REQ_VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $REQ_VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $ACC_VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $ACC_VPC_ID --enable-dns-hostnames

# ========== SUBNETS ========== #
REQ_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $REQ_VPC_ID --cidr-block 10.0.1.0/24 --query 'Subnet.SubnetId' --output text)
ACC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $ACC_VPC_ID --cidr-block 10.1.1.0/24 --query 'Subnet.SubnetId' --output text)

aws ec2 modify-subnet-attribute --subnet-id $REQ_SUBNET_ID --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $ACC_SUBNET_ID --map-public-ip-on-launch

# ========== INTERNET GATEWAYS ========== #
REQ_IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
ACC_IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)

aws ec2 attach-internet-gateway --internet-gateway-id $REQ_IGW_ID --vpc-id $REQ_VPC_ID
aws ec2 attach-internet-gateway --internet-gateway-id $ACC_IGW_ID --vpc-id $ACC_VPC_ID

# ========== ROUTE TABLES ========== #
REQ_RT_ID=$(aws ec2 create-route-table --vpc-id $REQ_VPC_ID --query 'RouteTable.RouteTableId' --output text)
ACC_RT_ID=$(aws ec2 create-route-table --vpc-id $ACC_VPC_ID --query 'RouteTable.RouteTableId' --output text)

aws ec2 create-route --route-table-id $REQ_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $REQ_IGW_ID
aws ec2 create-route --route-table-id $ACC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $ACC_IGW_ID

aws ec2 associate-route-table --route-table-id $REQ_RT_ID --subnet-id $REQ_SUBNET_ID
aws ec2 associate-route-table --route-table-id $ACC_RT_ID --subnet-id $ACC_SUBNET_ID

# ========== VPC PEERING ========== #
PEER_ID=$(aws ec2 create-vpc-peering-connection \
  --vpc-id $REQ_VPC_ID \
  --peer-vpc-id $ACC_VPC_ID \
  --query 'VpcPeeringConnection.VpcPeeringConnectionId' --output text)

aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id $PEER_ID

# Add peering routes
aws ec2 create-route --route-table-id $REQ_RT_ID --destination-cidr-block 10.1.0.0/16 --vpc-peering-connection-id $PEER_ID
aws ec2 create-route --route-table-id $ACC_RT_ID --destination-cidr-block 10.0.0.0/16 --vpc-peering-connection-id $PEER_ID

# Enable DNS resolution for peering
aws ec2 modify-vpc-peering-connection-options \
  --vpc-peering-connection-id $PEER_ID \
  --accepter-peering-connection-options '{"AllowDnsResolutionFromRemoteVpc":true}' \
  --requester-peering-connection-options '{"AllowDnsResolutionFromRemoteVpc":true}'

# ========== SECURITY GROUP ========== #
SG_ID=$(aws ec2 create-security-group \
  --group-name VPCPeeringSG \
  --description "Allow ICMP, SSH, and SSM" \
  --vpc-id $REQ_VPC_ID \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol icmp --port -1 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-id $SG_ID \
  --protocol tcp --port 22 --cidr 0.0.0.0/0

# ========== EC2 INSTANCES (SSM + SSH) ========== #
REQ_EC2_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --iam-instance-profile Name=$IAM_INSTANCE_PROFILE \
  --subnet-id $REQ_SUBNET_ID \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Requester-EC2}]" \
  --query 'Instances[0].InstanceId' --output text)

ACC_EC2_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --iam-instance-profile Name=$IAM_INSTANCE_PROFILE \
  --subnet-id $ACC_SUBNET_ID \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Accepter-EC2}]" \
  --query 'Instances[0].InstanceId' --output text)

# ========== DONE ========== #
echo ""
echo "🎉 Setup Complete"
echo "Requester VPC: $REQ_VPC_ID | Subnet: $REQ_SUBNET_ID | EC2: $REQ_EC2_ID"
echo "Accepter  VPC: $ACC_VPC_ID | Subnet: $ACC_SUBNET_ID | EC2: $ACC_EC2_ID"
echo "VPC Peering Connection ID: $PEER_ID"
