# Byaku Studio PoC Infrastructure

Terraform for the Byaku Studio PoC platform in **Ireland (eu-west-1)**, deployed to
the **Byaku-Studio-PoC** AWS account (711695043680) as a single `poc` environment.

## Layout

```text
terraform/
  backend/poc.tfvars         # S3 state backend
  environment/poc.tfvars     # environment inputs
  modules/                   # shared modules
.github/
  workflows/infra-cicd.yml   # pipeline
```

## Scope

| Area | Resources | Files |
| --- | --- | --- |
| Networking | VPC 10.0.0.0/16, 2 public + 5 private subnets (`app` tier in 2 AZs, `data` tier in 3 AZs), IGW, one shared NAT gateway, flow logs, S3 gateway endpoint | `vpc.tf`, `vpc_endpoints.tf` |
| Edge | Internet-facing ALB with host-based routing, regional WAF attached to the ALB, wildcard ACM certificate `*.byaku-studio.com` | `alb.tf`, `waf.tf`, `acm.tf` |
| Containers | ECS cluster `byaku-poc-cluster` with 5 services (web, admin-web, backend, ai, integrations), 8 task families incl. migrations and release smoke, per-service IAM/log groups/security groups, `byaku.internal` service discovery; 7 ECR repositories `byaku-poc/<service>`; 8 Secrets Manager containers `byaku-poc/<secret>` | `ecs.tf`, `ecs_tasks.tf`, `ecs_iam.tf`, `ecr.tf`, `secrets.tf`, `kms.tf` |
| Data | RDS PostgreSQL 16 `byaku-poc-core` (database `byaku`) and `byaku-poc-admin` (database `byaku_admin`), db.m8g.large Multi-AZ (Barmous production sizing), 100 GiB gp3 (autoscaling to 200 GiB), 14-day backups, created empty, RDS-managed master passwords | `rds.tf` |
| Baseline | CloudTrail (multi-region account trail), GuardDuty, AWS Config, Security Hub, CloudWatch alarms + SNS alerting, Budgets | `cloudtrail.tf`, `guard_duty.tf`, `aws_config.tf`, `security_hub.tf`, `cloudwatch.tf`, `sns.tf`, `budgets.tf` |

All resources carry the default tags from `main.tf`, including the partner tag
`aws-apn-id = pc:2yqdbavm3n3awa2b98r83k3bd`.

### Deferred (commented out)

- **Amazon Bedrock** (`bedrock.tf`, `var.bedrock_models`): out of scope for the
  PoC. Uncomment both and add the `BEDROCK_*` variables back to the backend
  environment in `ecs_tasks.tf` when the backend starts calling models.
- S3 storage and CloudFront (`S3_bucket.tf`, `cloudfront.tf`), ElastiCache
  (`elastic_cache.tf`) and CloudWatch dashboards (`cloudwatch.tf`).
- Application CI/CD (GitHub OIDC roles for the application repository): to be added
  once the Byaku application repository is known.

### HTTPS (two stages)

DNS for `byaku-studio.com` is hosted on Cloudflare.

1. `https_enabled = false` (current): the ACM certificate `*.byaku-studio.com` is
   requested and the ALB serves HTTP on port 80, routing `app.`, `api.` and `admin.`
   (admin only from `admin_allowed_cidrs`, VPC CIDR by default) by host header.
2. Add the CNAME from the `acm_certificate_validation_records` output to the
   Cloudflare zone (**DNS only**, not proxied). When `acm_certificate_status` is
   `ISSUED`, set `https_enabled = true` and apply: an HTTPS listener is added and
   port 80 redirects to 443.

Then point `app`, `api` and `admin` at the `alb_dns_name` output (proxied CNAMEs)
and set Cloudflare SSL/TLS to **Full (strict)**; Flexible would loop on the
HTTP to HTTPS redirect.

### Application

- Services start at 0 tasks until images are pushed to ECR (tag `bootstrap` for the
  initial task definition revisions); afterwards the release pipeline owns task
  definition revisions and desired counts (Terraform ignores that drift).
- Secret values are set outside Terraform in `byaku-poc/<secret>`.
- RDS master passwords are RDS-managed secrets (`rds_master_user_secret_arns`
  output). Automatic rotation is disabled because the `database-url` secrets embed
  the credentials (see the comment in `rds.tf`).

## Pipeline

`.github/workflows/infra-cicd.yml` runs three jobs:

1. `static_code_checks`: `terraform fmt -check` and `terraform validate` (no AWS access).
2. `plan`: plans `poc` and uploads the plan as an artifact (`terraform-plan-poc`).
3. `apply`: runs on push to `main` (or a manual run on `main`).

Pull requests only run the checks and the plan. The jobs authenticate through
GitHub OIDC with the role in the repository secret `AWS_ROLE_ARN_POC`; that role
(and the account's GitHub OIDC provider) still has to be created in the account
and must allow this repository's subjects. Jobs run on the org `self-hosted` runners.

## Prerequisites

- The S3 state bucket `byaku-tf-poc-711695043680` (eu-west-1, versioned, encrypted,
  public access blocked) exists.

## Local usage

```bash
cd terraform
terraform init -backend-config=backend/poc.tfvars -reconfigure
terraform plan -var-file=environment/poc.tfvars -var aws_profile=<profile>
```
