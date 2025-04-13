

### 🛠️ **CloudFormation & IAM CLI Operations for IAM User**

---

#### 📦 Create Stack (No Parameters)

Deploys the CloudFormation stack to create the IAM user when the template does **not** require parameters (e.g., no `InitialPassword` in `LoginProfile`).

```bash
aws cloudformation create-stack \
  --stack-name iam-user-stack \
  --template-body file://iam-user.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

---

#### 🔄 Update Stack (With Parameters)

Updates the IAM user stack where the template expects a parameter (e.g., `InitialPassword` used in `LoginProfile`).

```bash
aws cloudformation update-stack \
  --stack-name iam-user-stack \
  --template-body file://iam-user.yaml \
  --parameters ParameterKey=InitialPassword,ParameterValue="YourNewSecurePassword123!" \
  --capabilities CAPABILITY_NAMED_IAM
```

---

#### 🔍 Describe Stack

Retrieves details about the stack including status and outputs.

```bash
aws cloudformation describe-stacks \
  --stack-name iam-user-stack
```

---

#### 🔐 Attach IAM Managed Policy

Attaches a **managed policy** (e.g., `ViewOnlyAccess`) to the IAM user.

```bash
aws iam attach-user-policy \
  --user-name engineer \
  --policy-arn arn:aws:iam::aws:policy/job-function/ViewOnlyAccess
```

---

#### 🔓 Detach IAM Managed Policy

Detaches a **managed policy** from the IAM user.

```bash
aws iam detach-user-policy \
  --user-name engineer \
  --policy-arn arn:aws:iam::aws:policy/job-function/ViewOnlyAccess
```

---

#### 📄 Attach Inline Policy (Custom)

Attaches a **custom inline policy** from a local file (e.g., `s3-access-policy.json`).

```bash
aws iam put-user-policy \
  --user-name engineer \
  --policy-name EngineerS3BucketAccess \
  --policy-document file://s3-access-policy.json
```

---

### 🧹 **Detach/Delete Inline Policy from IAM User**

Removes the attached inline policy from the user `engineer`.

```bash
aws iam delete-user-policy \
  --user-name engineer \
  --policy-name EngineerS3BucketAccess
```

---

#### ❌ Delete Stack

Deletes the CloudFormation stack and all its resources.

```bash
aws cloudformation delete-stack \
  --stack-name iam-user-stack
```

---
