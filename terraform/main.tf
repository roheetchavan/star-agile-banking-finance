# Define the provider (AWS)
provider "aws" {
  region = "us-east-2" # Change this to your desired AWS region
  access_key = "AKIASA625THS65UB6YFT"
  secret_key = "Klx03fVC+4PAWeVYOa5DbwOxfKE8hExDjnXAQfbG"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

# Create a custom route table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id
}

# Create a subnet
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a" # Change this to your desired availability zone
  map_public_ip_on_launch = true
}

# Associate the subnet with the custom route table
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}

# Create a security group
resource "aws_security_group" "example" {
  name_prefix = "example-"
  description = "Example security group"

  # Allow SSH (Port 22), HTTP (Port 80), and HTTPS (Port 443) traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.example.id
}

# Create a network interface
resource "aws_network_interface" "example" {
  subnet_id   = aws_subnet.example.id
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS AMI ID, replace with your desired AMI
  instance_type = "t2.micro"             # Change the instance type if needed
  key_name      = "TestAWS"              # Replace with your key pair name

  network_interface {
    network_interface_id = aws_network_interface.example.id
    device_index = 0
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install apache2 -y
              sudo systemctl start apache2
              sudo systemctl enable apache2
              EOF

  tags = {
    Name = "ExampleEC2Instance2"
  }
}
