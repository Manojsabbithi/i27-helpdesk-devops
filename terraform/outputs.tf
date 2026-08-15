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

output "gke_cluster_name" {
  value = google_container_cluster.i27_cluster.name
}

output "gke_cluster_location" {
  value = google_container_cluster.i27_cluster.location
}

output "gke_node_service_account" {
  value = google_service_account.gke_nodes.email
}

output "cloudsql_instance_name" {
  value = google_sql_database_instance.i27_mysql.name
}

output "cloudsql_private_ip" {
  value = google_sql_database_instance.i27_mysql.private_ip_address
}

output "cloudsql_database_name" {
  value = google_sql_database.helpdesk.name
}
