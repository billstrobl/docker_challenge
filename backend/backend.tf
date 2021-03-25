########################################################################################################################
#
# Docker Deployer - Backend Module
#
# This template is intended to create the required infrastructure and configuration to run a Docker container in AWS.
# This will create an ec2 instance/volume using the latest Amazon Linux AMI, and any other resources required for an ec2
# instance to run a Docker container e.g. security groups with the correct ports exposed.
#
# NOTES: Please be aware that in addition to the ports required for the application, port 22 is exposed for Docker
#         management via SSH. This is always added to the security group, despite the other ports being variables.
#        This template also uses an S3 backend for remote statefile management. The bucket and dynamo table must already
#         exist before this template can be used.
#
########################################################################################################################

// Init and Config
terraform {
  required_version = ">= 0.13.5"

  required_providers {
    aws = ">= 3.0.0"
  }

  backend "s3" {
    key            = "docker_deploy/terraform.state"
    region         = "us-west-2"
    bucket         = "state-bucket"
    dynamodb_table = "state-locks"
    encrypt        = true
  }
}


// Provider
provider "aws" {
  region = var.region
}


// ECR Data Lookup
data "aws_ecr_repository" "rootdevs_docker_repo" {
  name  = var.ecr_repo_name
}


// IAM Roles and Profiles
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}


resource "aws_iam_role" "ec2_role" {
  name = "${var.task_name}_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json

  tags = { project = var.task_name }
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.task_name}_ec2_profile"
  role = aws_iam_role.ec2_role.name
}


data "aws_iam_policy_document" "instance-ecr-access-policy" {
  statement {
    actions = ["ecr:GetAuthorizationToken", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
    effect = "Allow"
    resources = [data.aws_ecr_repository.rootdevs_docker_repo.arn]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}


resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.task_name}_ec2_policy"
  role = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.instance-ecr-access-policy
}


// Security Group
resource "aws_security_group" "docker_deploy_sg" {
  description = "Security group for ${var.task_name}. Allows traffic only on ${var.open_ports}"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.open_ports
    content {
      protocol    = "http"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = var.cidr
    }
  }

  ingress {
    protocol = "ssh"
    from_port = 22
    to_port = 22
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.task_name}_sg"
  }
}


// AMI Lookup
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["*amzn2-ami-hvm*-x86_64*"]
  }
}


// EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name = var.key_name
  monitoring = true
  ebs_optimized = true

  // Volume matched to Amazon Linux AMI
  root_block_device {
    volume_size = 8
  }

  vpc_security_group_ids = [ aws_security_group.docker_deploy_sg.id ]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    project = var.task_name
    environment = "dev"
    name = "${var.task_name}_server"
  }

  volume_tags = {
    project = var.task_name
    environment = "dev"
    name = "${var.task_name}_server"
  }
}
