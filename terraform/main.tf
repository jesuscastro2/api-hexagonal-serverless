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

  source_hash = filebase64sha256(
    "${path.module}/../target/api-0.0.1-SNAPSHOT.jar"
  )
}

# ============================================================
# IAM - Role para Lambda principal
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
# Lambda principal - API Spring Boot
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
      DATABASE_URL  = var.database_url
      DB_USERNAME   = var.db_username
      DB_PASSWORD   = var.db_password
      JWT_SECRET    = var.jwt_secret
      SNS_TOPIC_ARN = aws_sns_topic.notifications.arn
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
# CloudWatch Logs - Lambda principal
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

  name        = "$default"
  auto_deploy = true
}

# Permiso para que API Gateway invoque Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id = "AllowAPIGatewayInvoke"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# ============================================================
# SNS - Topic de notificaciones
# ============================================================

resource "aws_sns_topic" "notifications" {
  name = "notifications-topic"

  tags = {
    Name        = "Notifications Topic"
    Environment = "serverless"
  }
}

# ============================================================
# SQS - Cola de notificaciones
# ============================================================

resource "aws_sqs_queue" "notifications" {
  name = "notifications-queue"

  # Debe ser al menos 6 veces el timeout de la Lambda consumidora.
  visibility_timeout_seconds = 180
  message_retention_seconds  = 345600

  tags = {
    Name        = "Notifications Queue"
    Environment = "serverless"
  }
}

# ============================================================
# Política SQS - Permitir que el Topic SNS publique en la cola
# ============================================================

resource "aws_sqs_queue_policy" "notifications" {
  queue_url = aws_sqs_queue.notifications.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowSNSPublish"
        Effect = "Allow"

        Principal = {
          Service = "sns.amazonaws.com"
        }

        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.notifications.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.notifications.arn
          }
        }
      }
    ]
  })
}

# ============================================================
# Suscripción SNS -> SQS
# ============================================================

resource "aws_sns_topic_subscription" "notifications_sqs" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.notifications.arn

  depends_on = [
    aws_sqs_queue_policy.notifications
  ]
}

# ============================================================
# IAM - Permitir a la Lambda principal publicar en SNS
# ============================================================

resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.notifications.arn
      }
    ]
  })
}

# ============================================================
# IAM - Role para notification-lambda
# ============================================================

resource "aws_iam_role" "notification_lambda_role" {
  name = "notification-lambda-role"

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

# Permisos básicos para CloudWatch Logs
resource "aws_iam_role_policy_attachment" "notification_lambda_basic" {
  role       = aws_iam_role.notification_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permisos para consumir SQS y enviar correo con SES
resource "aws_iam_role_policy" "notification_lambda_policy" {
  name = "notification-lambda-policy"
  role = aws_iam_role.notification_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = aws_sqs_queue.notifications.arn
      },
      {
        Effect = "Allow"

        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]

        Resource = "*"
      }
    ]
  })
}

# ============================================================
# CloudWatch Logs - notification-lambda
# ============================================================

resource "aws_cloudwatch_log_group" "notification_lambda_logs" {
  name              = "/aws/lambda/notification-lambda"
  retention_in_days = 7
}

# ============================================================
# Empaquetar el código Python de notification-lambda
# Requiere hashicorp/archive declarado en provider.tf.
# ============================================================

data "archive_file" "notification_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../notification-lambda/lambda_function.py"
  output_path = "${path.module}/notification-lambda.zip"
}

# ============================================================
# Lambda de Notificaciones
# ============================================================

resource "aws_lambda_function" "notification" {
  function_name = "notification-lambda"

  role    = aws_iam_role.notification_lambda_role.arn
  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.notification_lambda_zip.output_path
  source_code_hash = data.archive_file.notification_lambda_zip.output_base64sha256

  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      FROM_EMAIL = var.notification_from_email
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.notification_lambda_basic,
    aws_cloudwatch_log_group.notification_lambda_logs
  ]

  tags = {
    Name        = "Notification Lambda"
    Environment = "serverless"
  }
}

# ============================================================
# Event Source Mapping - SQS -> notification-lambda
# ============================================================


resource "aws_lambda_event_source_mapping" "notifications" {
  event_source_arn = aws_sqs_queue.notifications.arn
  function_name    = aws_lambda_function.notification.arn

  batch_size              = 1
  function_response_types = ["ReportBatchItemFailures"]
  enabled                 = true

  depends_on = [
    aws_iam_role_policy.notification_lambda_policy,
    aws_sns_topic_subscription.notifications_sqs
  ]
}
