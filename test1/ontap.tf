
variable "username" {
    type = string
}

variable "Appname" {
    type = string
}

variable "password" {
    type = string	
    sensitive = true
}
variable "validate_certs" {
    type = bool
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
      name = "vartofil001"
      hostname = "vartofil001"
      username = var.username
      password = var.password
      validate_certs = var.validate_certs
    }
	]
}

data "netapp-ontap_storage_aggregates_data_source" "all_aggregates" {
    # required to know which system to interface with
    cx_profile_name = "vartofil001"
      filter = {
        #name = "NA1_SSD"
       #"e06cd74e-8b98-48e2-9028-8bf3ccc2b619"
      }
   
}


/*
output "AggrsAvailable"{
  #value = data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates
  value = data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates[1]
  #value = data.netapp-ontap_storage_aggregates_data_source.all_aggregates
}
*/



resource "netapp-ontap_svm_resource" "terraformSVM" {
  cx_profile_name = "vartofil001"
  name = "TF_${var.Appname}"
  snapshot_policy = "default"
  subtype         = "default"
  language        = "c.utf_8"
  ipspace         = "Default"
  max_volumes     = "unlimited"
  #  #aggregates = [{name = "vartofil001_01_NVME_SSD_1"},{name = "vartofil001_02_NVME_SSD_1"}]
  aggregates = data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates
  lifecycle{
    #prevent_destroy = true
  }
}

resource "netapp-ontap_storage_volume_resource" "volume_1" {
  cx_profile_name = "vartofil001"
  svm_name = resource.netapp-ontap_svm_resource.terraformSVM.name
  aggregates = [{name=data.netapp-ontap_storage_aggregates_data_source.all_aggregates.storage_aggregates[0].name}]
    name = "${resource.netapp-ontap_svm_resource.terraformSVM.name}_Volume1"
  space = {
    size = 20
    size_unit = "mb"
  }
  language="c"
  depends_on = [netapp-ontap_svm_resource.terraformSVM]
}


/*
resource "netapp-ontap_storage_volume_resource" "volume_nog1" {
  cx_profile_name = "vartofil001"
  name = "TF_TestVolume2"
  svm_name = "terraformSVM"
  aggregates = [
    {
      name = "vartofil001_02_NVME_SSD_1"
    },
  ]
  space = {
    size = 100
    size_unit = "mb"
  }
  depends_on = [netapp-ontap_svm_resource.terraformSVM]
}

*/