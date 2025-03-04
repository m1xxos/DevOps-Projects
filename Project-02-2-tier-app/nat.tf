resource "yandex_compute_image" "nat-instance-ubuntu" {
  source_family = "nat-instance-ubuntu"
}

resource "yandex_compute_disk" "boot-disk-nat" {
  name     = "boot-disk-nat"
  type     = "network-hdd"
  zone     = local.zone
  size     = "20"
  image_id = yandex_compute_image.nat-instance-ubuntu.id
}

resource "yandex_compute_instance" "nat-instance" {
  name        = local.vm_nat_name
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
    disk_id = yandex_compute_disk.boot-disk-nat.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.bastion-d.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${local.vm_user_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${local.ssh_key_path}")}"
  }
}
