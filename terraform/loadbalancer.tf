module "tw_loadbalancer" {
    source      = "modules/tw-loadbalancer"
    name        = "thoughtworks"
    port        = "80"
    instances   = "${module.tw_instance.names}"
    zones       = "${module.tw_instance.zones}"
}
