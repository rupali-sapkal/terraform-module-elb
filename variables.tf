variable "name" {
  description = "Name prefix for all resources created by this module (e.g. myapp-prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancer and target group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer (min 2, in different AZs)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least 2 subnet_ids in different Availability Zones."
  }
}

variable "lb_type" {
  description = "Type of load balancer: application or network"
  type        = string
  default     = "application"

  validation {
    condition     = contains(["application", "network"], var.lb_type)
    error_message = "lb_type must be either \"application\" or \"network\"."
  }
}

variable "internal" {
  description = "Whether the load balancer is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the load balancer"
  type        = bool
  default     = false
}

variable "create_security_group" {
  description = "Whether to create a security group for the load balancer (ALB only; ignored for NLB)"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Existing security group IDs to attach instead of creating one (used when create_security_group = false)"
  type        = list(string)
  default     = []
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the load balancer on the listener ports"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_port" {
  description = "Port the load balancer listens on for HTTP"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Port the load balancer listens on for HTTPS"
  type        = number
  default     = 443
}

variable "enable_https" {
  description = "Whether to create an HTTPS listener (requires acm_certificate_arn)"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener (required if enable_https = true)"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy to use on the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "target_port" {
  description = "Port on which targets (e.g. EC2 instances/ECS tasks) receive traffic"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol used to route traffic to targets (HTTP, HTTPS, TCP, UDP, TLS)"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target: instance, ip, or lambda"
  type        = string
  default     = "instance"
}

variable "health_check_path" {
  description = "Path used by the health check (application load balancer only)"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Approximate amount of time between health checks (seconds)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time to wait for a health check response (seconds, ALB only)"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks before considering a target healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks before considering a target unhealthy"
  type        = number
  default     = 3
}

variable "idle_timeout" {
  description = "Time in seconds that a connection is allowed to be idle (ALB only)"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}
