resource "yandex_kms_symmetric_key" "vault-key" {
  name              = "vault-key"
  default_algorithm = "AES_256"
  rotation_period   = "24h"
}

output "key" {
  value = jsonencode({
          id = yandex_iam_service_account_key.vault-sa-key.id
          service_account_id = yandex_iam_service_account_key.vault-sa-key.service_account_id
          created_at = yandex_iam_service_account_key.vault-sa-key.created_at
          key_algorithm = yandex_iam_service_account_key.vault-sa-key.key_algorithm
          public_key = yandex_iam_service_account_key.vault-sa-key.public_key
          private_key = yandex_iam_service_account_key.vault-sa-key.private_key
        })
  sensitive = true
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault" {
  name = "vault"
  namespace = kubernetes_namespace.vault.metadata[0].name
  repository = "oci://cr.yandex/yc-marketplace/yandex-cloud/vault/chart/"
  chart = "vault"
  version = "0.28.1+yckms"
  wait = true
  set = [
      {
        name = "yandexKmsAuthJson"
        value = file("./authorized-key.json")
        # value = jsonencode({
        #   id = yandex_iam_service_account_key.vault-sa-key.id
        #   service_account_id = yandex_iam_service_account_key.vault-sa-key.service_account_id
        #   created_at = yandex_iam_service_account_key.vault-sa-key.created_at
        #   key_algorithm = yandex_iam_service_account_key.vault-sa-key.key_algorithm
        #   public_key = yandex_iam_service_account_key.vault-sa-key.public_key
        #   private_key = yandex_iam_service_account_key.vault-sa-key.private_key
        # })
      },
      {
        name = "yandexKmsKeyId"
        value = yandex_kms_symmetric_key.vault-key.id
      }
    ]
}
