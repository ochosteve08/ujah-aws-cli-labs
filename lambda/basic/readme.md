
---

## 🛠️ AWS Lambda Deployment with Bash Script (via AWS CLI)

This project demonstrates how to automate the deployment of a basic AWS Lambda function using a Bash script and AWS CLI.

### 📦 Overview

The Bash script automates the following steps:

1. **Creates an IAM Role** with the necessary trust policy.
2. **Attaches AWSLambdaBasicExecutionRole** permissions to the role.
3. **Zips a Python Lambda function** (`lambda_function.py`) using PowerShell (Windows/Git Bash friendly).
4. **Creates the Lambda function** with runtime set to Python 3.12.
5. **Invokes the Lambda function** and saves the output in `response.json`.

### 📁 Project Structure

```
.
├── lambda_function.py       # Your Python Lambda function
├── deploy.sh                # Bash script to automate deployment
├── trust-policy.json        # IAM trust relationship policy
├── lambda_function.zip      # Zipped Lambda package (auto-generated)
└── response.json            # Output of Lambda invocation (auto-generated)
```

### ✅ Prerequisites

* AWS CLI configured with valid credentials
* Git Bash / WSL / Linux terminal
* Python file named `lambda_function.py`
* Internet access for API calls to AWS

### 🚀 Usage

Run the deployment script from your terminal:

```bash
./deploy.sh
```

This will:

* Create the IAM role and attach permissions
* Package your function
* Deploy it to Lambda
* Invoke it once and store the response in `response.json`

### 📌 Notes

* Ensure your handler function in `lambda_function.py` is named `lambda_handler`.
* The default function name is `myBasicLambda`, but you can modify it inside the script.
* The script uses `powershell.exe` for zipping on Windows Git Bash—modify if using Linux or Mac.

---
