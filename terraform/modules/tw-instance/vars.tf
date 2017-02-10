variable "instances" {}
variable "dns_zone_name" {}
variable "dns_resource_name" {}

variable "disk_type" {
    default = "pd-standard"
}

variable "disk_scratch" {
    default = true
}

variable "disk_size" {
    default = 50
}

variable "machine_type" {
    default = "n1-standard-1"
}

variable "disk_auto_delete" {
    default = true
}

variable "role" {}

variable "environment" {}

variable "image" {
    default = "coreos-stable"
}

variable "region" {
    default = "europe-west-1"
}

variable "zone" {
    default = [
        "europe-west1-b",
        "europe-west1-c",
        "europe-west1-d"
    ]
}

variable "public_key_path" {}

variable "fw_rules" {
    type = "list"
}

variable "cloud_config_file" {
    default = "cloud-config.tpl"
}

variable "etcd_discovery_url" {
    default = "etcd_discovery_url.txt"
}

variable "preemptible" {
    default = false
}

variable "automatic_restart" {
    default = true
}
