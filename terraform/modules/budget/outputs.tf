output "budget_id" {
  description = "The ID of the AWS Budgets budget."
  value       = aws_budgets_budget.main.id
}

output "budget_name" {
  description = "The name of the AWS Budgets budget."
  value       = aws_budgets_budget.main.name
}

output "budget_limit_amount" {
  description = "The limit amount specified in the AWS Budgets budget."
  value       = aws_budgets_budget.main.limit_amount
}

output "budget_time_period_start" {
  description = "The start time of the time period for the AWS Budgets budget."
  value       = aws_budgets_budget.main.time_period_start
}

output "budget_time_period_end" {
  description = "The end time of the time period for the AWS Budgets budget."
  value       = aws_budgets_budget.main.time_period_end
}
