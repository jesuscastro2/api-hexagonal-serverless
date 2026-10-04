output "api_gateway_url" {
  description = "URL pública de API Gateway"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_function_name" {
  description = "Nombre de la función Lambda"
  value       = aws_lambda_function.api.function_name
}

output "lambda_role_name" {
  description = "Nombre del IAM Role utilizado por Lambda"
  value       = aws_iam_role.lambda_role.name
}

output "s3_bucket_name" {
  description = "Bucket S3 utilizado para el JAR de Lambda"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "cloudwatch_log_group" {
  description = "Grupo de logs de CloudWatch"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}