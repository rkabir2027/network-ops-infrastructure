
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "ecr-repository-url" {
  value = module.ecr.repository_url
}


output "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  value       = module.acm.certificate_arn
}


output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  value = module.ecs.task_definition_arn
}


output "application_url" {
  description = "Public HTTPS URL"
  value       = "https://networkmaster.uk"
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS"
  value       = module.alb.alb_dns_name
}
