module "tw_loadbalancer_80" {
    source              = "modules/tw-loadbalancer"
    name                = "www"
    port                = "80"
    instances           = "${module.tw_instance.names}"
    zones               = "${module.tw_instance.zones}"
    dns_zone_name       = "gce.norix.co.uk."
    dns_resource_name   = "norix"
}
