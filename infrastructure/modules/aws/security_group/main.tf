resource "aws_security_group" "alb" {
  name   = var.alb_sg_name
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "common" {
  name   = var.common_sg_name
  vpc_id = var.vpc_id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    security_groups = var.allow_security_group_ids
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
