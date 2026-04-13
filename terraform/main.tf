provider "aws" {
    region = var.region
}

resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/28"
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"

}

resource "aws_security_group" "web_sg" {
    name = "web-sg"
    vpc_id = aws_vpc.main.id

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0 
        protocol = "-1"
    }
}

resource "aws_instance" "web" {
    ami = var.ami
    instance_type = "t3.micro"
    security_groups = [aws_security_group.web_sg.id]
    subnet_id = aws_subnet.main.id

    user_data = <<-EOF
                #!/bin/bash
                yum install -y nginx
                systemctl start nginx
                systemctl enable nginx
                EOF
    
    tags = {
        Name = "Terraform-EC2"
    }
}
