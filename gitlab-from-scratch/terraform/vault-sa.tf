resource "vault_policy" "gitlab-viewer" {
  name   = "gitlab-viewer"
  policy = <<EOT
path "kvv2/*" {
  capabilities = ["read", "list"]
}

path "kvv2/data/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_token" "gitlab-vault-sa" {
  policies = [vault_policy.gitlab-viewer.name]
}

resource "kubernetes_secret" "gitlab-vault-token" {
  metadata {
    name      = "gitlab-vault"
    namespace = "external-secrets"
  }
  data = {
    "gitlab-vault-token" = vault_token.gitlab-vault-sa.client_token
  }
}
