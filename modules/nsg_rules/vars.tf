variable resource_group_name {}
variable network_security_group_name {}
variable rules {
    description = "List of Security Rules"
    type = list
    default = []
}
