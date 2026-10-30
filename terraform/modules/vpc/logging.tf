######################################################
##             Logging                              ##
######################################################
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "${var.vpc_name}-flow-logs-log-group"
  retention_in_days = var.vpc_flow_logs_retention_in_days

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-flow-logs-log-group"
  })
}

resource "aws_flow_log" "main" {
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn

  # Custom log format: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html#flow-logs-custom
  log_format = var.vpc_flow_logs_log_format

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-flow-logs"
  })
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.default_tags, var.tags, {
    Name = "${var.vpc_name}-flow-logs-role"
  })
}

resource "aws_iam_policy" "vpc_flow_logs" {
  name        = "${var.vpc_name}-flow-logs-policy"
  description = "VPC Flow Logs required permissions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs" {
  role       = aws_iam_role.vpc_flow_logs.name
  policy_arn = aws_iam_policy.vpc_flow_logs.arn
}