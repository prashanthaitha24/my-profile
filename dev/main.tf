module "stack" {
  source = "../modules/stack"
  project = var.project
  region  = var.region
  enable_vpc        = true
  enable_s3         = true
  enable_cloudfront = true
  enable_route53    = var.domain_zone_id != null && var.domain_name != null
  enable_eks        = true
  enable_alb        = false
  vpc_cidr     = "10.50.0.0/16"
  az_count     = 2
  bucket_name  = "${var.project}-site-${var.region}"
  domain_zone_id    = var.domain_zone_id
  domain_name       = var.domain_name
  api_domain_name   = var.api_domain_name
  api_shared_secret = var.api_shared_secret
  tags = { env="dev", project=var.project }
}
output "stack_outputs" {
  value = { vpc_id=module.stack.vpc_id, subnet_ids=module.stack.subnet_ids, bucket_name=module.stack.bucket_name, cloudfront_domain=module.stack.cloudfront_domain, eks_cluster_name=module.stack.eks_cluster_name }
}
