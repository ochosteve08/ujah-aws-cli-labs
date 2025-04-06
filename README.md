# AWS CLI Labs 🚀

A hands-on repository for building and managing various AWS services using the **Command Line Interface (CLI)**. This project is aimed at reinforcing practical knowledge of AWS services via automation and scripting.

## 📁 Repository Structure

Each folder represents a specific AWS service or lab:

```
aws-cli-labs/
│
├── ec2/                 # Launching and managing EC2 instances via CLI
├── s3/                  # Working with S3 buckets and objects
├── iam/                 # IAM users, roles, and policies via CLI
├── vpc/                 # Creating and managing custom VPCs
├── rds/                 # RDS instance setup and configuration
├── cloudwatch/          # Logs, metrics, and alarms via CLI
├── lambda/              # Deploying serverless functions via CLI
└── README.md
```

> All examples are based on best practices and assume basic knowledge of AWS CLI and shell scripting.

---

## 🛠️ Prerequisites

- AWS CLI v2 installed and configured
- Valid IAM user credentials with required permissions
- Basic knowledge of Bash or PowerShell

---

## ⚙️ How to Use

1. Clone the repository:

   ```bash
   git clone https://github.com/ochosteve08/ujah-aws-cli-labs.git

   ```
2. Navigate to any lab folder and follow the `README.md` or `instructions.md` inside:

   ```bash
   cd ec2
   bash create-instance.sh
   ```
3. Clean up resources after testing:

   ```bash
   bash delete-instance.sh
   ```

---

## 🎯 Goals

- Build cloud infrastructure programmatically
- Understand AWS service dependencies and automation
- Prepare for certification (e.g., AWS Solutions Architect, SysOps)
- Use CLI as an alternative to the console for DevOps-style workflows

---

## 📘 References

- [AWS CLI Official Docs](https://docs.aws.amazon.com/cli/)
- [AWS CLI Examples](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [jq JSON Processor](https://stedolan.github.io/jq/)

---

## ✍️ Author

**Ujah Stephen Ocheola**
Network Engineer | Cloud & DevOps Enthusiast
[LinkedIn](https://www.linkedin.com/in/ujah-stephen/) | [Email](mailto:stephenujah@yahoo.com)

---

## 📄 License

MIT License. Feel free to fork, contribute, and share!
