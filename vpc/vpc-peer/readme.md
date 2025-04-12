

# 🛠️ AWS CloudFormation Stack Operations for VPC Peering with EC2

This guide provides step-by-step instructions and scripts to manage CloudFormation stacks and VPC peering connections using AWS CLI.

---

## 📦 CloudFormation Stack Commands

### ✅ Create Stack

```bash
aws cloudformation create-stack \
  --stack-name VPCPeeringWithSubnets \
  --template-body file://vpc-peering-full.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

---

### 📄 Describe Stack

```bash
aws cloudformation describe-stacks \
  --stack-name VPCPeeringWithSubnets
```

```bash
aws cloudformation describe-stack-events \
  --stack-name VPCPeeringWithSubnets
```

---

### ❌ Delete Stack

```bash
aws cloudformation delete-stack \
  --stack-name VPCPeeringWithSubnets
```

---

## 🔧 Run Automation Scripts

Make scripts executable and run them:

```bash
chmod +x vpc-peering-script.sh
./vpc-peering-script.sh
```

```bash
chmod +x vpc-peering-teardown.sh
./vpc-peering-teardown.sh
```

---

## 🖥️ AWS Console/CLI Manual Operations

### Step 1: Create Two VPCs (Requester and Accepter)

---

### Step 2: Create VPC Peering Connection

```bash
aws ec2 create-vpc-peering-connection \
  --vpc-id vpc-0e8c1d640922215c1 \
  --peer-vpc-id vpc-0cdd4fc9f443a7e7f \
  --peer-region us-east-2 \
  --tag-specifications "ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=Requester-to-Accepter}]"
```

---

### Step 3: Confirm Peering Request

```bash
aws ec2 describe-vpc-peering-connections \
  --query 'VpcPeeringConnections[*].{ID:VpcPeeringConnectionId,Status:Status.Code}'
```

---

### Step 4: Accept VPC Peering Connection

```bash
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id pcx-0b57982e5fa88d17c
```

---

### Step 5: Update Route Tables

#### For  **Requester VPC** :

```bash
aws ec2 create-route \
  --route-table-id <Requester-RouteTable-ID> \
  --destination-cidr-block <Accepter-VPC-CIDR> \
  --vpc-peering-connection-id <Peering-Connection-ID>
```

#### For  **Accepter VPC** :

```bash
aws ec2 create-route \
  --route-table-id <Accepter-RouteTable-ID> \
  --destination-cidr-block <Requester-VPC-CIDR> \
  --vpc-peering-connection-id <Peering-Connection-ID>
```

---

## 📦 Deploy EC2 Instances via CloudFormation

### Deploy EC2 in VPC A

```bash
aws cloudformation create-stack \
  --stack-name VPC-A-EC2 \
  --template-body file://vpc-a-ec2.yaml \
  --parameters ParameterKey=PeerAVPCSubnetId,ParameterValue=subnet-03801f13a4fe332a1 \
  --capabilities CAPABILITY_NAMED_IAM
```

### Update EC2 Stack in VPC A

```bash
aws cloudformation update-stack \
  --stack-name VPC-A-EC2 \
  --template-body file://vpc-a-ec2.yaml \
  --parameters ParameterKey=PeerAVPCSubnetId,ParameterValue=subnet-03801f13a4fe332a1 \
  --capabilities CAPABILITY_NAMED_IAM
```

---

### Deploy EC2 in VPC B

```bash
aws cloudformation create-stack \
  --stack-name VPC-B-EC2 \
  --template-body file://vpc-b-ec2.yaml \
  --parameters ParameterKey=PeerBVPCSubnetId,ParameterValue=subnet-0fbdacb66ac33379f \
  --capabilities CAPABILITY_NAMED_IAM
```

---
