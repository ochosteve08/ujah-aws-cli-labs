


```
aws cloudformation create-stack \
  --stack-name iam-user-stack \
  --template-body file://iam-user.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```


```
aws cloudformation update-stack \
  --stack-name iam-user-stack \
  --template-body file://iam-user.yaml \
  --parameters ParameterKey=InitialPassword,ParameterValue="YourNewSecurePassword123!" \ 
  --capabilities CAPABILITY_NAMED_IAM
```


```


```



```
aws cloudformation describe-stacks \
  --stack-name iam-user-stack

```
