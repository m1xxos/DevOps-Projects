resource "yandex_kms_symmetric_key" "vault-key" {
  name              = "vault-key"
  default_algorithm = "AES_256"
  rotation_period   = "24h"
}

output "key" {
  value = yandex_iam_service_account_key.vault-sa-key.public_key
  sensitive = true
}
