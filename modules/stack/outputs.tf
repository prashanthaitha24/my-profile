output "vpc_id"{value=try(module.vpc[0].vpc_id,null)}
output "subnet_ids"{value=try(module.vpc[0].public_subnet_ids,[])}
output "bucket_name"{value=try(module.s3[0].bucket,null)}
output "cloudfront_domain"{value=try(module.cloudfront[0].domain_name,null)}
output "cloudfront_id"{value=try(module.cloudfront[0].distribution_id,null)}
output "eks_cluster_name"{value=try(module.eks[0].cluster_name,null)}
output "alb_dns_name"{value=try(module.alb[0].alb_dns_name,null)}
