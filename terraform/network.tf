resource "google_compute_network" "i27_vpc" {
  name                    = "i27-helpdesk-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "i27_subnet" {
  name          = "i27-helpdesk-subnet"
  ip_cidr_range = "10.10.0.0/20"
  region        = var.region
  network       = google_compute_network.i27_vpc.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }

  private_ip_google_access = true
}
