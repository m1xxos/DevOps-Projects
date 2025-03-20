variable "sa-k8s" {
  type = string
  default = "sa-k8s"
}

resource "yandex_iam_service_account" "sa-k8s" {
    name = var.sa-k8s
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-editor" {
  folder_id = yandex_resourcemanager_folder.gitlab.id
  role = "editor"
  
  members = [ 
    "serviceAccount:${yandex_iam_service_account.sa-k8s.id}"
   ]
}
