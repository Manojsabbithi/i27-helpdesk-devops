resource "google_artifact_registry_repository" "i27_repo" {
  location      = var.region
  repository_id = "i27-helpdesk"
  description   = "Docker images for i27 Helpdesk microservices"
  format        = "DOCKER"

  labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    managed_by  = "terraform"
  }
}
