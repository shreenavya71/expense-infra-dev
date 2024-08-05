variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        project = "expense"
        environment = "dev"
        terraform = "true"
        component = "web-alb"
    }
}

variable "zone_name" {
    default = "devopsnavyahome.online"
}