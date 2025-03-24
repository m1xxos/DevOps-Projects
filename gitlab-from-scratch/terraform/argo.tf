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


# resource "kubernetes_config_map" "argo-user" {
#   force = true
#   metadata {
#     name      = "argocd-cm"
#     namespace = "argocd"
#     labels = {
#       "app.kubernetes.io/name"    = "argocd-cm"
#       "app.kubernetes.io/part-of" = "argocd"
#     }
#   }
#   data = {
#     "accounts.m1xxos" = "apiKey, login"
#   }
# }
