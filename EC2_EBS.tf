# Downloading Driver For AWS & Terraform Communication
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AMI ID 
variable "amiId" {
	default = "ami-072ec8f4ea4a6f2cf"
}

# Security Group
variable "mySecurityGroup" {
	default = "sg-010f683d9801ca435"
}

# Default Region
variable "defaultRegion" {
	default = "ap-south-1"
}

# Default Key
variable "defaultKey" {
	default = "HimanshuTF"
}

# Default Instance Type 
variable "defaultInstanceType" {
	default = "t2.micro"
} 

# Default Instance State
variable "defaultInstanceState" {
	default = "running"
}

# Authentication in AWS Cloud
provider "aws" {
  region     = var.defaultRegion
  access_key = "Your-Access-Key-Here"
  secret_key = "Your-Secret-Key-Here"
}

# Launching AWS Instance
resource "aws_instance" "web" {
	  ami           = var.amiId
	  key_name 	= var.defaultKey
	  instance_type = var.defaultInstanceType
	  vpc_security_group_ids  = [var.mySecurityGroup]
	  tags = {
	    Name = "OS By TF"
	  }

# Login Inside the OS by ssh using Username and Private Key
	connection {
	      user        = "ec2-user"
	      type        = "ssh"
	      private_key = file("C:/Users/Himanshu Kumar/Documents/Terraform/HimanshuTF.pem")
	      host 	  = aws_instance.web.public_ip
	}

# Downloading the Software Inside the OS
	provisioner "remote-exec" {
	    inline = [
	      	"sudo yum -y install httpd",
		"sudo systemctl enable httpd --now"
    		]
	}
}

# Creating 1 Storage Device of 2 GB in Size in Region ap-south-1a with name Webserver Volume
resource "aws_ebs_volume" "MyVolume"{
  availability_zone = "ap-south-1a"
  size              = 2

  tags = {
    Name = "WebServer Volume"
  }
}

# Attaching the Harddisk to the OS 
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.MyVolume.id
  instance_id = aws_instance.web.id
}

# Stopping the Instance
resource "aws_ec2_instance_state" "Current_state" {
  instance_id = aws_instance.web.id
  state       = var.defaultInstanceState
}