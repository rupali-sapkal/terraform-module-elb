output "lb_id" {
  description = "ID of the load balancer"
  value       = aws_lb.this.id
}

output "lb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "lb_zone_id" {
  description = "Canonical hosted zone ID of the load balancer (for Route53 alias records)"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group — attach EC2 instances / an ASG / ECS service to this"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.this.name
}

output "security_group_id" {
  description = "ID of the security group created for the load balancer (null if create_security_group = false or lb_type = network)"
  value       = local.use_own_sg ? aws_security_group.this[0].id : null
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener, if created"
  value       = local.is_alb && var.enable_https ? aws_lb_listener.https[0].arn : null
}
