resource "yandex_resourcemanager_folder" "project-2" {
  name = "project-2"
  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_vpc_network" "project" {
  name = "project"
}

resource "yandex_vpc_subnet" "bastion-d" {
  name = "bastion-ru-central1-d"
  network_id = yandex_vpc_network.project.id
  v4_cidr_blocks = [ "192.168.0.0/16" ]
  zone = local.zone
}

resource "yandex_vpc_subnet" "app-d" {
  name = "app-ru-central1-d"
  network_id = yandex_vpc_network.project.id
  v4_cidr_blocks = [ "172.16.0.0/16" ]
  zone = local.zone
}

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "sg-nat"
  network_id = yandex_vpc_network.project.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}
