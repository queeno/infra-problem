module "tw_loadbalancer_80" {
    source      = "modules/tw-loadbalancer"
    name        = "thoughtworks-80"
    port        = "80"
    instances   = "${module.tw_instance.names}"
    zones       = "${module.tw_instance.zones}"
}
