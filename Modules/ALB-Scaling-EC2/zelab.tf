##-----------------------------------------Auto Scaling Group
###
resource "aws_autoscaling_group" "my-auto-scaling" {
  name               = "MyASGroup"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  desired_capacity   = 4
  max_size           = 6
  min_size           = 2
  # target_group_arns =

  launch_template {
    id      = aws_launch_template.my-template.id
    version = "$Latest"
  }
}

#### Launch Template - the config from whih the AS will launch
resource "aws_launch_template" "my-template" {
  name_prefix   = "LaunchTemplate"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.my-auto-scaling.name
  alb_target_group_arn   = aws_lb_target_group.instance-tg.arn
}

##-----------------------------------------Application Load Balancer
###
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

#### Configure Target Group
resource "aws_lb_target_group" "instance-tg" {
  name     = "MyEC2TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

#### Configure instance template
resource "aws_instance" "my-ec2-template" {
  ami           = "ami-005e54dee72cc1d00"
  instance_type = "t2.micro"
}

#### Add the instance type to the target group
resource "aws_lb_target_group_attachment" "to-my-ec2" {
  target_group_arn = aws_lb_target_group.instance-tg.arn
  target_id        = aws_instance.my-ec2-template.id
  port             = 80
}
