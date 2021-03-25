########################################################################################################################
#
# Docker Deployer - Docker Module
#
# This module will deploy and start the desired Docker container on the desired host instance. It will also create a
# Docker service to monitor the health of the container and restart if the application fails.
#
# NOTE: The port that will be opened between the host environment and the container is currently hardcoded to 4567.
#         If your application requires a different port to be open, please update this code to use a variable :)
#
########################################################################################################################

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
  required_version = ">= 0.13"
}


provider "docker" {
  host = "ssh://${var.username}@${var.target_ip}:22"
}


resource "docker_container" "rootdevs_interview_container" {
  image = var.image_name
  name = "rootdevs_interview_container"
}


resource "docker_service" "rootdevs_interview_service" {
  name = "rootdevs_interview_service"
  task_spec {
    container_spec {
      image = "${var.docker_repo_url}:8080/${var.image_name}"

      labels {
        label = "Name"
        value = "rootdevs_interview_service"
      }

      healthcheck {
        test = ["CMD", "curl", "http://localhost:4567"]
      }
    }

   restart_policy = {
      condition    = "on-failure"
      delay        = "3s"
      max_attempts = 4
    }
  }

  endpoint_spec {
    ports {
      target_port = 4567
    }
  }
}
