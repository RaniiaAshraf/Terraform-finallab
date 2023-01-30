resource "aws_lb_target_group" "loadbalancer-target" {
  name     = var.loadbalancertarget-name 
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
  target_type = "instance"

  health_check {
    path = "/"
    port = 80
  }
}


resource "aws_security_group" "loadbalancer-security" {
  name        = var.securitygroup-name 
  vpc_id      = var.vpc-id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "loadbalancer" {
  name            = var.loadbalancer-name
  internal           = false  
  load_balancer_type = "application"
  security_groups = [aws_security_group.loadbalancer-security.id] 
  subnets         = [var.public-subnet-id-1,var.public-subnet-id-2]

}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loadbalancer-target.arn
  }
}

resource "aws_lb_target_group_attachment" "tg-attach" {
  count = length(var.publicinstance)
  target_group_arn = aws_lb_target_group.loadbalancer-target.arn
  target_id        = var.publicinstance[count.index]

}

resource "aws_lb_target_group" "alb-tg-2" {
  name     = var.private-loadbalancer-targetname
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
  target_type = "instance"

  health_check {
    path = "/"
    port = 80
  }
}


resource "aws_lb" "loadbalancer-2" {
  name            = var.private-loadbalancer-name
  internal           = true 
  load_balancer_type = "application"
  security_groups = [aws_security_group.loadbalancer-security.id] 
  subnets         =  [var.private-subnet-id-1,var.private-subnet-id-2]

}


resource "aws_lb_listener" "listener-2" {
  load_balancer_arn = aws_lb.loadbalancer-2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg-2.arn
  }
}


resource "aws_lb_target_group_attachment" "tg-attach-2" {
  count = length(var.privateinstance)
  target_group_arn = aws_lb_target_group.alb-tg-2.arn
  target_id        = var.privateinstance[count.index]

}