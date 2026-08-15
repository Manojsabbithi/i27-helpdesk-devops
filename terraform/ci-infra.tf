# ============================================================
# CI/CD INFRASTRUCTURE
# Jenkins Controller + Jenkins Agent + SonarQube
# ============================================================

# ------------------------------------------------------------
# Service Accounts
# ------------------------------------------------------------

resource "google_service_account" "jenkins_controller" {
  account_id   = "i27-jenkins-controller"
  display_name = "i27 Jenkins Controller"
}

resource "google_service_account" "jenkins_agent" {
  account_id   = "i27-jenkins-agent"
  display_name = "i27 Jenkins Build Agent"
}

resource "google_service_account" "sonarqube" {
  account_id   = "i27-sonarqube"
  display_name = "i27 SonarQube"
}


# ------------------------------------------------------------
# Jenkins Agent permissions
# ------------------------------------------------------------

# Jenkins Agent must be able to push Docker images.
resource "google_artifact_registry_repository_iam_member" "jenkins_agent_writer" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.i27_repo.repository_id

  role = "roles/artifactregistry.writer"

  member = "serviceAccount:${google_service_account.jenkins_agent.email}"
}

# Allows Jenkins Agent to discover/authenticate to the GKE cluster.
# Kubernetes authorization will be restricted separately with RBAC.
resource "google_project_iam_member" "jenkins_agent_cluster_viewer" {
  project = var.project_id
  role    = "roles/container.clusterViewer"

  member = "serviceAccount:${google_service_account.jenkins_agent.email}"
}


# ------------------------------------------------------------
# Firewall - IAP administration
# ------------------------------------------------------------

resource "google_compute_firewall" "allow_iap_ci" {
  name    = "i27-allow-iap-ci"
  network = google_compute_network.i27_vpc.name

  direction = "INGRESS"

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = [
    "i27-ci"
  ]

  allow {
    protocol = "tcp"

    ports = [
      "22",
      "8080",
      "9000"
    ]
  }
}


# ------------------------------------------------------------
# Jenkins Agent -> Jenkins Controller
# ------------------------------------------------------------

resource "google_compute_firewall" "allow_agent_to_controller" {
  name    = "i27-allow-agent-controller"
  network = google_compute_network.i27_vpc.name

  direction = "INGRESS"

  source_tags = [
    "jenkins-agent"
  ]

  target_tags = [
    "jenkins-controller"
  ]

  allow {
    protocol = "tcp"

    ports = [
      "8080"
    ]
  }
}


# ------------------------------------------------------------
# Jenkins -> SonarQube
# ------------------------------------------------------------

resource "google_compute_firewall" "allow_jenkins_to_sonar" {
  name    = "i27-allow-jenkins-sonar"
  network = google_compute_network.i27_vpc.name

  direction = "INGRESS"

  source_tags = [
    "jenkins-controller",
    "jenkins-agent"
  ]

  target_tags = [
    "sonarqube"
  ]

  allow {
    protocol = "tcp"

    ports = [
      "9000"
    ]
  }
}


# ------------------------------------------------------------
# Jenkins Controller
# ------------------------------------------------------------

resource "google_compute_instance" "jenkins_controller" {
  name         = "i27-jenkins-controller"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = [
    "i27-ci",
    "jenkins-controller"
  ]

  labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    role        = "jenkins-controller"
    managed_by  = "terraform"
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"

      size = 30
      type = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.i27_subnet.id

    # External IP is currently used for outbound package downloads.
    # No application ports are publicly opened by our firewall.
    access_config {}
  }

  service_account {
    email = google_service_account.jenkins_controller.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


# ------------------------------------------------------------
# Jenkins Build Agent
# ------------------------------------------------------------

resource "google_compute_instance" "jenkins_agent" {
  name         = "i27-jenkins-agent"
  machine_type = "e2-medium"
  zone         = var.zone

  tags = [
    "i27-ci",
    "jenkins-agent"
  ]

  labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    role        = "jenkins-agent"
    managed_by  = "terraform"
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"

      size = 50
      type = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.i27_subnet.id

    access_config {}
  }

  service_account {
    email = google_service_account.jenkins_agent.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.jenkins_agent_writer,
    google_project_iam_member.jenkins_agent_cluster_viewer
  ]
}


# ------------------------------------------------------------
# SonarQube
# ------------------------------------------------------------

resource "google_compute_instance" "sonarqube" {
  name         = "i27-sonarqube"
  machine_type = "e2-standard-2"
  zone         = var.zone

  tags = [
    "i27-ci",
    "sonarqube"
  ]

  labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    role        = "sonarqube"
    managed_by  = "terraform"
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"

      size = 50
      type = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.i27_subnet.id

    access_config {}
  }

  service_account {
    email = google_service_account.sonarqube.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


# ------------------------------------------------------------
# Outputs
# ------------------------------------------------------------

output "jenkins_controller_name" {
  value = google_compute_instance.jenkins_controller.name
}

output "jenkins_controller_private_ip" {
  value = google_compute_instance.jenkins_controller.network_interface[0].network_ip
}

output "jenkins_agent_name" {
  value = google_compute_instance.jenkins_agent.name
}

output "jenkins_agent_private_ip" {
  value = google_compute_instance.jenkins_agent.network_interface[0].network_ip
}

output "sonarqube_name" {
  value = google_compute_instance.sonarqube.name
}

output "sonarqube_private_ip" {
  value = google_compute_instance.sonarqube.network_interface[0].network_ip
}
