

### ✅ **CloudFormation + EC2 + SSM + Apache + NACL Automation Lab**

This lab demonstrates the use of AWS CloudFormation to provision EC2 instances, configure networking via NACLs, enable SSM access, and automate Apache server installation using `UserData`.

---

### 🛠️ **Stack Operations**

#### 📦 Create Stack (Basic EC2 Instance)

```bash
aws cloudformation create-stack \
  --stack-name my-ec2-instance-stack \
  --template-body file://template.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

Creates an EC2 instance with basic IAM and networking setup.

#### 📄 Describe Stack

```bash
aws cloudformation describe-stacks \
  --stack-name my-ec2-instance-stack
```

Describes your current CloudFormation stack's status and outputs.

#### ❌ Delete Stack

```bash
aws cloudformation delete-stack \
  --stack-name my-ec2-instance-stack
```

Tears down the provisioned resources.

---

### 🌐 **Advanced Networking and Apache Setup**

#### 🧱 EC2 + NACL Setup

```bash
aws cloudformation create-stack \
  --stack-name my-nacl-ec2-instance-stack \
  --template-body file://nacl-ec2.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

Launches an EC2 instance in a subnet with Network ACLs applied.

#### 🔥 EC2 + NACL + Apache

```bash
aws cloudformation create-stack \
  --stack-name nacl-ec2-apache-instance-stack \
  --template-body file://nacl-ec2-apache.yml \
  --capabilities CAPABILITY_NAMED_IAM
```

Creates an EC2 instance in a subnet with custom NACL rules and installs Apache using `UserData`.

---

### 🛰️ **EC2 + Apache + SSM + Public IP + ALB**

```bash
aws cloudformation create-stack \
  --stack-name apache-ssm-lab \
  --template-body file://ec2-ssm-alb.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameters ParameterKey=VpcId,ParameterValue=vpc-xxxx \
               ParameterKey=SubnetId,ParameterValue=subnet-private \
               ParameterKey=PublicSubnetId,ParameterValue=subnet-public
```

**Stack Features:**

* Launches an EC2 instance (Ubuntu) with Apache pre-installed
* Enables access via **AWS Systems Manager Session Manager (SSM)**
* Attaches an **IAM Role** with `AmazonSSMManagedInstanceCore` policy
* Assigns a **public IP** for external reachability
* Creates an **Application Load Balancer (ALB)** to serve HTTP traffic
* Writes a simple HTML homepage to `/var/www/html/index.html`

---

Let me know if you'd like to split this into folders (e.g. `ec2/`, `nacl/`, `ssm-alb/`) or version your templates in the readme.
