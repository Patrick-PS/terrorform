variable "SVMname" {
    type = string
    description = "SVM naam"
}

variable "Volumename" {
    type = string
    description = "Volume naam"
}

variable "Aggrname" {
    type = string
    description = "Aggregate naam"
}

variable "VolSize" {
    type = number
    description = "Size of each volume"
    default =20
}

variable "VolSizeUnit" {
    type = string
    description = "mb /gb /tb"
    default="mb"
    validation{
    condition = lower(var.VolSizeUnit) =="mb" || lower(var.VolSizeUnit) =="gb" || lower(var.VolSizeUnit) =="tb"
    error_message = "alleen mb gb tb toegestaan"
  }
}

module "TestCreds" {
  source = "../../Filers/vartofil001"
}


terraform {
  required_providers {
    netapp-ontap = {
      source = "NetApp/netapp-ontap"
      version = "1.1.4"
    }
  }
}

provider "netapp-ontap" {
  # Configuration options
  connection_profiles = [
    {
      name = "OntapProfile"
      hostname =       module.TestCreds.Auth.filer
      username =       module.TestCreds.Auth.username
      password =       module.TestCreds.Auth.password
      validate_certs = module.TestCreds.Auth.validate_certs
    }
	]
}



resource "netapp-ontap_storage_volume_resource" "volume_1" {
  cx_profile_name = "OntapProfile"
  svm_name = var.SVMname
  aggregates = [{name=var.Aggrname}]
  name = var.Volumename
  space = {
    size = var.VolSize
    size_unit = lower(var.VolSizeUnit)
  }
  #depends_on = [netapp-ontap_svm_resource.terraformSVM]
  #count =0
}


output "result"{
 value = resource.netapp-ontap_storage_volume_resource.volume_1
}
