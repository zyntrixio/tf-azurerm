variable resource_group_name {}
variable loadbalancer_id {}
variable backend_id {}
variable lb_probe_unhealthy_threshold { default = "2" }
variable lb_probe_interval { default = "5" }
variable lb_port { default = {} }
variable frontend_ip_configuration_name {}
