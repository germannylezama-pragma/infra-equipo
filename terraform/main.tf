# Infra de un equipo distinto (serverless) para demostrar que el pipeline
# central sirve para cualquier repo. Tiene malas configuraciones A PROPÓSITO.

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  name = "pagos-${var.environment}"
  tags = {
    Project     = "infra-equipo"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# --- Datos -----------------------------------------------------------------

resource "aws_dynamodb_table" "transacciones" {
  name           = "${local.name}-transacciones"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamodb_rcu
  write_capacity = var.dynamodb_wcu
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # ⚠️ sin point_in_time_recovery ni cifrado con llave propia (KMS)
  tags = local.tags
}

# --- Mensajería ------------------------------------------------------------

resource "aws_sqs_queue" "eventos" {
  name = "${local.name}-eventos"
  # ⚠️ sin cifrado (kms_master_key_id / sqs_managed_sse_enabled)
  tags = local.tags
}

# --- Cómputo ---------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name = "${local.name}-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "${local.name}-lambda"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*" # ⚠️ permisos totales
      Resource = "*"
    }]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${local.name}-procesador"
  # ⚠️ sin retention_in_days ni kms_key_id
  tags = local.tags
}

resource "aws_lambda_function" "procesador" {
  function_name = "${local.name}-procesador"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.12"
  handler       = "app.handler"
  filename      = "${path.module}/build/lambda.zip"
  memory_size   = var.lambda_memory_mb
  timeout       = 30

  environment {
    variables = {
      TABLE = aws_dynamodb_table.transacciones.name
      QUEUE = aws_sqs_queue.eventos.url
    }
  }

  # ⚠️ sin tracing X-Ray, sin dead letter queue, sin límite de concurrencia
  depends_on = [aws_cloudwatch_log_group.lambda]
  tags       = local.tags
}
