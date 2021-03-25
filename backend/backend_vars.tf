########################################################################################################################
#
# Docker Deployer - Backend Module - backend_vars.tf
#
# This file contains all of the potential variables that can be passed as inputs to this TF template. Please note
# default values and override if necessary for your usage.
#
########################################################################################################################

variable "region" {
  type = string
  default = "us-west-2"
  description = "The AWS region where the backend infrastructure will be created."
}


variable "vpc_id" {
  type = string
  description = "The ID of the VPC where the backend infrastructure will be created."
}


variable "cidr" {
  type = list
  default = ["10.0.0.0/32"]
  description = "The CIDR block used with the security group to open ports."
}


variable "open_ports" {
  type = list
  default = ["4567"]
  description = "The list of ports that will be exposed on the EC2 instance."
}


variable "task_name" {
  type = string
  description = "The name of the application that will be deployed."
}


variable "key_name" {
  type = string
  description = "The name of the key pair that will be associated with the new EC2 instance."
}


variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "The instance type that will be created to host the Docker Container."
}


variable "ecr_repo_name" {
  type = string
  description = "The name of the Docker repo in ECR that hosts the Container."
}
