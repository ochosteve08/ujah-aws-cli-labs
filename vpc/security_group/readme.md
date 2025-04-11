

📦 Create Stack (Basic EC2 Instance with security group)

```
 aws cloudformation create-stack \
  --stack-name sg-ec2-instance-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```


📄 Describe Stack

```bash
aws cloudformation describe-stacks \
  --stack-name sg-ec2-instance-stack
```

Describes your current CloudFormation stack's status and outputs.


❌ Delete Stack

```
 aws cloudformation delete-stack \
  --stack-name sg-ec2-instance-stack
```
