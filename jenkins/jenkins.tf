provider "google" {
  credentials = file("/Users/veemana/sme-sessions/secrets/google-key/fine-craft-384611-e1246396d492.json")
  project     = "fine-craft-384611"
  region      = "us-central1"
}

resource "google_compute_instance" "jenkins_server" {
  name         = "jenkins-server"
  machine_type = "n1-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "rhel-8"
    }
  }
  tags = ["jenkins-server", "webserver", "production"]
  metadata_startup_script = <<-EOF
    #!/bin/bash

    # Install Java Development Kit (JDK)
    yum install fontconfig java-11-openjdk -y
    
    #Install wget
    yum install wget -y 

    # Install Jenkins
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
    yum install jenkins -y

    # Start Jenkins service
    systemctl start jenkins
    systemctl enable jenkins

    # Installing docker
    yum install -y yum-utils device-mapper-persistent-data lvm2 -y
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    systemctl start docker
    systemctl enable docker

    # Install git
    yum install git -y


  EOF

  metadata = {
    ssh-keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDP2UbOVPTkZspxjrK+pyP1P9WxMRmZ9w7k01o8HKZ+VDlGgV0bQRw7MaFkxx7gY3fkawgIMo1yJp5HKx+e+c7H9yuY9fL4Tnmbrs0c0JnhnpcPGfgSHcQh5zoVerRtyprI2Iywul2VMOaWrX5se0tKfFVlJboO1dUv7dMDm1MQYdCz04GuEcd4wDN/he0QS7ZEivA317k1lwKTfA5jVnYBe67L2tYuQktFdwg+WD720CCYWfZB3FNHYOodEdHkhkgog1NisbYfFBkNJ11wNI9khk4GFM90agx4fz3WDXt0nskHzhqA/WbpFswR6xdbGvfICazQG8AVg85OX4knsZqIL062YDNe/f00jy2HPt7RnVkP66tZ7ro4R390nE076f9j9UBqwtCWAAVzZMrOsLGFJsDfO6B8+1y7GgFgRXrqQm3xbFptGrZM6H9Qgb4NSR4JARpY18sb/fa4CVAOOfc/vtp1Ku12AyCfKt2ls6R1Y106vul768ysd6WJJleCAWM= veemana@Arumugams-MacBook-Pro.local"
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_firewall" "jenkins_firewall" {
  name    = "jenkins-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-server"]
}

