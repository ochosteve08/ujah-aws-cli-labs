

### 🛠️ CloudFormation **Stack Operations**

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

```
aws cloudformation describe-stack-events --stack-name VPCPeeringWithSubnets

```


❌ Delete Stack


```
aws cloudformation delete-stack --stack-name VPCPeeringWithSubnets

```


```
chmod u+x vpc-peering-script.sh
./vpc-peering-script.sh

```



```
chmod +x vpc-peering-teardown.sh
./vpc-peering-teardown.sh

```




🛠️ AWS Console **Operations**

* create 2 vpc
* ```
  aws ec2 create-vpc-peering-connection \
      --vpc-id vpc-0e8c1d640922215c1 \
      --peer-vpc-id vpc-0cdd4fc9f443a7e7f \
      --peer-region us-east-2 \
      --tag-specifications "ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=Requester-to-Accepter}]"

  ```
* Confirm the Peering Request

Check the status of the peering connection using the following command:

```
aws ec2 describe-vpc-peering-connections --query 'VpcPeeringConnections[*].{ID:VpcPeeringConnectionId,Status:Status.Code}'

```

* Accept the VPC Peering Connection

Once the peering request is initiated, it needs to be accepted by the accepter VPC. You can accept it via the command:

```
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id pcx-0b57982e5fa88d17c

```


* Update Route Tables

Once the VPC peering connection is established, you need to update the route tables in both VPCs to allow traffic to route through the peering connection.

* For  **Requester VPC** , add a route to the Accepter VPC's CIDR block.
* For  **Accepter VPC** , add a route to the Requester VPC's CIDR block.

```
aws ec2 create-route --route-table-id <Requester-RouteTable-ID> \
    --destination-cidr-block <Accepter-VPC-CIDR> \
    --vpc-peering-connection-id <Peering-Connection-ID>

```



```
aws ec2 create-route --route-table-id <Accepter-RouteTable-ID> \
    --destination-cidr-block <Requester-VPC-CIDR> \
    --vpc-peering-connection-id <Peering-Connection-ID>

```
