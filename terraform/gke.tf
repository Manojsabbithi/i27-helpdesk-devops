resource "google_container_cluster" "i27_cluster" {
  name     = "i27-helpdesk-gke"
  location = var.zone

  network    = google_compute_network.i27_vpc.id
  subnetwork = google_compute_subnetwork.i27_subnet.id

  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }
}


resource "google_container_node_pool" "i27_nodes" {
  name       = "i27-helpdesk-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.i27_cluster.name
  node_count = 1

  node_config {
    machine_type = "e2-standard-2"
    disk_type    = "pd-balanced"
    disk_size_gb = 30

    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
      project     = "i27-helpdesk"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  depends_on = [
    google_project_iam_member.gke_node_role,
    google_artifact_registry_repository_iam_member.gke_artifact_reader
  ]
}
