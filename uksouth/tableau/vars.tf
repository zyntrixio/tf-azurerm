# Module Variables
variable worker_subnet {}

variable environment { default = "tableau" }

variable "tags" {
    type = map
    default = {
        Environment = "Tableau"
    }
}
