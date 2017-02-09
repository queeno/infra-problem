 output "vm-public_ip_address" {
    value = "${formatlist("%s/%s", module.tw_instance.names, module.tw_instance.public_ip_address)}"
}
