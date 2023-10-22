provider "aws" {
  region = "us-east-2"
  shared_credentials_files = ["~/.aws/credentials"]
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}


#resource "aws_key_pair" "key" {
#  key_name   = "id_rsa"
#  public_key = file("~/.ssh/id_rsa.pub")
#}

resource "aws_default_vpc" "default_vpc" {

}

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow inbound traffic"

  # using default VPC
  vpc_id      = aws_default_vpc.default_vpc.id
  ingress {
    description = "TLS from VPC"

    # we should allow incoming and outoging
    # TCP packets
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 8081"

    # we should allow incoming and outoging
    # TCP packets
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"

    # allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbond traffic"

    from_port   = 0
    to_port     = 0
    protocol    = -1

    # allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_traffic"
  }
}

variable "ami_id" {
  description = "ubuntu 22.04 ami id"
  default     = "ami-024e6efaf93d85776"
}

resource "aws_instance" "my_ec2" {
  ami             = var.ami_id
  instance_type   = "t2.micro"

  # refering key which we created earlier
  key_name        = "TestAWS"

  # refering security group created earlier
  security_groups = [aws_security_group.allow_traffic.name]

  tags = {
    Name = "my-test-ec2"
  }
}

resource "null_resource" "write_hosts_file" {
  triggers = {
    public_ip = aws_instance.my_ec2.public_ip
  }

  provisioner "local-exec" {
    command = <<EOF
rm -f hosts
echo "[servers]" > hosts
echo "my-test-ec2 ansible_ssh_host=${aws_instance.my_ec2.public_ip} ansible_ssh_user=ubuntu" >> hosts
cp hosts ../ansible
cat ../ansible/hosts
EOF
  }
}

output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}
