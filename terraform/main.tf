# Create a VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

}

# Create a Subnet

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  availability_zone = "us-west-1a"

}

# Security Groups

resource "aws_security_group" "http_80" {
  name        = "wrokstation_to_lb_server"
  description = "Workstation to LB segmantation"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP Connection from workstation to LB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.workstation_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "ssh_22" {
  name        = "workstation_to_all_servers"
  description = "Workstation to all servers segmantation"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH Connection from workstation to all servers"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.workstation_ip]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "internal_commn" {
  name        = "subnet_internal_commn"
  description = "Allow any internal communication in the subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Any subnet internal communication"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.subnet_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
     
}

# Create an Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

}

# Creating a route table

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Route table association with the subnet

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id

}

# EC2 Instances

resource "aws_instance" "LB" {
  ami           = "ami-0454207e5367abf01" 
  instance_type = "t2.micro"
  private_ip    = var.lb_server_private_ip
  availability_zone = "us-west-1a"
  subnet_id     = aws_subnet.subnet.id 
  vpc_security_group_ids = [aws_security_group.internal_commn.id, aws_security_group.http_80.id, aws_security_group.ssh_22.id]
  associate_public_ip_address = "true"
  key_name      = "asgmt-ssh-key"

}

resource "aws_instance" "WEB" {
  ami           = "ami-0454207e5367abf01"
  instance_type = "t2.micro"
  private_ip    = var.web_server_private_ip
  availability_zone = "us-west-1a"
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.internal_commn.id, aws_security_group.ssh_22.id]
  associate_public_ip_address = "true"
  key_name      = "asgmt-ssh-key"

}

resource "aws_instance" "DB" {
  ami           = "ami-0454207e5367abf01"
  instance_type = "t2.micro"
  private_ip    = var.db_server_private_ip
  availability_zone = "us-west-1a"
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.internal_commn.id, aws_security_group.ssh_22.id]
  associate_public_ip_address = "true"
  key_name      = "asgmt-ssh-key"

}

# Adding an SSH key

resource "aws_key_pair" "ssh_key" {
     key_name   = "asgmt-ssh-key"
     public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYsBNZpbXIYop+xlVONgvZwCU8L4lI835HgzOF53hF+BzZ7z3Ms/XIqcbWEB5skqW8NcTr+B9vHMIMIQP2r870Uqn2RZQoxQWfIDjRtwR8hVQ8KhYo/3zHbk2c+gSHy5Tpo2nZne7rWNtP4lCi4cELBq+RSB/r/eQvWguwimzWa2iEUKRm1UlcFv92vdfbQluwOlY9k+60h+m+aSYQ/Pq+jqAfllzcPZNHMH9BPqrFgvMb+ZLomDWALh0sgOzLMSOqnCbbxkFECAeoORxTjaZGWTaVsSXpmu0DPMBvnxN4MIvvF4Z4sAL6NK1I/D2EyXPg1C35oyJgouf3KpBEcBKp ubuntu@ip-172-31-35-171"

}
