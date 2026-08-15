resource "google_storage_bucket" "tfstate" {
  name          = "i27-helpdesk-manoj-2026-tfstate"
  location      = "ASIA-SOUTH1"
  storage_class = "STANDARD"

  force_destroy = false

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = {
    project    = "i27-helpdesk"
    purpose    = "terraform-state"
    managed_by = "terraform"
  }
}

output "tfstate_bucket_name" {
  value = google_storage_bucket.tfstate.name
}
