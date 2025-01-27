# Step:1 : Create a VPC
# THis is the resource file for the terraform code, where we are going to create the resources.
resource "aws_vpc" "Terraform-vpc" {
  cidr_block           = "10.0.0.0/16" # This has 65536 IP addresses. Simple formula to calculate the number of IP addresses in a CIDR block is 2^(32-n), where n is the number after the slash. like in this case it is 16, so the number of IP addresses will be 2^(32-16) = 65536.
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform-VPC"
  }
}
output "aws_vpc_output" {
  value = aws_vpc.Terraform-vpc.id
}
# Step:2 : Create a Subnet & Assign the AZ to it
# This is a subnet resource, where we are going to create a subnet in the VPC we created in the previous step.
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.Terraform-vpc.id # Here we tagged the subnet to vpc.
  cidr_block              = "10.0.0.0/18"           # This has 16384 IP addresses. simple formula is (2^{(32-18)} = 2^{14} = 16384)
  map_public_ip_on_launch = true                     # This will make the subnet public.
  availability_zone       = "us-east-1a"             # This is the availability zone where we are going to create the subnet.
  tags = {
    Name = "Public-Subnet-us-east-1a-AZ-1"
  }
}
output "aws_subnet_output-public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.Terraform-vpc.id
  cidr_block              = "10.0.64.0/18" # This has 16384 IP addresses.
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b" # This is the availability zone where we are going to create the subnet.
  tags = {
    Name = "Public-Subnet-us-east-1b-AZ-2"
  }
}
output "aws_subnet_output-public_subnet_2" {
  value = aws_subnet.public_subnet_2
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.Terraform-vpc.id
  cidr_block              = "10.0.128.0/18" # This has 16384 IP addresses.
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1c" # This is the availability zone where we are going to create the subnet.
  tags = {
    Name = "Private-Subnet-us-east-1c-AZ-3"
  }

}
output "aws_subnet_output-private_subnet_1" {
  value = aws_subnet.private_subnet_1.id
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.Terraform-vpc.id
  cidr_block              = "10.0.192.0/18" # This has 16384 IP addresses.
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1d" # This is the availability zone where we are going to create the subnet.
  tags = {
    Name = "Private-Subnet-us-east-1d-AZ-4"
  }

}
output "aws_subnet_output-private_subnet_2" {
  value = aws_subnet.private_subnet_2.id
}
# Step:3 : Create an Internet Gateway and attach it to the VPC
# This is an internet gateway resource, where we are going to create an internet gateway and attach it to the VPC.
resource "aws_internet_gateway" "Terraform-IGW" {
  vpc_id = aws_vpc.Terraform-vpc.id
  tags = {
    Name = "Terraform-IGW"
  }
}
output "aws_internet_gateway_output" {
  value = aws_internet_gateway.Terraform-IGW.id
}
# Step:4 : Create a Route Table and add a route to the internet gateway
# This is a route table resource, where we are going to create a route table and add a route to the internet gateway.
resource "aws_route_table" "Terraform-RT" {
  vpc_id = aws_vpc.Terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"                           # This is the route to the internet.
    gateway_id = aws_internet_gateway.Terraform-IGW.id # This is the internet gateway id. and we are attaching it to the route.
  }
  tags = {
    Name = "Terraform-RT"
  }
}
output "aws_route_table_output" {
  value = aws_route_table.Terraform-RT.id
}
# Step:5 : Associate the route table with the subnet
# This is a route table association resource, where we are going to associate the route table with the subnet.
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.Terraform-RT.id
}
output "aws_route_table_association_output_public_subnet_1" {
  value = aws_route_table_association.public_subnet_1_association.id
}
resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.Terraform-RT.id
}
output "aws_route_table_association_output_public_subnet_2" {
  value = aws_route_table_association.public_subnet_2_association.id
}
# Step:6 : Create a Security Group for the instances
# This is a security group resource, where we are going to create a security group for the instances.
# Here we are allowing tcp port 22 for ssh and http port 80 for http.
resource "aws_security_group" "Terraform_securityGroup" {
  name        = "Terraform_securityGroup"
  description = "Allow inbound traffic on port 22 and 80"
  vpc_id      = aws_vpc.Terraform-vpc.id # Here we are tagging the security group to the vpc.
  # This is the ingress rule, where we are allowing the traffic to come in.
  ingress {
    from_port   = 22 # This is the ssh port.
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.32/27", "192.168.1.64/27"]
  }
  ingress {
    from_port   = 80 # This is the http port.
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.32/27", "192.168.1.64/27"]
  }
  # This is the egress rule, where we are allowing all the traffic to go out.
  egress {
    from_port   = 0             # This is the from port.
    to_port     = 0             # This is the to port.
    protocol    = "-1"          # This is the protocol, -1 means all the protocols.
    cidr_blocks = ["0.0.0.0/0"] # This is the cidr block, which means all the IP addresses can go out.
  }
}
output "aws_security_group_output" {
  value = aws_security_group.Terraform_securityGroup.id
}
# Step:7 : Create an load balancer
# This is a load balancer resource, where we are going to create a load balancer.
resource "aws_lb" "Terraform-LoadBalancer" {
  name                             = "Terraform-LoadBalancer"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.Terraform_securityGroup.id]                # Here we are tagging the security group to the load balancer.
  subnets                          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] # Here we are tagging the subnets to the load balancer.
  enable_deletion_protection       = false
  enable_http2                     = true
  idle_timeout                     = 60
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "Terraform-LoadBalancer"
  }
}
output "aws_lb_output" {
  value = aws_lb.Terraform-LoadBalancer.id
}
# Step:8 : Create a target group
# This is a target group resource, where we are going to create a target group. This target group is going to be used by the load balancer.
resource "aws_lb_target_group" "Terraform-target-group" {
  name        = "Terraform-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Terraform-vpc.id
  target_type = "instance" # This is the target type, here we are using instance as the target type.
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "Terraform-target-group"
  }
}
output "aws_lb_target_group_output" {
  value = aws_lb_target_group.Terraform-target-group.id
}
# Step:9 : Create a listener
# This is a listener resource, where we are going to create a listener. This listener is going to be used by the load balancer.
resource "aws_lb_listener" "Terraform-listener" {
  load_balancer_arn = aws_lb.Terraform-LoadBalancer.arn # Here we are tagging the load balancer to the listener.
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Terraform-target-group.arn # Here we are tagging the target group to the listener.
  }
}
output "aws_lb_listener_output" {
  value = aws_lb_listener.Terraform-listener.id
}
# Step:10 : Create an Auto Scaling Group
# This is an auto scaling group resource, where we are going to create an auto scaling group.
resource "aws_autoscaling_group" "Terraform-ASG" {
  name                      = "Terraform-ASG"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id] # Here we are tagging the subnets to the auto scaling group.
  launch_configuration      = aws_launch_configuration.Terraform-LC.name                     # Here we are tagging the launch configuration to the auto scaling group.
  target_group_arns         = [aws_lb_target_group.Terraform-target-group.arn]               # Here we are tagging the target group to the auto scaling group.
  tag {
    key                 = "Name"
    value               = "Terraform-ASG"
    propagate_at_launch = true
  }
}
output "aws_autoscaling_group_output" {
  value = aws_autoscaling_group.Terraform-ASG.id
}
# Step:11 : Create a Launch Configuration
# This is a launch configuration resource, where we are going to create a launch configuration. This launch configuration is going to be used by the auto scaling group.
resource "aws_launch_configuration" "Terraform-LC" {
  name                        = "Terraform-LC"
  image_id                    = "ami-0c55b159cbfafe1f0"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.Terraform_securityGroup.id] # Here we are tagging the security group to the launch configuration.
  key_name                    = "terraform-key"
  associate_public_ip_address = true
  user_data                   = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 80 &
                EOF
}
output "aws_launch_configuration_output" {
  value = aws_launch_configuration.Terraform-LC.id
}
# Step:12 : Create a Launch Template
# This is a launch template resource, where we are going to create a launch template. This launch template is going to be used by the auto scaling group.
resource "aws_launch_template" "Terraform-LT" {
  name                 = "Terraform-LT"
  ebs_optimized        = false
  image_id             = "ami-0c55b159cbfafe1f0"
  instance_type        = "t2.micro"
  key_name             = "terraform-key"
  security_group_names = [aws_security_group.Terraform_securityGroup.id] # Here we are tagging the security group to the launch template.
  user_data            = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 80 &
                EOF
}
output "aws_launch_template_output_Terraform-LT" {
  value = aws_launch_template.Terraform-LT.id
}
resource "aws_launch_template" "Terraform-LT_1" {
  name                 = "Terraform-LT"
  ebs_optimized        = false
  image_id             = "ami-0c55b159cbfafe1f0"
  instance_type        = "t2.micro"
  key_name             = "terraform-key"
  security_group_names = [aws_security_group.Terraform_securityGroup.id] # Here we are tagging the security group to the launch template.
  user_data            = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 80 &
                EOF
  
}
output "aws_launch_template_output" {
  value = aws_launch_template.Terraform-LT_1.id
}

# Step:13 : Create a Launch Template Version
# This is a launch template version resource, where we are going to create a launch template version. This launch template version is going to be used by the auto scaling group.
/*resource "aws_launch_template_version" "Terraform-LTV" {
  launch_template_id = aws_launch_template.Terraform-LT.id
  source_version     = "$Latest"
}
output "aws_launch_template_version_output" {
  value = aws_launch_template_version.Terraform-LTV.id
} */

# Step:14 : create an instance
# This is an instance resource, where we are going to create an instance. This instance is going to be used by the auto scaling group.
resource "aws_instance" "Terraform-Instance" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  key_name               = "terraform-key"
  subnet_id              = aws_subnet.public_subnet_1.id # Here we are tagging the subnet to the instance.
  vpc_security_group_ids = [aws_security_group.Terraform_securityGroup.id]
  security_groups        = [aws_security_group.Terraform_securityGroup.id] # Here we are tagging the security group to the instance.
  user_data              = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 80 &
                EOF
}
output "aws_instance_output" {
  value = aws_instance.Terraform-Instance.id
}