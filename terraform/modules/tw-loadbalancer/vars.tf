variable "name" {}
variable "instances" {
    type = "list"
}

variable "zones" {
    type = "list"
}

variable "port" {}

variable "request_path" {
    default = "/"
}

variable "check_interval_sec" {
    default = 5
}

variable "healthy_threshold" {
    default = 2
}

variable "unhealthy_threshold" {
    default = 3
}

variable "timeout_sec" {
    default = 3
}
