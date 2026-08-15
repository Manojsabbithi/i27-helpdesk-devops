resource "google_compute_global_address" "helpdesk_ingress_ip" {
  name         = "i27-helpdesk-ingress-ip"
  address_type = "EXTERNAL"
}

output "ingress_static_ip" {
  value = google_compute_global_address.helpdesk_ingress_ip.address
}
