terraform {
  backend "gcs" {
    bucket = "i27-helpdesk-manoj-2026-tfstate"
    prefix = "terraform/dev"
  }
}
