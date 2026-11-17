# AWS Infrastructure Automation with Terraform

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?logo=amazonaws&logoColor=white)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)

Provisions a complete two-tier AWS environment (networking, compute and a managed database) using **reusable Terraform modules**. Everything is defined as code, version-controlled and repeatable.

## Architecture

```
                         Internet
                            │
                    ┌───────▼────────┐
                    │ Internet GW    │
                    └───────┬────────┘
  VPC 10.0.0.0/16           │
  ┌─────────────────────────┼──────────────────────────────┐
  │  Public subnets (2 AZs) │                              │
  │   ┌──────────────┐  ┌───▼──────────┐                   │
  │   │ EC2 + Nginx  │  │ EC2 + Nginx  │   web-sg: 80 (all) │
  │   └──────┬───────┘  └──────┬───────┘           22 (your IP)
  │          │ 3306            │                           │
  │  Private subnets (2 AZs)   │                           │
  │   ┌────────▼───────────────▼─────┐                     │
  │   │   RDS MySQL 8.0 (encrypted)  │   db-sg: 3306 from web-sg only
  │   └──────────────────────────────┘                     │
  └────────────────────────────────────────────────────────┘
```

## Project structure

```
.
├── main.tf                    # Wires the modules together
├── variables.tf               # Input variables with validation
├── outputs.tf                 # Public IPs, URLs, RDS endpoint
├── providers.tf               # AWS provider, default tags, optional S3 backend
├── terraform.tfvars.example   # Sample values (copy to terraform.tfvars)
├── scripts/user_data.sh       # EC2 bootstrap: installs Nginx + status page
├── modules/
│   ├── vpc/                   # VPC, public/private subnets, IGW, route tables
│   ├── security-groups/       # Least-privilege web and DB security groups
│   ├── ec2/                   # Amazon Linux 2023 instances (IMDSv2, encrypted EBS)
│   └── rds/                   # MySQL in private subnets, not publicly accessible
└── .github/workflows/terraform.yml   # fmt + validate + tflint on every push
```

## Key features

- **Modular design.** Each layer is a separate module with its own inputs and outputs, so it can be reused across environments.
- **Security by default.** SSH is limited to one trusted IP. The database only accepts traffic from the web security group and is never public. EBS and RDS storage are encrypted, and IMDSv2 is enforced.
- **Secrets are kept out of Git.** The DB password is a `sensitive` variable passed through an environment variable, and `*.tfvars` and state files are git-ignored.
- **Cost-aware.** It uses free-tier-eligible `t3.micro` and `db.t3.micro`, with no NAT Gateway.
- **CI.** GitHub Actions checks formatting, validates the configuration and runs TFLint on every push.
- **Default tags.** Every resource is tagged with Project, Environment and ManagedBy.

## Usage

**Prerequisites:** Terraform 1.5 or later, an AWS account, AWS CLI configured (`aws configure`), and an EC2 key pair in your region.

```bash
# 1. Configure
cp terraform.tfvars.example terraform.tfvars   # edit allowed_ssh_cidr and key_name
export TF_VAR_db_password='YourStrongPassword123!'

# 2. Deploy
terraform init
terraform plan
terraform apply

# 3. Visit the URL printed in the outputs
terraform output web_urls

# 4. Tear down when finished (avoids charges)
terraform destroy
```

## What I learned

- Structuring Terraform into reusable modules with clear input/output contracts
- Designing a VPC with public and private tiers across multiple Availability Zones
- Using security-group-to-security-group rules for least-privilege access
- Handling secrets and state safely, including the remote S3 backend with DynamoDB locking
