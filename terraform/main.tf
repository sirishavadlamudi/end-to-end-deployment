resource "google_compute_instance" "app_vm" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["backend-vm"]

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    CONTAINER_IMAGE="${container_image}"
    docker pull "$CONTAINER_IMAGE"
    docker run -d --restart always --name backend -p 80:8000 "$CONTAINER_IMAGE"
  EOF
}

output "instance_ip" {
  value = google_compute_instance.app_vm.network_interface[0].access_config[0].nat_ip
}
