output "project_id" {
  value = var.project_id
}

output "vpc_name" {
  value = google_compute_network.i27_vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.i27_subnet.name
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.i27_repo.name
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.i27_repo.repository_id}"
}
