output "record_names"{value=[for k,v in aws_route53_record.this: v.name]}
