

---

### 🛠️ **CloudFormation & IAM CLI Operations for IAM User**

#### 📦 Create Stack (No Parameters)

Deploys the CloudFormation stack to create the IAM user when no parameter (like `InitialPassword`) is defined in the template.

```bash
aws cloudformation create-stack \
  --stack-name iam-user-stack \
  --template-body file://iam-user.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

#### 🔄 Update Stack (With Parameters)

Updates an existing IAM user stack where the template expects a parameter (e.g., `InitialPassword` for the `LoginProfile`).

```bash
aws cloudformation update-stack \
  --stack-name iam-user-stack \
  --template-body file://iam-user.yaml \
  --parameters ParameterKey=InitialPassword,ParameterValue="YourNewSecurePassword123!" \
  --capabilities CAPABILITY_NAMED_IAM
```

#### 🔍 Describe Stack

Displays the current state and outputs of the deployed stack.

```bash
aws cloudformation describe-stacks \
  --stack-name iam-user-stack
```

---

### 🔐 **Attach Inline Policy to IAM User**

Attaches an inline IAM policy to the user `engineer`, granting access to a specific S3 bucket.

```bash
aws iam put-user-policy \
  --user-name engineer \
  --policy-name EngineerS3BucketAccess \
  --policy-document file://s3-access-policy.json
```

---

### ❌ **Detach/Delete Inline Policy from IAM User**

Removes the attached inline policy from the user `engineer`.

```bash
aws iam delete-user-policy \
  --user-name engineer \
  --policy-name EngineerS3BucketAccess
```

---

### 🗑️ **Delete CloudFormation Stack**

Deletes the entire stack and its resources (e.g., the IAM user).

```bash
aws cloudformation delete-stack \
  --stack-name iam-user-stack
```

---
