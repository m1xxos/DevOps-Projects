variable "token" {
  type      = string
  sensitive = true
}

variable "folder_id" {
  type      = string
  sensitive = true
}

variable "cloud_id" {
  type      = string
  sensitive = true
}

variable "argo_token" {
  type = string
}

variable "repo_url" {
  type    = string
  default = "https://github.com/m1xxos/DevOps-Projects.git"
}

variable "charts_path" {
  type    = string
  default = "gitlab-from-scratch/argo/charts"
}

variable "cloudflare_zone_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "main_domain" {
  type = string
  default = "gitlab.m1xxos.tech"
}
