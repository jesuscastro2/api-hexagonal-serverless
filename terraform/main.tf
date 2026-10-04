# ============================================================
# S3 - Bucket para almacenar el JAR de Lambda
# ============================================================

resource "aws_s3_bucket" "lambda_bucket" {
  bucket_prefix = "api-hexagonal-lambda-"

  tags = {
    Name        = "API Hexagonal Lambda"
    Environment = "serverless"
  }
}

# Subir el JAR generado por Maven
resource "aws_s3_object" "lambda_jar" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "api-hexagonal.jar"
  source = "${path.module}/../target/api-0.0.1-SNAPSHOT.jar"

  etag = filemd5("${path.module}/../target/api-0.0.1-SNAPSHOT.jar")
}

# ============================================================
# IAM - Role para Lambda
# ============================================================

resource "aws_iam_role" "lambda_role" {
  name = "api-hexagonal-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Permisos básicos para escribir logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ============================================================
# Lambda
# ============================================================

resource "aws_lambda_function" "api" {
  function_name = var.lambda_function_name

  role = aws_iam_role.lambda_role.arn

  runtime = "java21"

  handler = "com.example.api.LambdaHandler::handleRequest"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_jar.key

  source_code_hash = filebase64sha256("${path.module}/../target/api-0.0.1-SNAPSHOT.jar")

  memory_size = 1024
  timeout     = 30

  environment {
    variables = {
      DATABASE_URL = var.database_url
      DB_USERNAME  = var.db_username
      DB_PASSWORD  = var.db_password
      JWT_SECRET   = var.jwt_secret
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution
  ]

  tags = {
    Name        = "API Hexagonal"
    Environment = "serverless"
  }
}

# ============================================================
# CloudWatch Logs
# ============================================================

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

# ============================================================
# API Gateway HTTP API
# ============================================================

resource "aws_apigatewayv2_api" "api" {
  name          = "api-hexagonal"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]

    allow_methods = [
      "GET",
      "POST",
      "PUT",
      "DELETE",
      "OPTIONS"
    ]

    allow_headers = [
      "Content-Type",
      "Authorization"
    ]
  }
}

# Integración API Gateway -> Lambda
resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.api.id

  integration_type = "AWS_PROXY"

  integration_uri = aws_lambda_function.api.invoke_arn

  payload_format_version = "2.0"
}

# Ruta general para nuestra API
resource "aws_apigatewayv2_route" "default" {
  api_id = aws_apigatewayv2_api.api.id

  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Ruta raíz
resource "aws_apigatewayv2_route" "root" {
  api_id = aws_apigatewayv2_api.api.id

  route_key = "ANY /"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Stage automático
resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.api.id

  name = "$default"

  auto_deploy = true
}

# Permiso para que API Gateway invoque Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowAPIGatewayInvoke"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.api.function_name

  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}