locals {
  is_alb           = var.lb_type == "application"
  use_own_sg       = local.is_alb && var.create_security_group
  lb_security_groups = local.is_alb ? (
    var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
  ) : null
}

# ---------------------------------------------------------------------------
# Security Group (ALB only)
# ---------------------------------------------------------------------------
resource "aws_security_group" "this" {
  count = local.use_own_sg ? 1 : 0

  name        = "${var.name}-lb-sg"
  description = "Security group for ${var.name} load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      description = "HTTPS"
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-lb-sg"
  })
}

# ---------------------------------------------------------------------------
# Load Balancer
# ---------------------------------------------------------------------------
resource "aws_lb" "this" {
  name               = "${var.name}-lb"
  internal           = var.internal
  load_balancer_type = var.lb_type
  subnets            = var.subnet_ids
  security_groups    = local.lb_security_groups

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout                = local.is_alb ? var.idle_timeout : null

  tags = merge(var.tags, {
    Name = "${var.name}-lb"
  })
}

# ---------------------------------------------------------------------------
# Target Group
# ---------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    path                = local.is_alb ? var.health_check_path : null
    interval            = var.health_check_interval
    timeout              = local.is_alb ? var.health_check_timeout : null
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    protocol            = var.target_protocol
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# HTTP / primary Listener
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_port
  protocol          = local.is_alb ? "HTTP" : "TCP"

  dynamic "default_action" {
    for_each = local.is_alb && var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = tostring(var.https_port)
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = local.is_alb && var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this.arn
    }
  }
}

# ---------------------------------------------------------------------------
# HTTPS Listener (ALB only, optional)
# ---------------------------------------------------------------------------
resource "aws_lb_listener" "https" {
  count = local.is_alb && var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
