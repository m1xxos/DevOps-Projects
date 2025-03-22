resource "yandex_kms_symmetric_key" "vault-key" {
  name              = "vault-key"
  default_algorithm = "aes-256"
  rotation_period   = "24h"
}
