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
      git {
        repo_url = "https://github.com/m1xxos/DevOps-Projects.git"
        revision = "HEAD"
        directory {
          path = "gitlab-from-scratch/charts/*"
        }
      }
    }
    template {
      metadata {
        name = "{{path.basename}}"
      }
      spec {
        source {
          repo_url        = "https://github.com/m1xxos/DevOps-Projects.git"
          path            = "gitlab-from-scratch/argo/charts/{{path.basename}}"
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
