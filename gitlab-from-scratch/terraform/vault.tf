resource "yandex_kms_symmetric_key" "vault-key" {
  name              = "vault-key"
  default_algorithm = "AES_256"
  rotation_period   = "24h"
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "yandex_kubernetes_marketplace_helm_release" "vault" {
  name            = "vault"
  namespace       = "vault"
  cluster_id      = yandex_kubernetes_cluster.gitlab-cluster.id
  product_version = "f2ejsfsifanfq9h2ko3e" // vault 0.29.0_yckms
  user_values = {
    yandexKmsAuthJson = jsonencode({
      id                 = yandex_iam_service_account_key.vault-sa-key.id
      service_account_id = yandex_iam_service_account_key.vault-sa-key.service_account_id
      created_at         = yandex_iam_service_account_key.vault-sa-key.created_at
      key_algorithm      = yandex_iam_service_account_key.vault-sa-key.key_algorithm
      public_key         = yandex_iam_service_account_key.vault-sa-key.public_key
      private_key        = yandex_iam_service_account_key.vault-sa-key.private_key
    })
    "server.extraEnvironmentVars.YANDEXCLOUD_KMS_KEY_ID" = yandex_kms_symmetric_key.vault-key.id
  }
}
