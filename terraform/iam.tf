resource "google_service_account" "gke_nodes" {
  account_id   = "i27-gke-nodes"
  display_name = "i27 Helpdesk GKE Node Service Account"
}

resource "google_project_iam_member" "gke_node_role" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_artifact_registry_repository_iam_member" "gke_artifact_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.i27_repo.repository_id

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke_nodes.email}"
}
