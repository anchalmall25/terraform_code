provider "aws" {
  region     = "ap-south-1"
  access_key = "access_key"
  secret_key = "security_key"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my_vpc"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = {
    Name = "gw"
  }
}
resource "aws_subnet" "public_subnet" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "private_subnet" {
    vpc_id = "${aws_vpc.my_vpc.id}"

    cidr_block = "192.168.0.0/24"
    availability_zone = "ap-south-1a"

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_route_table" "my_table" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

 

  tags = {
    Name = "my_table"
  }
}
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.my_table.id}"
}
resource "aws_security_group" "my_security" {
  name        = "my_security"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  

  tags = {
    Name = "my_security"
  }
}
resource "aws_instance" "wordpress" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.public_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.my_security.id}"]
  key_name = "keycloud"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "wordpress"
  }

}
resource "aws_instance" "mysql" {
  ami           = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  
  subnet_id = "${aws_subnet.private_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.my_security.id}"]
  key_name = "keycloud"
  availability_zone = "ap-south-1a"

 tags = {
    Name = "mysql"
  }

}
