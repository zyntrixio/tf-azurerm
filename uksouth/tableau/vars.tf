variable environment { default = "tableau" }

variable "tags" {
    type = map
    default = {
        Environment = "Tableau"
    }
}
