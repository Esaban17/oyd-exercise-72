output "state_bucket_name" {
  description = "Nombre del bucket S3 a usar en los backend-*.hcl"
  value       = aws_s3_bucket.tfstate.id
}

output "lock_table_name" {
  description = "Nombre de la tabla DynamoDB a usar en los backend-*.hcl"
  value       = aws_dynamodb_table.tflock.name
}
