data "template_file" "hostname" {
    count    = "${var.instances}"
    template = "${var.role}-${count.index + 1}"
}

data "template_file" "fqdn" {
    count    = "${var.instances}"
    template = "${data.template_file.hostname.*.rendered[count.index]}.gcloud-${var.region}.${var.environment}"
}


resource "google_compute_instance" "thoughtworks" {
    count = "${var.instances}"
    name = "vm-${data.template_file.hostname.*.rendered[count.index]}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone[count.index % length(var.zone)]}"
    tags = ["${var.role}"]
    depends_on = ["google_compute_disk.thoughtworks"]

    disk {
        image = "${var.image}"
        auto_delete = true
    }

    disk {
        disk = "disk-${data.template_file.hostname.*.rendered[count.index]}"
        auto_delete = "${var.disk_auto_delete}"
    }

    network_interface {
        network = "default"
        access_config = {}
    }

    metadata {
        sshKeys = "core:${file(var.public_key_path)}"
        #"user-data" = "${file("${var.cloud_config_file}")}"
    }

    /*service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]
    }*/

}

resource "google_compute_disk" "thoughtworks" {
    count = "${var.instances}"
    name = "disk-${data.template_file.hostname.*.rendered[count.index]}"
    type = "${var.disk_type}"
    zone = "${var.zone[count.index % length(var.zone)]}"
    size = "${var.disk_size}"
}

resource "google_compute_firewall" "thoughtworks" {
    count = "${length(var.fw_rules)}"

    name = "${var.role}-${lookup(var.fw_rules[count.index], "name")}"
    network = "default"

    allow {
        protocol = "${lookup(var.fw_rules[count.index], "protocol", "tcp")}"
        ports = "${split(",", lookup(var.fw_rules[count.index], "ports"))}"
    }

    source_ranges = "${split(",", lookup(var.fw_rules[count.index], "source_ips"))}"
    target_tags = ["${var.role}"]
}
