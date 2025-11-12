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
    access_config {} # external IP
  }

  metadata = {
    # disable oslogin so SSH keys via metadata work (optional)
    enable-oslogin = "FALSE"
  }

  tags = ["backend-vm"]

  # Startup script: installs docker, pulls container and runs it as detached container.
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # Update and install docker
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Install Docker (official script)
    if ! command -v docker >/dev/null 2>&1; then
      curl -fsSL https://get.docker.com | sh
    fi

    # Wait for docker to be up
    sleep 5

    # ensure container_image variable is available to script
    CONTAINER_IMAGE="${container_image}"

    # If the variable hasn't been substituted, check metadata key fallback
    if [ -z "$CONTAINER_IMAGE" ] || [ "$CONTAINER_IMAGE" = "null" ]; then
      # try to read custom metadata key 'container-image'
      CONTAINER_IMAGE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/container-image)
    fi

    echo "Using image: $CONTAINER_IMAGE"

    # Pull and run the container
    docker pull "$CONTAINER_IMAGE" || true

    # Stop any existing container named app-backend
    if docker ps -a --format '{{.Names}}' | grep -q '^app-backend$'; then
      docker rm -f app-backend || true
    fi

    # run container (map port 80 on host to 8000 inside container as an example; adjust as needed)
    docker run -d --restart always --name app-backend -p 80:8000 "$CONTAINER_IMAGE"
  EOF
}

# Attach custom metadata value of the container image (useful if you want metadata instead of text substitution)
resource "google_compute_instance" "app_vm_metadata" {
  depends_on = [google_compute_instance.app_vm]

  # This is intentionally empty resource to attach the metadata attribute using the "google_compute_instance" above.
  # NOTE: we already embedded the script including ${container_image} substitution by Terraform interpolation
  # So this resource is optional. Keeping as placeholder to show alternatives.
}
