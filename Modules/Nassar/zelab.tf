##----------------------------------------------------------------------------------------------------VPC and Gateways
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Virtual Private Cloud
resource "aws_vpc" "my-vpc" {
  cidr_block       = "10.23.0.0/16"

  tags = {
    Name = "NassarVPC"
  }
}

##---------------------------------------------------Gateways
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "NassarIGW"
  }
}

##----------------------------------------------------------------------------------------------------Subnets
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Public Subnet 01
resource "aws_subnet" "pub-net01" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.1.0/24"
  #map_public_ip_on_launch = true

  tags = {
    Name = "PubSubnet01"
  }
}

##---------------------------------------------------Public Subnet 02
resource "aws_subnet" "pub-net02" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "PubSubnet02"
  }
}

##---------------------------------------------------Private Subnet 01
resource "aws_subnet" "priv-net01" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.3.0/24"

  tags = {
    Name = "PrivSubnet01"
  }
}

##---------------------------------------------------Private Subnet 02
resource "aws_subnet" "priv-net02" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.23.4.0/24"

  tags = {
    Name = "PrivSubnet02"
  }
}

##----------------------------------------------------------------------------------------------------Route Tables
##----------------------------------------------------------------------------------------------------
resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "PublicRoute"
  }
}

##----------------------------------------------------------------------------------------------------Route Tables Association
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------
resource "aws_route_table_association" "to-igw01" {
  subnet_id      = aws_subnet.pub-net01.id
  route_table_id = aws_route_table.my-route.id
}

resource "aws_route_table_association" "to-igw02" {
  subnet_id      = aws_subnet.pub-net02.id
  route_table_id = aws_route_table.my-route.id
}

##----------------------------------------------------------------------------------------------------Security Groups
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Bastion Security Group
resource "aws_security_group" "fromBastion" {
  name        = "BastionSG"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "SSH to EC2"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionSSH"
  }
}
##---------------------------------------------------Instance Security Group
resource "aws_security_group" "instance" {
  name        = "NodesSG"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "SSH from Bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.fromBastion.id]
  }

  ingress {
    description      = "Access HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.accessALB.id]
  }

  ingress {
    description      = "mount EFS"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "EC2Access"
  }
}
##---------------------------------------------------ALB Security Group
resource "aws_security_group" "accessALB" {
  name        = "ALB-SG"
  description = "Access ALB from Internet via HTTPS"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "TLS back to VPC"
    from_port        = 1024
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AccessOnALB"
  }
}

##----------------------------------------------------------------------------------------------------Elastic FileSystem
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Creating EFS file system
resource "aws_efs_file_system" "my-efs" {
    creation_token = "my-efs"
    tags = {
        Name = "SuchAGlusterFS"
    }
}
##---------------------------------------------------Creating Mount target of EFS
resource "aws_efs_mount_target" "mount" {
    file_system_id = aws_efs_file_system.my-efs.id

    subnet_id      = aws_subnet.priv-net01.id
    security_groups = [aws_security_group.instance.id]
}
##---------------------------------------------------Creating Mount Point for EFS
resource "null_resource" "configure_nfs" {
    depends_on = [aws_efs_mount_target.mount]
    connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = aws_key_pair.chachakey.key_name
        host     = aws_instance.template.public_ip
    }
}

resource "aws_key_pair" "chachakey" {
  key_name   = "chacha"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

##----------------------------------------------------------------------------------------------------Instances
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Template with EFS and Apps
resource "aws_instance" "template" {
  ami           = var.ami-id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pub-net01.id
  key_name      = aws_key_pair.chachakey.key_name
  # App Provisioning

  tags = {
    Name = "Template"
  }
}
##---------------------------------------------------Bastion
resource "aws_instance" "bastion" {
  subnet_id     = aws_subnet.pub-net02.id
  ami           = var.ami-id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.fromBastion.id]
  key_name      = aws_key_pair.chachakey.key_name

  tags = {
    Name = "Bastion"
  }
}

##----------------------------------------------------------------------------------------------------Configure Target Group
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Configure Target Group
resource "aws_lb_target_group" "my-target-group" {
  name     = "MyNodesTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
}

##----------------------------------------------------------------------------------------------------Auto Scaling Group
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Launch Template
resource "aws_launch_template" "my-template" {
  name_prefix   = "LaunchTemplate"
#########Image from EC2
  image_id      = var.ami-id
  instance_type = "t2.micro"
  #subnet_id     =

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }
  vpc_security_group_ids = [aws_security_group.instance.id]
  #user_data = filebase64("${path.module}/example.sh")
}

##---------------------------------------------------AutoScaling Group
resource "aws_autoscaling_group" "my-auto-scaling" {
  name               = "MyASGroup"
  #availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_zone_identifier = [aws_subnet.pub-net01.id, aws_subnet.pub-net02.id]
  desired_capacity   = 3
  max_size           = 5
  min_size           = 2

  launch_template {
    id      = aws_launch_template.my-template.id
    version = "$Latest"
  }
  
  target_group_arns = [aws_lb_target_group.my-target-group.arn]
}

##----------------------------------------------------------------------------------------------------Application Load Balancer
##----------------------------------------------------------------------------------------------------
###
##---------------------------------------------------Configure the LoadBalancer
resource "aws_lb" "nodes-lb" {
  name               = "NassarLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.accessALB.id]
  subnets            = [aws_subnet.pub-net01.id, aws_subnet.pub-net02.id]

  enable_deletion_protection = true
}

##---------------------------------------------------Forward to Listener
resource "aws_alb_listener" "my-listener" {
  load_balancer_arn = aws_lb.nodes-lb.arn
  port = "80"
  protocol = "HTTP"
  # certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.my-target-group.arn
    type             = "forward"
  }
}

##----------------------------------------------------------------------------------------------------Ouputs
##----------------------------------------------------------------------------------------------------
