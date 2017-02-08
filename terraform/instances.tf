module "tw_instance" {
    instances = 3
    source = "modules/tw-instance"
    role = "app"
    environment = "dev"
    public_key_path = "${var.public_key_path}"
    fw_rules = [
        {
            name = "world-to-ssh"
            protocol = "tcp"
            source_ips = "0.0.0.0"
            ports = "22"
        },
        {
            name = "world-to-http"
            protocol = "tcp"
            source_ips = "0.0.0.0"
            ports = "80"
        }
    ]
}
