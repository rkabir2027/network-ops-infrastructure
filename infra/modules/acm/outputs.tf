
output "certificate_arn" {
  description = "ARN of the existing ACM certificate"
  value       = data.aws_acm_certificate.existing.arn
}
