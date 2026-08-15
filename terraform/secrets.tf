resource "google_secret_manager_secret" "db_password" {
  secret_id = "i27-db-password"

  replication {
    auto {}
  }

  labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_secret_manager_secret" "jwt_secret" {
  secret_id = "i27-jwt-secret"

  replication {
    auto {}
  }

  labels = {
    project     = "i27-helpdesk"
    environment = var.environment
    managed_by  = "terraform"
  }
}
