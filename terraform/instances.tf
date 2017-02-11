module "tw_instance" {
    instances = 7
    source = "modules/tw-instance"
    role = "app"
    environment = "dev"
    public_key_path = "${var.public_key_path}"
    dns_zone_name   = "gce.norix.co.uk."
    dns_resource_name   = "norix"
    fw_rules = [
        {
            name = "world-to-ssh"
            protocol = "tcp"
            source_ips = "0.0.0.0/0"
            ports = "22"
        },
        {
            name = "world-to-http-80"
            protocol = "tcp"
            source_ips = "0.0.0.0/0"
            ports = "80"
        },
        {
            name = "world-to-http-8080"
            protocol = "tcp"
            source_ips = "0.0.0.0/0"
            ports = "8080"
        }
    ]
}
