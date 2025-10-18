locals { name = var.project }
module "vpc" { source="../vpc" count=var.enable_vpc?1:0 name="${local.name}-vpc" cidr=var.vpc_cidr az_count=var.az_count tags=var.tags }
module "s3"  { source="../s3"  count=var.enable_s3?1:0  bucket_name=coalesce(var.bucket_name,"${local.name}-site-${var.region}") tags=var.tags }
module "cloudfront" {
  source="../cloudfront" count=var.enable_cloudfront?1:0
  s3_domain_name=module.s3[0].bucket_domain_name
  api_domain_name=var.api_domain_name
  api_shared_secret=var.api_shared_secret
  aliases=var.domain_name!=null?[var.domain_name]:[]
  tags=var.tags
}
data "aws_cloudfront_distribution" "cf" { count=var.enable_cloudfront && var.enable_route53 && var.domain_zone_id!=null ? 1 : 0
  id=module.cloudfront[0].distribution_id
}
module "route53" {
  source="../route53" count=var.enable_route53 && var.domain_zone_id!=null ? 1 : 0
  zone_id=var.domain_zone_id
  records=[ for d in data.aws_cloudfront_distribution.cf : {
    name=var.domain_name, type="A",
    alias={name=d.domain_name, hosted_zone_id=d.hosted_zone_id, evaluate_target_health=false}
  }]
}
module "eks" { source="../eks" count=var.enable_eks?1:0 name="${local.name}-eks" region=var.region vpc_id=module.vpc[0].vpc_id subnet_ids=module.vpc[0].public_subnet_ids tags=var.tags }
module "alb" { source="../alb" count=var.enable_alb?1:0 name="${local.name}-alb" vpc_id=module.vpc[0].vpc_id subnet_ids=module.vpc[0].public_subnet_ids tags=var.tags }
