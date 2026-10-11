
# ============================================================
# API Gateway
# ============================================================

output "api_gateway_url" {
  description = "URL pública de API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

# ============================================================
# Lambda Principal
# ============================================================

output "lambda_function_name" {
  description = "Nombre de la función Lambda principal"
  value       = aws_lambda_function.api.function_name
}

output "lambda_role_name" {
  description = "Nombre del IAM Role utilizado por Lambda"
  value       = aws_iam_role.lambda_role.name
}

# ============================================================
# S3
# ============================================================

output "s3_bucket_name" {
  description = "Bucket S3 utilizado para el JAR de Lambda"
  value       = aws_s3_bucket.lambda_bucket.id
}

# ============================================================
# CloudWatch - Lambda Principal
# ============================================================

output "cloudwatch_log_group" {
  description = "Grupo de logs de CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

# ============================================================
# SNS
# ============================================================

output "sns_topic_arn" {
  description = "ARN del SNS Topic de notificaciones"
  value       = aws_sns_topic.notifications.arn
}

# ============================================================
# SQS
# ============================================================

output "sqs_queue_url" {
  description = "URL de la cola SQS"
  value       = aws_sqs_queue.notifications.id
}

output "sqs_queue_arn" {
  description = "ARN de la cola SQS"
  value       = aws_sqs_queue.notifications.arn
}

# ============================================================
# Lambda de Notificaciones
# ============================================================

output "notification_lambda_name" {
  description = "Nombre de la Lambda de notificaciones"
  value       = aws_lambda_function.notification.function_name
}

output "notification_lambda_arn" {
  description = "ARN de la Lambda de notificaciones"
  value       = aws_lambda_function.notification.arn
}

output "notification_lambda_role_name" {
  description = "IAM Role de la Lambda de notificaciones"
  value       = aws_iam_role.notification_lambda_role.name
}

# ============================================================
# CloudWatch - Lambda de Notificaciones
# ============================================================

output "notification_cloudwatch_log_group" {
  description = "Grupo de logs de notification-lambda"
  value       = aws_cloudwatch_log_group.notification_lambda_logs.name
}
