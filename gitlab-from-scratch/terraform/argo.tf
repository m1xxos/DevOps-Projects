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
    namespace = "argocd"
  }
  data = {
    "accounts.m1xxos" = "apiKey, login"
  }
}

resource "kubernetes_config_map_v1_data" "argo-admin" {
  force = true
  metadata {
    name      = "argocd-rbac-cm"
    namespace = "argocd"
  }
  data = {
    "policy.csv" = "g, m1xxos, role:admin"
  }
}

resource "argocd_application_set" "helm-apps" {
  metadata {
    name      = "helm-apps"
    namespace = "argocd"
  }
  spec {
    generator {
      list {
        elements = [
          {
            repo = "https://traefik.github.io/charts"
            name = "traefik"
            target_revision = "34.4.1"
          },
          {
            repo = "https://prometheus-community.github.io/helm-charts"
            name = "prometheus-community"
            target_revision = "27.7.0"
          }
        ]
      }
    }
    template {
      metadata {
        name = "{{name}}"
      }
      spec {
        source {
          repo_url = "{{repo}}"
          chart    = "{{name}}"
          target_revision = "{{target_revision}}"
        }
        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "{{name}}"
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
