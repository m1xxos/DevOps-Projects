resource "yandex_compute_instance_group" "app" {
  name = "app"
  service_account_id = yandex_iam_service_account.s3-sa.id
  instance_template {
    platform_id = "standard-v3"
    resources {
      cores = 2
      memory = 2
    }
    network_interface {
      network_id = yandex_vpc_network.project.id
      subnet_ids = [ yandex_vpc_subnet.app-d.id ]
    }
    boot_disk {
      disk_id = yandex_compute_disk.app-disk.id
    }
    network_settings {
      type = "STANDARD"
    }

  }
  scale_policy {
    auto_scale {
      initial_size = 1
      cpu_utilization_target = 70
      max_size = 3
      measurement_duration = 100
    }
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion = 1
  }
  allocation_policy {
    zones = ["ru-central1-d"]
  }
}

resource "yandex_compute_image" "ubuntu" {
    source_family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "app-disk" {
  image_id = yandex_compute_image.ubuntu.id
  size = 20
}
