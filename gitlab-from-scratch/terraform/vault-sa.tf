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

resource "vault_policy" "gitlab-cert-viewer" {
  name   = "gitlab-cert-viewer"
  policy = <<EOT
path "kvv2${vault_kv_secret_v2.cloudflare-api-token-secret.name}" {
  capabilities = ["read", "list"]
}

path "kvv2/data/${vault_kv_secret_v2.cloudflare-api-token-secret.name}" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_token" "gitlab-cert-sa" {
  policies = [vault_policy.gitlab-cert-viewer.name]
}

resource "kubernetes_secret" "gitlab-cert-token" {
  metadata {
    name      = "gitlab-cert-token"
    namespace = "cert-manager"
  }
  data = {
    "gitlab-vault-token" = vault_token.gitlab-cert-sa.client_token
  }
}
