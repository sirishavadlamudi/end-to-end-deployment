# Create a Compute Engine VM and run your backend Docker container on startup

resource "google_compute_instance" "app_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  # Attach the VM to the default VPC and give it an external IP
  network_interface {
    network       = "default"
    access_config {}
  }

  # Optional: tags for firewall rules or identification
  tags = ["backend-vm"]

  # Startup script: install Docker, pull your image, and run it
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # Update and install Docker
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Install Docker
    curl -fsSL https://get.docker.com | sh
    systemctl start docker

    # Get container image variable from Terraform
    CONTAINER_IMAGE="${var.container_image}"
    echo "Using image: $CONTAINER_IMAGE"

    # Pull and run the container
    docker pull "$CONTAINER_IMAGE"
    docker run -d --restart always --name backend -p 80:8000 "$CONTAINER_IMAGE"
  EOF
}

# Output the instance name and public IP
output "instance_name" {
  value = google_compute_instance.app_vm.name
}

output "instance_ip" {
  value =
}