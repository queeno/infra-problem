output "private_ip_address" {
    value = ["${google_compute_instance.thoughtworks.*.network_interface.0.address}"]
}

output "public_ip_address" {
    value = ["${google_compute_instance.thoughtworks.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}

output "zones" {
    value = ["${google_compute_instance.thoughtworks.*.zone}"]
}

output "names" {
    value = ["${google_compute_instance.thoughtworks.*.name}"]
}
