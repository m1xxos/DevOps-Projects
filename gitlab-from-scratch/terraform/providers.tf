terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.139.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.7.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.2.0"
    }
  }
  required_version = ">= 0.13"
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1"
    key    = "gitlab-fs.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  zone      = "ru-central1-d"
  token     = var.token
  folder_id = var.folder_id
  cloud_id  = var.cloud_id
}

provider "helm" {
  kubernetes = {
    host                   = data.yandex_kubernetes_cluster.gitlab-cluster.master.0.external_v4_endpoint
    cluster_ca_certificate = data.yandex_kubernetes_cluster.gitlab-cluster.master.0.cluster_ca_certificate
    token                  = data.yandex_client_config.client.iam_token
  }
}

provider "kubernetes" {
  host                   = data.yandex_kubernetes_cluster.gitlab-cluster.master.0.external_v4_endpoint
  cluster_ca_certificate = data.yandex_kubernetes_cluster.gitlab-cluster.master.0.cluster_ca_certificate
  token                  = data.yandex_client_config.client.iam_token
}

provider "argocd" {
  username     = "m1xxos"
  auth_token   = var.argo_token
  port_forward = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
