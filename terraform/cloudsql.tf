resource "google_compute_global_address" "cloudsql_private_range" {
  name          = "i27-cloudsql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.i27_vpc.id
}

resource "google_service_networking_connection" "cloudsql_private_connection" {
  network                 = google_compute_network.i27_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.cloudsql_private_range.name]
}

resource "google_sql_database_instance" "i27_mysql" {
  name             = "i27-helpdesk-mysql"
  region           = var.region
  database_version = "MYSQL_8_0"

  deletion_protection = false

  depends_on = [
    google_service_networking_connection.cloudsql_private_connection
  ]

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 10
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.i27_vpc.id
    }

    backup_configuration {
      enabled = false
    }
  }
}

resource "google_sql_database" "helpdesk" {
  name     = "helpdesk_dev"
  instance = google_sql_database_instance.i27_mysql.name
}
