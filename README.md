# Terraform mono-repo (Dev/Prod + Modules)

my-terraform/
├─ dev/
├─ prod/
├─ modules/
│  ├─ stack/
│  ├─ vpc/
│  ├─ s3/
│  ├─ cloudfront/
│  ├─ route53/
│  ├─ eks/
│  └─ alb/

Usage:
  cd my-terraform/dev && terraform init && terraform apply
  cd my-terraform/prod && terraform init && terraform apply
