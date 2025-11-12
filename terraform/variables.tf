variable "project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "machine_type" {
  default = "e2-micro"
}

variable "instance_name" {
  default = "backend-vm"
}

variable "container_image" {
  description = "Docker image to deploy"
  type        = string
}
