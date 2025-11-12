variable "project" {
  type        = string
  description = "GCP project id"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "container_image" {
  type        = string
  description = "Container image (dockerhub) to run on VM, e.g. myuser/myrepo:latest"
}

variable "instance_name" {
  type    = string
  default = "tf-backend-vm"
}
