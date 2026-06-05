# Bootstrap del backend remoto de Terraform.
#
# Resuelve el problema del huevo y la gallina: el bucket que guarda el state
# del proyecto no puede guardar su propio state. Por eso este módulo usa
# backend LOCAL y crea, una sola vez:
#   - el bucket S3 (versionado + cifrado + acceso público bloqueado)
#   - la tabla DynamoDB para el state locking
#
# Una vez aplicado, infra/envs/*/backend-*.hcl apuntan a estos recursos.

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # Backend local a propósito (no remoto).
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.state_bucket_name

  tags = {
    Project   = "oyd-exercise-7-2"
    ManagedBy = "terraform-bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tflock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Project   = "oyd-exercise-7-2"
    ManagedBy = "terraform-bootstrap"
  }
}
