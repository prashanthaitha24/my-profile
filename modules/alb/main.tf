resource "aws_security_group" "alb_sg" { name="${var.name}-alb-sg", description="ALB SG", vpc_id=var.vpc_id
  ingress { from_port=443, to_port=443, protocol="tcp", cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0, to_port=0, protocol="-1", cidr_blocks=["0.0.0.0/0"] }
  tags=var.tags
}
resource "aws_lb" "this" { name=var.name, load_balancer_type="application", internal=false, security_groups=[aws_security_group.alb_sg.id], subnets=var.subnet_ids, tags=var.tags }
resource "aws_lb_listener" "https" { load_balancer_arn=aws_lb.this.arn, port=443, protocol="HTTPS", ssl_policy="ELBSecurityPolicy-2016-08", certificate_arn=null
  default_action { type="fixed-response", fixed_response{content_type="text/plain",message_body="OK",status_code="200"} }
}
