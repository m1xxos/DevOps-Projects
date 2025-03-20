resource "yandex_kubernetes_cluster" "gitlab-cluster" {
  name       = "gitlab-cluster"
  network_id = yandex_vpc_network.gitlab.id

  cluster_ipv4_range = "10.96.0.0/16"
  service_ipv4_range = "10.112.0.0/16"

  master {
    version = "1.31"
    zonal {
      zone      = yandex_vpc_subnet.gitlab-ru-central1-d.zone
      subnet_id = yandex_vpc_subnet.gitlab-ru-central1-d.id

    }

    public_ip = true

    security_group_ids = [
      yandex_vpc_security_group.gitlab-cluster-nodegroup-traffic.id,
      yandex_vpc_security_group.gitlab-cluster-traffic.id
    ]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "21:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.sa-k8s.id
  node_service_account_id = yandex_iam_service_account.sa-k8s-node.id

  release_channel = "REGULAR"

  depends_on = [
    yandex_iam_service_account.sa-k8s,
    yandex_iam_service_account.sa-k8s-node
  ]
}

resource "yandex_kubernetes_node_group" "gitlab-node-group" {
  name       = "gitlab-node-group"
  cluster_id = yandex_kubernetes_cluster.gitlab-cluster.id
  version    = "1.31"

  instance_template {
    platform_id = "standard-v3"
    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.gitlab-ru-central1-d.id}"]
      security_group_ids = [
        yandex_vpc_security_group.gitlab-cluster-nodegroup-traffic.id,
        yandex_vpc_security_group.gitlab-nodegroup-traffic.id,
        yandex_vpc_security_group.gitlab-worker-access.id
      ]
    }

    resources {
      memory = 4
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    auto_scale {
      initial = 1
      min     = 1
      max     = 2
    }
  }

  maintenance_policy {
    auto_repair  = true
    auto_upgrade = true

    maintenance_window {
      start_time = "21:00"
      duration   = "3h"
    }
  }

}
