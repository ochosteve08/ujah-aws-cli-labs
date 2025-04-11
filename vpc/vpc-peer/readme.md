

### 🛠️ **Stack Operations**

#### 📦 Create Stack

```
aws cloudformation create-stack \
  --stack-name VPCPeeringWithSubnets \
  --template-body file://vpc-peering-full.yml \
  --capabilities CAPABILITY_NAMED_IAM

```



📄 Describe Stack

```
aws cloudformation describe-stacks \
  --stack-name VPCPeeringWithEC2s

```



❌ Delete Stack


```
aws cloudformation delete-stack --stack-name VPCPeeringWithEC2s

```


```
chmod +x vpc-peering-ssm.sh
./vpc-peering-ssm.sh

```



```
chmod +x vpc-peering-teardown.sh
./vpc-peering-teardown.sh

```
