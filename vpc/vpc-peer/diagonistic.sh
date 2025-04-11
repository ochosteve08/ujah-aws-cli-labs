#!/bin/bash

# === Replace with your EC2 instance IDs ===
REQ_EC2_ID="i-015d3a57fb3f21c2d"
ACC_EC2_ID="i-0ecd5c4fbc5d053fd"

echo "🔎 Checking EC2 Instance Connect prerequisites..."

for INSTANCE_ID in $REQ_EC2_ID $ACC_EC2_ID; do
  echo ""
  echo "➡️ Instance ID: $INSTANCE_ID"

  PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

  echo "🌐 Public IP: $PUBLIC_IP"
  if [[ $PUBLIC_IP == "None" || $PUBLIC_IP == "null" ]]; then
    echo "❌ No Public IP assigned. EC2 Instance Connect will NOT work."
  else
    echo "✅ Public IP present"
  fi

  SG_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" --output text)

  echo "🛡️ Security Group ID: $SG_ID"
  echo "🔐 Checking if port 22 is open..."
  aws ec2 describe-security-groups --group-ids $SG_ID \
    --query "SecurityGroups[0].IpPermissions[?ToPort==\`22\`]" --output table

  SUBNET_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].SubnetId" --output text)

  echo "🧱 Subnet ID: $SUBNET_ID"
  echo "📡 Checking route table associated with this subnet..."
  RT_ID=$(aws ec2 describe-route-tables \
    --filters Name=association.subnet-id,Values=$SUBNET_ID \
    --query "RouteTables[0].RouteTableId" --output text)

  echo "🔁 Route Table ID: $RT_ID"
  aws ec2 describe-route-tables --route-table-ids $RT_ID \
    --query "RouteTables[0].Routes" --output table

  echo "✅ Done with $INSTANCE_ID"
done

echo ""
echo "🔐 NOTE: Ensure your IAM role/user has 'ec2-instance-connect:SendSSHPublicKey' permission"
