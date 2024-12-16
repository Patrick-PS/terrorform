variable "SVMname" {
    type = string
    description = "SVM naam"
}

variable "Volumename" {
    type = string
    description = "Volume naam"
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


data "netapp-ontap_storage_aggregates_data_source" "all_aggregates" {
    # required to know which system to interface with
    cx_profile_name = "OntapProfile"
      filter = {
        #name = "NA1_SSD"
       #"e06cd74e-8b98-48e2-9028-8bf3ccc2b619"
      }
   
}



resource "netapp-ontap_storage_volume_resource" "volume_1" {
  cx_profile_name = "OntapProfile"
  svm_name = var.SVMname
  aggregates = [{name=data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates[0].name}]
    name = var.Volumename
  space = {
    size = var.VolSize
    size_unit = var.VolSizeUnit
  }
  #depends_on = [netapp-ontap_svm_resource.terraformSVM]
  #count =0
}


output "CreatedVol"{
 value = resource.netapp-ontap_storage_volume_resource.volume_1
}
