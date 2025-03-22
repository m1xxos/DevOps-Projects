variable "sa-k8s" {
  type    = string
  default = "sa-k8s"
}

variable "sa-k8s-node" {
  type    = string
  default = "sa-k8s-node"
}

variable "vault-kms" {
  type    = string
  default = "vault-kms"
}

resource "yandex_iam_service_account" "sa-k8s" {
  name = var.sa-k8s
}

resource "yandex_iam_service_account" "sa-k8s-node" {
  name = var.sa-k8s-node
}

resource "yandex_iam_service_account" "vault-kms" {
  name = var.vault-kms
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-editor" {
  folder_id = yandex_resourcemanager_folder.gitlab.id
  role      = "editor"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-puller" {
  folder_id = yandex_resourcemanager_folder.gitlab.id
  role      = "container-registry.images.puller"

  members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s-node.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "name" {
  folder_id = yandex_resourcemanager_folder.gitlab.id
  role      = "kms.keys.encrypterDecrypter"

  members = [
    "serviceAccount:${yandex_iam_service_account.vault-kms.id}"
  ]
}

resource "yandex_iam_service_account_key" "vault-sa-key" {
  service_account_id = yandex_iam_service_account.vault-kms
}
