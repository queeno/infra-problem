resource "google_compute_target_pool" "thoughtworks" {
  name              = "lb-${var.name}"
  instances         = ["${formatlist("%s/%s", var.zones, var.instances)}"]
  health_checks     = ["${google_compute_http_health_check.thoughtworks.name}"]
}

resource "google_compute_forwarding_rule" "thoughtworks" {
  name       = "fr-${var.name}"
  target     = "${google_compute_target_pool.thoughtworks.self_link}"
  port_range = "${var.port}-${var.port}"
}

resource "google_compute_http_health_check" "thoughtworks" {
  name                = "hc-${var.name}"
  port                = "${var.port}"
  request_path        = "${var.request_path}"
  check_interval_sec  = "${var.check_interval_sec}"
  healthy_threshold   = "${var.healthy_threshold}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  timeout_sec         = "${var.timeout_sec}"
}
