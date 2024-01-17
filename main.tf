#Author: Aaron Burkett

#aws CLI configured to have static access key
provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "ec2" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx
              EOF

  tags = {
    Name = "Ubuntu"
  }
}

#               echo "Hello World" > /var/www/html/index.html

resource "aws_security_group" "allow_web_traffic" {
  name        = "port80"
  description = "Allow inbound traffic on port 80 and all outbound traffic"

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.allow_web_traffic.id
  network_interface_id = aws_instance.ec2.primary_network_interface_id
}

output "server_public_ip" {
  value = aws_instance.ec2.public_ip
}