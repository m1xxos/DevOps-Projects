resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.8.13"
  values     = [file("files/argo-values.yaml")]
}


resource "kubernetes_config_map_v1_data" "argo-user" {
  force = true
  metadata {
    name      = "argocd-cm"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  data = {
    "accounts.m1xxos" = "apiKey, login"
  }
}

resource "kubernetes_config_map_v1_data" "argo-admin" {
  force = true
  metadata {
    name      = "argocd-rbac-cm"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  data = {
    "policy.csv" = "g, m1xxos, role:admin"
  }
}

resource "argocd_application" "configs" {
  metadata {
    name      = "configs"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  spec {
    source {
      repo_url = var.repo_url
      path     = "gitlab-from-scratch/argo/configs"
    }
    destination {
      server = "https://kubernetes.default.svc"
    }
  }
}


resource "argocd_application_set" "helm-apps" {
  metadata {
    name      = "helm-apps"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  spec {
    generator {
      git {
        repo_url = var.repo_url
        revision = "HEAD"
        directory {
          path = "${var.charts_path}/*"
        }
      }
    }
    template {
      metadata {
        name = "{{path.basename}}"
      }
      spec {
        source {
          repo_url        = var.repo_url
          path            = "${var.charts_path}/{{path.basename}}"
          target_revision = "HEAD"
          helm {
            value_files = ["../../values/{{path.basename}}.yaml"]
          }
        }
        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "{{path.basename}}"
        }
        sync_policy {
          automated {
            prune     = true
            self_heal = true
          }
          sync_options = [
            "CreateNamespace=true"
          ]
        }
      }
    }
  }
}
