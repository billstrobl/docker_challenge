########################################################################################################################
#
# Docker Deployer - Docker Module - docker_vars.tf
#
# This file contains all of the potential variables that can be passed as inputs to this TF template. Please note which
# are required. Also note any default values and override if necessary for your usage.
#
########################################################################################################################

variable "username" {
  type = string
  description = "The user that will be used to SSH to the remote instance and manage Docker."
}

variable "target_ip" {
  type = string
  description = "The IP of the target instance to run the desired Container."
}

variable "docker_repo_url" {
  type = string
  description = "The URL of the ECR repo hosting the desired Container."
}

variable "image_name" {
  type = string
  description = "The name of the image to use to build the desired Container."
}
