resource "aws_lb" "app_alb" {
    name               = "${var.project_name}-${var.environment}-app-alb"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [data.aws_ssm_parameter.app_alb_sg_id.value]
    subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

    enable_deletion_protection = false

    tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}-app-alb"
        }
    )
}


resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/html"
            message_body = "<h1>This is Fixed response from APP ALB</h1>"
            status_code  = "200"
        }
    }   
}