# Terraform variables file

variable "az" {
    default = "us-west-1a"
    description = "Availability zone"
}

variable "aws_access_key" {
    description = "AWS access key from the enviorment variable"
}

variable "aws_secret_key" {
    description = "AWS secret key from the enviorment variable"
}

variable "subnet_cidr" {
    default = "192.168.0.0/24"
}

variable "vpc_cidr" {
    default = "192.168.0.0/24"
}

variable "workstation_ip" {
    default = "13.49.66.94/32"
}

variable "lb_server_private_ip" {
    default = "192.168.0.11"
}

variable "web_server_private_ip" {
    default = "192.168.0.12"
}

variable "db_server_private_ip" {
    default = "192.168.0.13"
}
