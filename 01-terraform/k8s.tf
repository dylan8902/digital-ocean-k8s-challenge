data "digitalocean_kubernetes_versions" "version" {
  version_prefix = "1.21."
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name         = "challenge"
  region       = "lon1"
  auto_upgrade = true
  version      = data.digitalocean_kubernetes_versions.version.latest_version

  maintenance_policy {
    start_time  = "04:00"
    day         = "sunday"
  }

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"
    node_count = 3
  }
}
