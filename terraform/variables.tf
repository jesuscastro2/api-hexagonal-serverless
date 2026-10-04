variable "aws_region" {
  description = "Región de AWS donde se desplegará la aplicación"
  type        = string
}

variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "database_url" {
  description = "URL JDBC de PostgreSQL/Neon"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Usuario de PostgreSQL/Neon"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña de PostgreSQL/Neon"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Clave secreta utilizada para firmar los JWT"
  type        = string
  sensitive   = true
}