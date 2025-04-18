
# 📘 Exploring Amazon OpenSearch Service with IPv6-Enabled VPC

This guide walks you through the  **minimum setup required to explore Amazon OpenSearch Service** , specifically when **IPv6 is required** for domain creation within a VPC.

---

## 🎯 Objective

Create an Amazon OpenSearch Service domain in a VPC **with IPv6 enabled** to resolve the following error:

> ❌ `IPv6CIDRBlockNotFoundForSubnet: VPC subnet does not have IPv6 CIDR assigned to it. Please assign IPv6 CIDR to the subnet.`

---

## 🛠 Prerequisites

* AWS CLI configured with appropriate permissions
* Existing **VPC** and **subnet** (or create new)
* IAM permissions for:

  `ec2:*`, `opensearch:*`, `iam:PassRole`, `iam:GetRole`
* Optional: S3 bucket for OpenSearch snapshots

---

## ⚙️ Step 1: Enable IPv6 for the VPC

```bash
aws ec2 associate-vpc-cidr-block \
  --vpc-id vpc-0a55ce42c45c2c211 \
  --amazon-provided-ipv6-cidr-block
```

---

## 🔍 Step 2: Retrieve the IPv6 CIDR Block

```bash
aws ec2 describe-vpcs \
  --vpc-ids vpc-0a55ce42c45c2c211 \
  --query "Vpcs[].Ipv6CidrBlockAssociationSet[].Ipv6CidrBlock" \
  --output text
```

Expected output (example):

```text
2600:1f16:e43:8b00::/56
```

---

## 📤 Step 3: Assign a /64 IPv6 CIDR to the Subnet

Pick a `/64` range from your VPC’s `/56` block:

```bash
aws ec2 associate-subnet-cidr-block \
  --subnet-id subnet-09c82d8f0c19e14c1 \
  --ipv6-cidr-block 2600:1f16:e43:8b00::/64
```

---

## ✅ Step 4: Enable IPv6 Assignment on Subnet

Ensure instances/services launched in this subnet get IPv6 automatically:

```bash
aws ec2 modify-subnet-attribute \
  --subnet-id subnet-09c82d8f0c19e14c1 \
  --assign-ipv6-address-on-creation
```

---

## 🔐 Step 5: Create a Security Group

Create and configure a security group that allows HTTPS (port 443) access:

```bash
aws ec2 create-security-group \
  --group-name OpenSearchSG \
  --description "Allow HTTPS for OpenSearch" \
  --vpc-id vpc-0a55ce42c45c2c211
```

Authorize inbound access for IPv6 traffic:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxxxxx \
  --protocol tcp \
  --port 443 \
  --cidr 2600:1f16:e43:8b00::/64
```

---

## 🧠 Step 6: Create the OpenSearch Domain

```bash
aws opensearch create-domain \
  --domain-name explore-opensearch \
  --engine-version OpenSearch_2.11 \
  --cluster-config InstanceType=t3.small.search,InstanceCount=1 \
  --vpc-options SubnetIds=["subnet-09c82d8f0c19e14c1"],SecurityGroupIds=["sg-xxxxxxxxxxxx"] \
  --ebs-options EBSEnabled=true,VolumeSize=10 \
  --access-policies file://access-policy.json
```

 **Example access policy (`access-policy.json`)** :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-2:533267247137:domain/explore-opensearch/*"
    }
  ]
}
```

> 🔒 Tip: Use your own IAM ARN instead of `"*"` for restricted access.

---

## 🔎 Step 7: Access Your Domain

```bash
aws opensearch describe-domain \
  --domain-name explore-opensearch \
  --query "DomainStatus.Endpoint"
```

Use the returned endpoint in a browser or with `curl`.

---

## 🧼 Optional Cleanup

```bash
aws opensearch delete-domain --domain-name explore-opensearch
```

---

## ✅ Summary

| ✅ Task                           | Status |
| --------------------------------- | ------ |
| VPC IPv6 CIDR block assigned      | ✅     |
| Subnet IPv6 /64 block associated  | ✅     |
| IPv6 assignment enabled on subnet | ✅     |
| Security group for HTTPS created  | ✅     |
| OpenSearch domain created         | ✅     |

---

Let me know if you'd like this turned into a deployable script or CloudFormation template.
