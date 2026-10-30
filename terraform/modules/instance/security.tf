resource "aws_iam_instance_profile" "this" {
  name = "${var.instance_name}-iam-profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name = "${var.instance_name}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  #managed_policy_arns = var.iam_permissions
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.iam_permissions)

  role       = aws_iam_role.this.name
  policy_arn = var.iam_permissions[count.index]
}
