resource "yandex_storage_bucket" "app" {
  folder_id = var.folder_id
  bucket = "app-proj2-m1xxos"
}

resource "yandex_iam_service_account" "s3-sa" {
  name      = "s3-proj2-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-editor" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "compute-admin" {
  folder_id = var.folder_id
  role      = "compute.admin"
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-user" {
  folder_id = var.folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.s3-sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.s3-sa.id
  description        = "static access key for object storage"
}
