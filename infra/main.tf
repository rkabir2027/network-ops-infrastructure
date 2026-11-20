module "vpc" {
  source       = "./modules/vpc"
  project_name = "network-ops"

}

module "ecr" {
  source       = "./modules/ecr"
  project_name = "network-ops"
}


module "acm" {
  source      = "./modules/acm"
  domain_name = "networkmaster.uk"
}


module "alb" {
  source            = "./modules/alb"
  project_name      = "network-ops"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
}


module "ecs" {
  source       = "./modules/ecs"
  project_name = "network-ops"
  aws_region   = "eu-west-1"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  https_listener_arn    = module.alb.https_listener_arn

  container_image = "${module.ecr.repository_url}:v1"
  desired_count   = 1

  depends_on = [module.alb]
}


# Find the existing Route 53 hosted zone
data "aws_route53_zone" "existing" {
  name         = "networkmaster.uk."
  private_zone = false
}

# Point the domain to the Terraform ALB
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = "networkmaster.uk"
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
