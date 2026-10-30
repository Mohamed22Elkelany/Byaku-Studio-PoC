output "task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}