# ECS execution and task roles:
# <name>-<service>-execution / -task and <name>-migration-execution / -task.
# Execution roles pull only their own image, write only their own log group and
# read only the secrets mapped to their service.
locals {
  # Secrets (env var -> secret suffix) injected into each task family.
  app_secret_env = {
    backend = {
      ADMIN_DATABASE_URL         = "admin-database-url"
      ADMIN_FIELD_ENCRYPTION_KEY = "admin-field-encryption-key"
      ADMIN_JWT_SECRET           = "admin-jwt-secret"
      AGENT_TOKEN_PEPPER         = "agent-token-pepper"
      DATABASE_URL               = "database-url"
      FIELD_ENCRYPTION_KEY       = "field-encryption-key"
      INTERNAL_API_SECRET        = "internal-api-secret"
      JWT_SECRET                 = "jwt-secret"
    }
    integrations = {
      DATABASE_URL         = "database-url"
      FIELD_ENCRYPTION_KEY = "field-encryption-key"
      INTERNAL_API_SECRET  = "internal-api-secret"
    }
    db-migrate       = { DATABASE_URL = "database-url" }
    admin-db-migrate = { ADMIN_DATABASE_URL = "admin-database-url" }
  }

  # Execution role -> images, log groups and secrets it may use.
  ecs_execution_roles = {
    web          = { repos = ["web"], logs = ["web"], secrets = [] }
    admin-web    = { repos = ["admin-web"], logs = ["admin-web"], secrets = [] }
    ai           = { repos = ["ai"], logs = ["ai"], secrets = [] }
    backend      = { repos = ["backend"], logs = ["backend"], secrets = values(local.app_secret_env.backend) }
    integrations = { repos = ["integrations"], logs = ["integrations"], secrets = values(local.app_secret_env.integrations) }
    migration = {
      repos   = ["db-migrate", "admin-db-migrate"]
      logs    = ["db-migrate", "admin-db-migrate"]
      secrets = ["database-url", "admin-database-url"]
    }
  }
}

data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  for_each = local.ecs_execution_roles

  name               = "${local.name}-${each.key}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

data "aws_iam_policy_document" "ecs_execution" {
  for_each = local.ecs_execution_roles

  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "PullOwnImages"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [for repo in each.value.repos : module.ecr[repo].repository_arn]
  }

  statement {
    sid       = "WriteOwnLogs"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [for group in each.value.logs : "${aws_cloudwatch_log_group.app[group].arn}:*"]
  }

  dynamic "statement" {
    for_each = length(each.value.secrets) > 0 ? [1] : []
    content {
      sid       = "ReadMappedSecrets"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [for suffix in distinct(each.value.secrets) : aws_secretsmanager_secret.app[suffix].arn]
    }
  }

  dynamic "statement" {
    for_each = length(each.value.secrets) > 0 ? [1] : []
    content {
      sid       = "DecryptMappedSecrets"
      actions   = ["kms:Decrypt"]
      resources = [aws_kms_key.secrets.arn]

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["secretsmanager.${var.aws_region}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role_policy" "ecs_execution" {
  for_each = local.ecs_execution_roles

  name   = "runtime-bootstrap"
  role   = aws_iam_role.ecs_execution[each.key].id
  policy = data.aws_iam_policy_document.ecs_execution[each.key].json
}

# Task roles: application identity inside the container. They carry no permissions
# yet; Bedrock (bedrock.tf, commented out), EFS, S3 report and SES statements are
# added with those resources in a later phase.
resource "aws_iam_role" "ecs_task" {
  for_each = local.ecs_execution_roles

  name               = "${local.name}-${each.key}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}
