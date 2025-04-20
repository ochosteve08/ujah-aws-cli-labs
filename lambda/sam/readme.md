
```markdown
# AWS Lambda Deployment using AWS SAM and AWS CLI

This project demonstrates how to deploy an AWS Lambda function using the AWS Serverless Application Model (SAM) and AWS CLI with CloudFormation.

## 📦 Project Structure

```

lambda-sam/
├── src/                  # Lambda function source code
│   └── index.js
├── template.yaml         # SAM template defining Lambda and related resources
├── payload.json          # JSON input for testing Lambda
├── deploy.sh             # Bash script to invoke the Lambda


```

---

## 🧰 Prerequisites

- **AWS CLI v2** installed and configured  
  Check version:
  ```bash
  aws --version
```

* **AWS SAM CLI** installed

  Check version:

  ```bash
  sam --version
  ```
* Node.js installed (for Node-based Lambda)

---

## 🚀 Deploying the Lambda Function

### 1. **Build your SAM application**

```bash
sam build
```

### 2. **Deploy with guided setup (first time)**

```bash
sam deploy --guided
```

This command will:

* Package your Lambda
* Upload it to S3
* Create a CloudFormation stack
* Deploy the Lambda function

You will be prompted to enter:

* Stack name
* AWS region
* S3 bucket for deployment artifacts
* Whether to allow SAM to create IAM roles

---

## 🧪 Testing the Lambda Function

### 1. **Prepare your test payload**

`payload.json`

```json
{
  "name": "Alice",
  "age": 30
}
```

### 2. **Invoke using AWS CLI**

```bash
aws lambda invoke \
  --function-name <YOUR_LAMBDA_FUNCTION_NAME> \
  --cli-binary-format raw-in-base64-out \
  --payload file://payload.json \
  response.json
```

Replace `<YOUR_LAMBDA_FUNCTION_NAME>` with the one generated from the `sam deploy` output.

### 3. **Check the Response**

```bash
cat response.json
```

---

## 📌 Useful Commands

* **Validate your template**
  ```bash
  sam validate
  ```
* **Delete your deployed stack**
  ```bash
  aws cloudformation delete-stack --stack-name <your-stack-name>
  ```

---

## 📚 Resources

* [AWS SAM Documentation](https://docs.aws.amazon.com/serverless-application-model/index.html)
* [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
* [AWS CLI Lambda Commands](https://docs.aws.amazon.com/cli/latest/reference/lambda/index.html)

---

## 🧑‍💻 Author

Ujah Stephen Ocheola
