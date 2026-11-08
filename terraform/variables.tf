variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "dynamodb_rcu" {
  type    = number
  default = 5
}

variable "dynamodb_wcu" {
  type    = number
  default = 5
}

variable "lambda_memory_mb" {
  type    = number
  default = 256
}
