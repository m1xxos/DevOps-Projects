resource "yandex_compute_image" "ubuntu" {
  source_family = "ubuntu-24-04-lts"
}

resource "yandex_compute_disk" "redis" {
  size = 20
  image_id = yandex_compute_image.ubuntu.id 
}

resource "yandex_compute_instance" "redis" {
    count = 3
    name = "redis-${count.index}"
    zone = "ru-central1-d"
    platform_id = "standard-v3"
    boot_disk {
        initialize_params {
        image_id = yandex_compute_image.ubuntu.id
        }
    }
    network_interface {
        subnet_id = "fl8ns818530umls1abo6"
        nat = true
    }
    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
    resources {
        cores = 2
        memory = 2
    }
    scheduling_policy {
        preemptible = true
    }
}