variable "aws_region" {
  description = "AWS region donde viven el bucket de state y la tabla de lock"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Nombre global único del bucket S3 para el state de Terraform"
  type        = string
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB para el state locking"
  type        = string
  default     = "oyd-exercise-72-tflock"
}
