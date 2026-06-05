# Cola SQS principal del ejercicio 7.2 (cambio trivial para disparar el CI).
resource "aws_sqs_queue" "main" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
}
