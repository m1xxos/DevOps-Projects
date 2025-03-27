resource "yandex_resourcemanager_folder" "gitlab" {
  name = "gitlab"

  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_vpc_network" "gitlab" {
  name = "gitlab"
}

resource "yandex_vpc_address" "traefik-address" {
  name = "traefik-address"
  external_ipv4_address {
    zone_id = "ru-central1-d"
  }
}

resource "yandex_vpc_subnet" "gitlab-ru-central1-a" {
  name           = "gitlab-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_subnet" "gitlab-ru-central1-b" {
  name           = "gitlab-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.129.0.0/24"]
}

resource "yandex_vpc_subnet" "gitlab-ru-central1-d" {
  name           = "gitlab-ru-central1-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}

resource "yandex_vpc_security_group" "gitlab-cluster-nodegroup-traffic" {
  name       = "gitlab-cluster-nodegroup-traffic"
  network_id = yandex_vpc_network.gitlab.id

  ingress {
    from_port         = 0
    to_port           = 65535
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }
}

resource "yandex_vpc_security_group" "gitlab-nodegroup-traffic" {
  name       = "gitlab-nodegroup-traffic"
  network_id = yandex_vpc_network.gitlab.id
  ingress {
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["10.96.0.0/16", "10.112.0.0/16"]
  }
  egress {
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "gitlab-cluster-traffic" {
  name       = "gitlab-cluster-traffic"
  network_id = yandex_vpc_network.gitlab.id
  ingress {
    description    = "Правило для входящего трафика, разрешающее доступ к API Kubernetes (порт 443)."
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description    = "Правило для входящего трафика, разрешающее доступ к API Kubernetes (порт 6443)."
    port           = 6443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description    = "Правило для исходящего трафика, разрешающее передачу трафика между мастером и подами metric-server."
    port           = 4443
    protocol       = "TCP"
    v4_cidr_blocks = ["10.96.0.0/16"]
  }
}

resource "yandex_vpc_security_group" "gitlab-worker-access" {
  name       = "gitlab-worker-access"
  network_id = yandex_vpc_network.gitlab.id
  ingress {
    description    = "Правило для входящего трафика, разрешающее подключение к узлам по SSH."
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port      = 30000
    to_port        = 32767
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
