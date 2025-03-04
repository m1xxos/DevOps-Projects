resource "yandex_compute_image" "ubuntu-1804-lts" {
  source_family = "ubuntu-1804-lts"
}

resource "yandex_compute_disk" "boot-disk-ubuntu" {
  name     = "boot-disk-ubuntu"
  type     = "network-hdd"
  zone     = local.zone
  size     = "20"
  image_id = yandex_compute_image.ubuntu-1804-lts.id
}

resource "yandex_compute_instance" "test-vm" {
  name        = "test-vm"
  platform_id = "standard-v3"
  zone        = local.zone

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-ubuntu.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app-d.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${local.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${local.ssh_key_path}")}"
  }
}