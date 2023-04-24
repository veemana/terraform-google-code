resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh.public_key_openssh
  filename = "${path.module}/id_rsa.pub"
}

resource "google_compute_project_metadata_item" "ssh_key" {
  key   = "ssh-keys"
  value = "${local_file.public_key.content}"
}

resource "google_compute_instance" "example" {
  count = 2

  name         = "example${count.index + 1}-instance"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  metadata = {
    ssh-keys = "${google_compute_project_metadata_item.ssh_key.value}"
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    useradd -m -p $(openssl passwd -1 password) user1
    useradd -m -p $(openssl passwd -1 password) user2
  EOF

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}
