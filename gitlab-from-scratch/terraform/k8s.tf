resource "yandex_kubernetes_cluster" "gitlab-cluster" {
  name = "gitlab-cluster"
  network_id = yandex_vpc_network.gitlab.id
  master {
    version = "1.31"
    zonal {
      zone = yandex_vpc_subnet.gitlab-ru-central1-d.zone
      subnet_id = yandex_vpc_subnet.gitlab-ru-central1-d.id
    }

    public_ip = true
    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "21:00"
        duration   = "3h"
      }
    }
  }

  service_account_id = yandex_iam_service_account.sa-k8s.id
  node_service_account_id = yandex_iam_service_account.sa-k8s-node.id
  
  release_channel = "STABLE"

  depends_on = [ 
    yandex_iam_service_account.sa-k8s, 
    yandex_iam_service_account.sa-k8s-node
  ]
}