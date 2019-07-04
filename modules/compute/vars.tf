variable "admin" {
  description = "Default user with root access"
  type        = "map"

  default = {
    name       = "laadmin"
    public_key = ""
    password   = "TFB2248hxq!!"
  }
}

variable "vm_count" {
  description = "Used for counting"
}

variable "location" {
  description = "Resource location. To see full list run 'az account list-locations'"
}

variable "resource_group_name" {
  description = "Name of the corresponding resource group"
}

variable "subnet_id" {
  description = "The id of the corresponding subnet"
}

variable "vm_type_name" {
  description = "Name of the type of virtual machine"
}

variable "vm_size" {
  description = "Size of the vm. To see full list run 'az vm list-sizes'"
}

variable "vm_disk_size" {
  description = "Size of OS disk gb"
  default     = "32"
}

variable "vm_disk_type" {
  description = "Storage class. Can be Standard_LRS or Premium_LRS"
  default     = "StandardSSD_LRS"
}

variable "os" {
  description = "Disk image with preinstalled OS"
  type        = "map"

  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "lb_backend_address_pool_id_list" {
  description = "the id for the azurerm_lb_backend_address_pool resource"
#  type        = "list"
#  default     = ["",""]
}
