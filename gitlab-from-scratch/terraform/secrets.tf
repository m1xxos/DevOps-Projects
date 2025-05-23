resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "example" {
  mount               = vault_mount.kvv2.path
  name                = "secret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar"
    }
  )
  custom_metadata {
    max_versions = 5
    data = {
      foo = "vault@example.com",
      bar = "12345"
    }
  }
}

resource "vault_kv_secret_v2" "cloudflare-api-token-secret" {
  mount = vault_mount.kvv2.path
  name  = "cloudflare-api-token-secret"
  cas   = 1
  data_json = jsonencode(
    {
      cloudflare-api-token-secret = var.cloudflare_api_token
    }
  )
}
