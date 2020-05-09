provider "aws" {
  version = "~> 2.61"
  access_key = var.access-key
  secret_key = var.secret-key
  region     = "ap-south-1"
}
data "aws_availability_zones" "all" {}

###  EC2 instance
resource "aws_instance" "web" {
  ami               = lookup(var.amis,var.region)
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  source_dest_check = false
  instance_type = "t2.micro"
}

###  Security Group for EC2
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Autoscaling Launch Configuration
resource "aws_launch_configuration" "example" {
  image_id               = lookup(var.amis,var.region)
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = var.key_name
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, Team" > index.html
              nohup busybox httpd -f -p 9090 &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

## AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones = ["data.aws_availability_zones[count.index]"]
  min_size = 2
  max_size = 4
  load_balancers = ["aws_elb.example.name"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###  ELB
resource "aws_elb" "example" {
  name = "terraform-asg-example"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["element(data.aws_availability_zones.all.names[count.index])"]
  health_check  {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:9090/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "9090"
    instance_protocol = "http"
  }
}