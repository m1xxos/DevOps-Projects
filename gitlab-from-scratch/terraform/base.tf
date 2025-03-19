resource "yandex_resourcemanager_folder" "gitlab" {
  name = "gitlab"

  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_vpc_network" "gitlab" {
  name = "gitlab"
}

resource "yandex_vpc_subnet" "gitlab-ru-central1-a" {
  name = "gitlab-ru-central1-a"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_subnet" "gitlab-ru-central1-b" {
  name = "gitlab-ru-central1-b"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.129.0.0/24"]
}

resource "yandex_vpc_subnet" "gitlab-ru-central1-d" {
  name = "gitlab-ru-central1-d"
  zone = "ru-central1-d"
  network_id = yandex_vpc_network.gitlab.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}
